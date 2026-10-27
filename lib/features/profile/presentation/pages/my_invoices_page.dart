import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/subscription_usecases.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:url_launcher/url_launcher.dart';

class MyInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String propertyName;
  final String? propertyId;
  final bool isCurrent;
  final String servicePeriod;
  final String paidDate;
  final int totalBeds;
  final double totalAmount;
  final String invoiceDate;
  final String status;
  final Color docBgColor;
  final Color docIconColor;
  final String? receiptPaymentId;
  final String? downloadUrl;
  final String? receiptUrl;
  final String? invoicePdf;

  MyInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.propertyName,
    this.propertyId,
    this.isCurrent = false,
    required this.servicePeriod,
    required this.paidDate,
    required this.totalBeds,
    required this.totalAmount,
    required this.invoiceDate,
    this.status = 'Paid',
    required this.docBgColor,
    required this.docIconColor,
    this.receiptPaymentId,
    this.downloadUrl,
    this.receiptUrl,
    this.invoicePdf,
  });
}

class MyInvoicesPage extends StatefulWidget {
  const MyInvoicesPage({super.key});

  @override
  State<MyInvoicesPage> createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends State<MyInvoicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _downloadingIds = {};

  bool _isLoading = true;
  String? _errorMessage;
  List<MyInvoiceModel> _allInvoices = [];

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReceipts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final useCase = sl<GetMyReceiptsUseCase>();
      final receipts = await useCase();

      final mappedInvoices = <MyInvoiceModel>[];

      final docStyles = [
        const {'bg': Color(0xFFEFF6FF), 'icon': Color(0xFF2563EB)},
        const {'bg': Color(0xFFFFF7ED), 'icon': Color(0xFFEA580C)},
        const {'bg': Color(0xFFF3E8FF), 'icon': Color(0xFF9333EA)},
      ];

      for (int i = 0; i < receipts.length; i++) {
        final receipt = receipts[i];
        final style = docStyles[i % docStyles.length];

        final isCurrent =
            receipt.subscription?.status.toUpperCase() == 'ACTIVE';

        // Format dates safely
        String servicePeriod = 'N/A';
        if (receipt.subscription?.startDate != null &&
            receipt.subscription?.endDate != null) {
          final startStr = _dateFormatter.format(receipt.subscription!.startDate!);
          final endStr = _dateFormatter.format(receipt.subscription!.endDate!);
          servicePeriod = '$startStr - $endStr';
        } else if (receipt.subscription?.plan?.planName != null &&
            receipt.subscription!.plan!.planName.isNotEmpty) {
          servicePeriod = receipt.subscription!.plan!.planName;
        }

        String paidDate = 'Paid';
        if (receipt.receiptDate != null) {
          paidDate = 'Paid on ${_dateFormatter.format(receipt.receiptDate!)}';
        }

        String invoiceDateStr = 'N/A';
        if (receipt.invoice?.invoiceDate != null) {
          invoiceDateStr = _dateFormatter.format(receipt.invoice!.invoiceDate!);
        } else if (receipt.receiptDate != null) {
          invoiceDateStr = _dateFormatter.format(receipt.receiptDate!);
        }

        String statusStr = 'Paid';
        if (receipt.invoice?.status != null &&
            receipt.invoice!.status.isNotEmpty) {
          final rawStatus = receipt.invoice!.status.toUpperCase();
          if (rawStatus == 'PAID' || rawStatus == 'SUCCESS') {
            statusStr = 'Paid';
          } else {
            statusStr =
                rawStatus[0] + rawStatus.substring(1).toLowerCase();
          }
        } else if (receipt.paymentStatus.isNotEmpty) {
          final rawStatus = receipt.paymentStatus.toUpperCase();
          if (rawStatus == 'PAID' || rawStatus == 'SUCCESS') {
            statusStr = 'Paid';
          } else {
            statusStr =
                rawStatus[0] + rawStatus.substring(1).toLowerCase();
          }
        }

        final invoiceNum = receipt.invoice?.invoiceNumber.isNotEmpty == true
            ? receipt.invoice!.invoiceNumber
            : (receipt.receiptNumber.isNotEmpty == true
                ? receipt.receiptNumber
                : 'INV-${receipt.receiptId}');

        mappedInvoices.add(
          MyInvoiceModel(
            id: receipt.receiptId.isNotEmpty
                ? receipt.receiptId
                : receipt.paymentId,
            invoiceNumber: invoiceNum,
            propertyName: receipt.property?.name ?? 'Property',
            propertyId: receipt.property?.id,
            isCurrent: isCurrent,
            servicePeriod: servicePeriod,
            paidDate: paidDate,
            totalBeds: receipt.subscription?.totalBeds ?? 0,
            totalAmount: receipt.amount > 0
                ? receipt.amount
                : (receipt.breakdown?.totalAmount ?? 0.0),
            invoiceDate: invoiceDateStr,
            status: statusStr,
            docBgColor: style['bg']!,
            docIconColor: style['icon']!,
            receiptPaymentId: receipt.paymentId.isNotEmpty
                ? receipt.paymentId
                : receipt.receiptId,
            downloadUrl: receipt.downloadUrl,
            receiptUrl: receipt.receiptUrl,
            invoicePdf: receipt.invoice?.invoicePdf,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _allInvoices = mappedInvoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatNumber(num n) {
    final s = n.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Future<void> _handleInvoiceDownload(MyInvoiceModel invoice) async {
    if (_downloadingIds.contains(invoice.id)) return;

    setState(() {
      _downloadingIds.add(invoice.id);
    });

    try {
      String? targetUrl;

      if (invoice.invoicePdf != null && invoice.invoicePdf!.isNotEmpty) {
        targetUrl = invoice.invoicePdf;
      } else if (invoice.receiptUrl != null && invoice.receiptUrl!.isNotEmpty) {
        targetUrl = invoice.receiptUrl;
      }

      if (targetUrl == null || targetUrl.isEmpty) {
        if (invoice.receiptPaymentId != null &&
            invoice.receiptPaymentId!.isNotEmpty) {
          final useCase = sl<GetPaymentReceiptUseCase>();
          final result = await useCase(invoice.receiptPaymentId!);
          targetUrl = result['fileUrl'];
        }
      }

      if ((targetUrl == null || targetUrl.isEmpty) &&
          invoice.downloadUrl != null &&
          invoice.downloadUrl!.isNotEmpty) {
        if (invoice.downloadUrl!.startsWith('http')) {
          targetUrl = invoice.downloadUrl;
        } else {
          targetUrl = '${ApiConstants.baseUrl}${invoice.downloadUrl}';
        }
      }

      if (targetUrl != null && targetUrl.isNotEmpty) {
        final uri = Uri.parse(targetUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Invoice ${invoice.invoiceNumber} receipt is unavailable.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not download invoice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingIds.remove(invoice.id);
        });
      }
    }
  }

  void _handleInvoiceView(MyInvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInvoiceDetailSheet(invoice),
    );
  }

  List<MyInvoiceModel> _getFilteredInvoiceList() {
    if (_searchQuery.trim().isEmpty) {
      return _allInvoices;
    }

    final query = _searchQuery.toLowerCase().trim();
    return _allInvoices.where((inv) {
      return inv.invoiceNumber.toLowerCase().contains(query) ||
          inv.propertyName.toLowerCase().contains(query) ||
          inv.servicePeriod.toLowerCase().contains(query) ||
          inv.invoiceDate.toLowerCase().contains(query) ||
          inv.paidDate.toLowerCase().contains(query) ||
          inv.totalAmount.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _getFilteredInvoiceList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Invoices',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'View and manage all your service invoices',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SizedBox(
                height: 44.h,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by invoice number, date or amount...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: const Color(0xFF64748B),
                      size: 20.sp,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 44.h,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Invoices List Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 48.sp,
                                  color: Colors.red.shade400,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Failed to load invoices',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _fetchReceipts,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredInvoices.isEmpty
                          ? RefreshIndicator(
                              onRefresh: _fetchReceipts,
                              color: AppColors.primaryBlue,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 120.h),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 48.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'No invoices found',
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchReceipts,
                              color: AppColors.primaryBlue,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                itemCount: filteredInvoices.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 14.h),
                                itemBuilder: (context, index) {
                                  final invoice = filteredInvoices[index];
                                  return _buildInvoiceCard(invoice);
                                },
                              ),
                            ),
            ),

            // Bottom Sticky Bar (Go to Home)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    size: 20.sp,
                    color: AppColors.primaryBlue,
                  ),
                  label: Text(
                    'Go to Home',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(MyInvoiceModel invoice) {
    final isDownloading = _downloadingIds.contains(invoice.id);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: invoice.isCurrent
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE2E8F0),
          width: invoice.isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Doc Icon + Title/Period + Paid Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored Document Icon Container
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: invoice.docBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: invoice.docIconColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),

              // Property Name & Service Period
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            invoice.propertyName,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (invoice.isCurrent) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Current',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      invoice.servicePeriod,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Service Period',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Status Badge & Paid Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 11.sp,
                          color: const Color(0xFF166534),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          invoice.status,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    invoice.paidDate,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Middle Bar (3 Columns: Service Units | Total Amount | Invoice Date)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                // Column 1: Beds / Service Units
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.single_bed_outlined,
                            size: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${invoice.totalBeds} Beds',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Service Units',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 26.h,
                  color: const Color(0xFFE2E8F0),
                ),

                // Column 2: Total Amount
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '₹${_formatNumber(invoice.totalAmount)}',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Total Amount',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: 26.h,
                  color: const Color(0xFFE2E8F0),
                ),

                // Column 3: Invoice Date
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                invoice.invoiceDate,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Invoice Date',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Action Buttons: View Invoice & Download Invoice
          Row(
            children: [
              // View Invoice Button
              Expanded(
                child: SizedBox(
                  height: 36.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleInvoiceView(invoice),
                    icon: Icon(
                      Icons.radio_button_checked,
                      size: 14.sp,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      'View Invoice',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // Download Invoice Button
              Expanded(
                child: SizedBox(
                  height: 36.h,
                  child: ElevatedButton.icon(
                    onPressed: isDownloading
                        ? null
                        : () => _handleInvoiceDownload(invoice),
                    icon: isDownloading
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.file_download_outlined,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                    label: Text(
                      'Download Invoice',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailSheet(MyInvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice Details',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  invoice.status,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          _buildDetailRow('Invoice No.', invoice.invoiceNumber),
          SizedBox(height: 10.h),
          _buildDetailRow('Property', invoice.propertyName),
          SizedBox(height: 10.h),
          _buildDetailRow('Service Units', '${invoice.totalBeds} Beds'),
          SizedBox(height: 10.h),
          _buildDetailRow('Service Period', invoice.servicePeriod),
          SizedBox(height: 10.h),
          _buildDetailRow('Invoice Date', invoice.invoiceDate),
          SizedBox(height: 10.h),
          _buildDetailRow('Payment Details', invoice.paidDate),
          SizedBox(height: 10.h),
          _buildDetailRow(
            'Total Amount',
            '₹${_formatNumber(invoice.totalAmount)}',
            valueColor: AppColors.primaryBlue,
            isBold: true,
          ),

          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _handleInvoiceDownload(invoice);
              },
              icon: Icon(
                Icons.file_download_outlined,
                size: 18.sp,
                color: Colors.white,
              ),
              label: Text(
                'Download Receipt PDF',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
