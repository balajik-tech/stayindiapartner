import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/stock_management/presentation/cubit/stock_cubit.dart';
import 'package:stayindia_owner/features/stock_management/domain/entities/stock_item.dart';
import 'package:stayindia_owner/features/stock_management/core/stock_constants.dart';

class NumpadEntrySheet extends StatefulWidget {
  final String itemName;
  final String category;
  final String defaultUnit;
  final String propertyId;
  final StockItem? existingItem;
  final VoidCallback onSubmitted;

  const NumpadEntrySheet({
    super.key,
    required this.itemName,
    required this.category,
    required this.defaultUnit,
    required this.propertyId,
    this.existingItem,
    required this.onSubmitted,
  });

  @override
  State<NumpadEntrySheet> createState() => _NumpadEntrySheetState();
}

class _NumpadEntrySheetState extends State<NumpadEntrySheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.defaultUnit;
    _priceController.text = '';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });

    _amountController.addListener(_onInputChanged);
    _priceController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onInputChanged);
    _priceController.removeListener(_onInputChanged);
    _amountController.dispose();
    _priceController.dispose();
    _amountFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  double get _totalPrice {
    return double.tryParse(_priceController.text) ?? 0.0;
  }

  double get _pricePerUnit {
    final qty = double.tryParse(_amountController.text) ?? 0.0;
    if (qty <= 0) return 0.0;
    return _totalPrice / qty;
  }

  void _submitTransaction() async {
    final String qtyText = _amountController.text.trim();
    final String priceText = _priceController.text.trim();

    if (qtyText.isEmpty || double.tryParse(qtyText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.locale.languageCode == 'te' ? "సరైన పరిమాణాన్ని నమోదు చేయండి" : "Please enter a valid quantity",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final double quantity = double.parse(qtyText);

    if (priceText.isEmpty || double.tryParse(priceText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.locale.languageCode == 'te' ? "మొత్తం ధరను నమోదు చేయండి" : "Please enter a valid total price",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }
    final double totalPrice = double.parse(priceText);
    final double pricePerUnit = quantity > 0 ? totalPrice / quantity : 0.0;

    final cubit = context.read<StockCubit>();

    try {
      if (widget.existingItem != null) {
        await cubit.addStockTransaction(
          widget.existingItem!.id,
          widget.propertyId,
          quantity,
          pricePerUnit,
          totalPrice,
          'Cash',
          DateTime.now(),
          'In-field entry',
        );
      } else {
        final String backendUnit;
        switch (_selectedUnit.toUpperCase()) {
          case 'KG':
            backendUnit = 'kg';
            break;
          case 'LTR':
            backendUnit = 'liters';
            break;
          case 'PCS':
            backendUnit = 'pieces';
            break;
          case 'BAG':
            backendUnit = 'units';
            break;
          case 'PACK':
            backendUnit = 'packets';
            break;
          default:
            final lower = _selectedUnit.toLowerCase();
            if (const ['kg', 'liters', 'pieces', 'packets', 'units'].contains(lower)) {
              backendUnit = lower;
            } else {
              backendUnit = 'units';
            }
        }

        await cubit.addTransaction(
          propertyId: widget.propertyId,
          itemName: widget.itemName,
          category: widget.category,
          unit: backendUnit,
          quantity: quantity,
          totalAmount: totalPrice,
          paymentMode: 'Cash',
          notes: 'In-field entry',
        );
      }

      widget.onSubmitted();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'te' ? "ఇన్వెంటరీకి స్టాక్ విజయవంతంగా జోడించబడింది" : "Stock added to inventory successfully!",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTe = context.locale.languageCode == 'te';
    final localizedName = StockConstants.getLocalizedNameForString(widget.itemName, context.locale.languageCode);

    final List<String> unitChoices = ['KG', 'LTR', 'PCS', 'BAG', 'PACK'];
    if (!unitChoices.contains(_selectedUnit.toUpperCase())) {
      unitChoices.add(_selectedUnit);
    }

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomInset > 0 ? bottomInset + 12.h : safeBottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.itemName,
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTe || localizedName != widget.itemName)
                      Text(
                        "($localizedName)",
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.black26, fontSize: 20.sp),
              labelText: isTe ? 'పరిమాణం' : 'Quantity',
              labelStyle: const TextStyle(color: Color(0xFF16539B), fontWeight: FontWeight.bold),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: const Icon(Icons.calculate_rounded, color: Color(0xFF16539B)),
              suffixIcon: Container(
                margin: EdgeInsets.only(right: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16539B),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _selectedUnit,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: Color(0xFF16539B), width: 2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _priceController,
            focusNode: _priceFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.black26, fontSize: 20.sp),
              labelText: isTe ? 'మొత్తం ధర' : 'Total Price (₹)',
              labelStyle: const TextStyle(color: Color(0xFF16539B), fontWeight: FontWeight.bold),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF16539B)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: Color(0xFF16539B), width: 2),
              ),
            ),
          ),
          if (_pricePerUnit > 0) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFDCE4F5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isTe ? 'యూనిట్ ధర:' : 'Price per Unit:',
                    style: TextStyle(
                      color: const Color(0xFF16539B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹ ${_pricePerUnit.toStringAsFixed(2)} / $_selectedUnit',
                    style: TextStyle(
                      color: const Color(0xFF16539B),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          Text(
            isTe ? 'ప్రమాణం ఎంచుకోండి' : 'Select Unit',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            children: unitChoices.map((unit) {
              final isSelected = _selectedUnit.toUpperCase() == unit.toUpperCase();
              return ChoiceChip(
                label: Text(
                  unit,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF16539B),
                backgroundColor: const Color(0xFFF1F5F9),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF16539B) : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedUnit = unit;
                    });
                  }
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _submitTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16539B),
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            child: Text(
              isTe ? 'ఇన్వెంటరీకి స్టాక్ జోడించు' : 'Add Stock to Inventory',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
