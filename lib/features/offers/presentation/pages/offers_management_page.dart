import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/injection_container.dart';
import '../../domain/entities/offer_entity.dart';
import '../cubit/offers_cubit.dart';
import '../cubit/offers_state.dart';

class OffersManagementPage extends StatelessWidget {
  const OffersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String? ownerId;
    if (authState is AuthAuthenticated) {
      ownerId = authState.owner.id;
    }

    return BlocProvider(
      create: (context) => sl<OffersCubit>()..fetchOffers(createdBy: ownerId),
      child: const OffersManagementView(),
    );
  }
}

class OffersManagementView extends StatefulWidget {
  const OffersManagementView({super.key});

  @override
  State<OffersManagementView> createState() => _OffersManagementViewState();
}

class _OffersManagementViewState extends State<OffersManagementView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String? ownerId = authState is AuthAuthenticated
        ? authState.owner.id
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          StringUtils.translate('manage_offers', context: context),
          style: GoogleFonts.outfit(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2C5990),
        onPressed: () => _showOfferForm(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          StringUtils.translate('create_offer', context: context),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: BlocConsumer<OffersCubit, OffersState>(
              listener: (context, state) {
                if (state is OfferOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: GoogleFonts.outfit()),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is OffersError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: GoogleFonts.outfit()),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OffersLoading && state is! OffersLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OffersLoaded || state is OfferOperationSuccess) {
                  final offers = state is OffersLoaded
                      ? state.offers
                      : (context.read<OffersCubit>().state is OffersLoaded
                            ? (context.read<OffersCubit>().state
                                      as OffersLoaded)
                                  .offers
                            : <OfferEntity>[]);

                  final filteredOffers = offers.where((offer) {
                    final query = _searchQuery.toLowerCase();
                    return offer.title.toLowerCase().contains(query) ||
                        offer.description.toLowerCase().contains(query) ||
                        (offer.code?.toLowerCase().contains(query) ?? false);
                  }).toList();

                  if (filteredOffers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<OffersCubit>().fetchOffers(
                      createdBy: ownerId,
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                      itemCount: filteredOffers.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final offer = filteredOffers[index];
                        return _OfferCard(
                          offer: offer,
                          onEdit: () => _showOfferForm(context, offer: offer),
                        );
                      },
                    ),
                  );
                }

                if (state is OffersError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade300,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: GoogleFonts.outfit(color: AppColors.greyText),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: GoogleFonts.outfit(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: StringUtils.translate(
            'search_offers_hint',
            context: context,
          ),
          hintStyle: GoogleFonts.outfit(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: 64.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            StringUtils.translate('no_offers_yet', context: context),
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            StringUtils.translate('create_offer_desc', context: context),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.greyText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferForm(BuildContext context, {OfferEntity? offer}) {
    final offersCubit = context.read<OffersCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: offersCubit),
          BlocProvider.value(value: context.read<AuthCubit>()),
          BlocProvider.value(value: context.read<HostelCubit>()),
        ],
        child: _OfferFormSheet(offer: offer),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onEdit;

  const _OfferCard({required this.offer, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isPercentage = offer.type == 'PERCENTAGE';
    final isFlat = offer.type == 'FLAT';
    final isReferral = offer.type == 'REFERRAL';

    Color themeColor = const Color(0xFF2C5990);
    IconData iconData = Icons.local_offer_rounded;

    if (isPercentage) {
      themeColor = const Color(0xFF10B981);
      iconData = Icons.percent_rounded;
    } else if (isFlat) {
      themeColor = const Color(0xFFF59E0B);
      iconData = Icons.currency_rupee_rounded;
    } else if (isReferral) {
      themeColor = const Color(0xFF8B5CF6);
      iconData = Icons.people_outline_rounded;
    }

    final authState = context.read<AuthCubit>().state;
    final String? ownerId = authState is AuthAuthenticated
        ? authState.owner.id
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: themeColor, size: 20.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                offer.type,
                                style: GoogleFonts.outfit(
                                  color: themeColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: offer.isActive,
                              activeThumbColor: const Color(0xFF10B981),
                              activeTrackColor: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.5),
                              onChanged: (val) {
                                context.read<OffersCubit>().updateOffer(
                                  offer.id,
                                  {'isActive': val},
                                  refreshCreatedBy: ownerId,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          offer.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          offer.description,
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            color: AppColors.greyText,
                            height: 1.4,
                          ),
                        ),
                        if (offer.code != null && offer.code!.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.vpn_key_rounded,
                                  size: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  offer.code!,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            StringUtils.translate(
                              'ends_label',
                              context: context,
                              namedArgs: {
                                'date': offer.endDate != null
                                    ? DateFormat(
                                        'dd MMM yyyy',
                                      ).format(offer.endDate!)
                                    : StringUtils.translate(
                                        'never',
                                        context: context,
                                      ),
                              },
                            ),
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (offer.hostelName != null) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.apartment_rounded,
                            size: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              offer.hostelName!,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18.sp,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: onEdit,
                      ),
                      SizedBox(width: 16.w),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18.sp,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => _confirmDelete(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final offersCubit = context.read<OffersCubit>();
    final authState = context.read<AuthCubit>().state;
    final String? ownerId = authState is AuthAuthenticated
        ? authState.owner.id
        : null;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          StringUtils.translate('delete_offer_title', context: context),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        content: Text(
          StringUtils.translate('delete_offer_confirm', context: context),
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              StringUtils.translate('cancel', context: context),
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              StringUtils.translate('delete', context: context),
              style: GoogleFonts.outfit(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      offersCubit.deleteOffer(offer.id, refreshCreatedBy: ownerId);
    }
  }
}

class _OfferFormSheet extends StatefulWidget {
  final OfferEntity? offer;

  const _OfferFormSheet({this.offer});

  @override
  State<_OfferFormSheet> createState() => _OfferFormSheetState();
}

class _OfferFormSheetState extends State<_OfferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _codeController;
  late TextEditingController _valueController;

  String _selectedType = 'PROMOTIONAL';
  String? _selectedHostelId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.offer?.title ?? '');
    _descController = TextEditingController(
      text: widget.offer?.description ?? '',
    );
    _codeController = TextEditingController(text: widget.offer?.code ?? '');
    _valueController = TextEditingController(
      text: widget.offer?.value != null
          ? widget.offer!.value.toStringAsFixed(0)
          : '0',
    );

    if (widget.offer != null) {
      _selectedType = widget.offer!.type;
      _selectedHostelId = widget.offer!.hostelId;
      _startDate = widget.offer!.startDate;
      _endDate = widget.offer!.endDate;
      _isActive = widget.offer!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _updatePromoCodeWithPrefix({
    String? newHostelId,
    String? customBaseCode,
  }) {
    final hostState = context.read<HostelCubit>().state;
    String? hostelName;
    if (hostState is HostelLoaded) {
      final targetId = newHostelId ?? _selectedHostelId;
      if (targetId != null) {
        Hostel? targetHostel;
        for (final h in hostState.hostels) {
          if (h.id == targetId) {
            targetHostel = h;
            break;
          }
        }
        if (targetHostel != null && targetHostel.name.isNotEmpty) {
          hostelName = targetHostel.name;
        }
      }
    }

    String base = (customBaseCode ?? _codeController.text).trim().toUpperCase();
    if (base.contains('-')) {
      final parts = base.split('-');

      base = parts.sublist(1).join('-');
    }

    if (base.isEmpty) {
      base = "OFFER";
    }

    if (hostelName != null) {
      final prefix = hostelName
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      _codeController.text = "$prefix-$base";
    } else {
      _codeController.text = base;
    }
  }

  Widget _buildTemplateChip({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String? ownerId = authState is AuthAuthenticated
        ? authState.owner.id
        : null;
    final hostelState = context.read<HostelCubit>().state;

    List<Hostel> hostels = [];
    if (hostelState is HostelLoaded) {
      hostels = hostelState.hostels;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                StringUtils.translate(
                  widget.offer == null ? 'create_offer' : 'edit_offer_details',
                  context: context,
                ),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Quick Templates",
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildTemplateChip(
                      title: "Welcome Offer",
                      icon: Icons.celebration_rounded,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        _titleController.text = "Welcome Discount";
                        _descController.text =
                            "Get ₹1000 off on your first month's stay!";
                        setState(() {
                          _selectedType = "FLAT";
                          _valueController.text = "1000";
                        });
                        _updatePromoCodeWithPrefix(
                          customBaseCode: "WELCOME1000",
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildTemplateChip(
                      title: "Long Stay 10%",
                      icon: Icons.history_rounded,
                      color: const Color(0xFF2C5990),
                      onTap: () {
                        _titleController.text = "Long Stay Benefit";
                        _descController.text =
                            "Get 10% off for staying more than 6 months!";
                        setState(() {
                          _selectedType = "PERCENTAGE";
                          _valueController.text = "10";
                        });
                        _updatePromoCodeWithPrefix(
                          customBaseCode: "LONGSTAY10",
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildTemplateChip(
                      title: "Flat 500 Off",
                      icon: Icons.currency_rupee_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        _titleController.text = "Flat Discount";
                        _descController.text =
                            "Flat ₹500 off on your room booking!";
                        setState(() {
                          _selectedType = "FLAT";
                          _valueController.text = "500";
                        });
                        _updatePromoCodeWithPrefix(customBaseCode: "SAVE500");
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildTemplateChip(
                      title: "Referral Bonus",
                      icon: Icons.people_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        _titleController.text = "Referral Bonus";
                        _descController.text =
                            "Refer a friend and get flat ₹500 off on next rent!";
                        setState(() {
                          _selectedType = "REFERRAL";
                          _valueController.text = "500";
                        });
                        _updatePromoCodeWithPrefix(customBaseCode: "REFER500");
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.outfit(fontSize: 14.sp),
                decoration: _buildInputDecoration(
                  StringUtils.translate('offer_title_hint', context: context),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 14.sp),
                decoration: _buildInputDecoration(
                  StringUtils.translate('offer_desc_hint', context: context),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      style: GoogleFonts.outfit(fontSize: 14.sp),
                      textCapitalization: TextCapitalization.characters,
                      decoration: _buildInputDecoration(
                        StringUtils.translate(
                          'promo_code_hint',
                          context: context,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: _buildInputDecoration(
                        StringUtils.translate('offer_type', context: context),
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'PROMOTIONAL',
                          child: Text(
                            StringUtils.translate(
                              'offer_type_promotional',
                              context: context,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'PERCENTAGE',
                          child: Text(
                            StringUtils.translate(
                              'offer_type_percentage',
                              context: context,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'FLAT',
                          child: Text(
                            StringUtils.translate(
                              'offer_type_flat',
                              context: context,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'REFERRAL',
                          child: Text(
                            StringUtils.translate(
                              'offer_type_referral',
                              context: context,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedType == 'PERCENTAGE' || _selectedType == 'FLAT') ...[
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _valueController,
                  style: GoogleFonts.outfit(fontSize: 14.sp),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _buildInputDecoration(
                    _selectedType == 'PERCENTAGE'
                        ? StringUtils.translate(
                            'discount_percentage',
                            context: context,
                          )
                        : StringUtils.translate(
                            'flat_discount_amount',
                            context: context,
                          ),
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _selectedHostelId,
                decoration: _buildInputDecoration(
                  StringUtils.translate(
                    'applicable_property_hint',
                    context: context,
                  ),
                ),
                style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      StringUtils.translate(
                        'global_all_properties',
                        context: context,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  ...hostels.map(
                    (h) => DropdownMenuItem(
                      value: h.id,
                      child: Text(
                        h.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedHostelId = val;
                  });
                  _updatePromoCodeWithPrefix(newHostelId: val);
                },
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                StringUtils.translate(
                                  'starts_label',
                                  context: context,
                                  namedArgs: {
                                    'date': DateFormat(
                                      'dd MMM yyyy',
                                    ).format(_startDate),
                                  },
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _endDate != null
                                    ? StringUtils.translate(
                                        'ends_label',
                                        context: context,
                                        namedArgs: {
                                          'date': DateFormat(
                                            'dd MMM yyyy',
                                          ).format(_endDate!),
                                        },
                                      )
                                    : StringUtils.translate(
                                        'ends_never',
                                        context: context,
                                      ),
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      StringUtils.translate(
                        'make_active_immediately',
                        context: context,
                      ),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Switch.adaptive(
                    value: _isActive,
                    activeThumbColor: const Color(0xFF10B981),
                    activeTrackColor: const Color(
                      0xFF10B981,
                    ).withValues(alpha: 0.5),
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final title = _titleController.text.trim();
                      final description = _descController.text.trim();
                      final code = _codeController.text.trim().toUpperCase();
                      final double value =
                          double.tryParse(_valueController.text) ?? 0.0;

                      final payload = OfferEntity(
                        id: widget.offer?.id ?? '',
                        title: title,
                        description: description,
                        code: code.isNotEmpty ? code : null,
                        type: _selectedType,
                        value: value,
                        startDate: _startDate,
                        endDate: _endDate,
                        isActive: _isActive,
                        hostelId: _selectedHostelId,
                      );

                      if (widget.offer == null) {
                        context.read<OffersCubit>().createOffer(
                          payload,
                          refreshCreatedBy: ownerId,
                        );
                      } else {
                        context.read<OffersCubit>().updateOffer(
                          widget.offer!.id,
                          payload.toJson(),
                          refreshCreatedBy: ownerId,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5990),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    StringUtils.translate(
                      widget.offer == null ? 'publish_offer' : 'save_changes',
                      context: context,
                    ),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: Colors.grey.shade500,
        fontSize: 13.sp,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF2C5990), width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _startDate
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
