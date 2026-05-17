import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../domain/entities/stock_item.dart';
import '../../data/default_stock_items_data.dart';
import '../../core/stock_constants.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class AddStockItemPage extends StatefulWidget {
  final String propertyId;
  const AddStockItemPage({super.key, required this.propertyId});

  @override
  State<AddStockItemPage> createState() => _AddStockItemPageState();
}

class _AddStockItemPageState extends State<AddStockItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0.0');
  final _totalController = TextEditingController(text: '0.0');
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Grocery';
  String _selectedUnit = 'kg';
  String _selectedPaymentMode = 'Cash';

  final List<String> _categories = ['Grocery', 'Vegetables', 'Cleaning', 'Other'];
  final List<String> _units = ['kg', 'liters', 'pieces', 'packets', 'units'];
  final List<String> _paymentModes = ['UPI', 'Cash', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_calculateTotal);
    _priceController.removeListener(_calculateTotal);
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (qty > 0 && price > 0) {
      final total = qty * price;
      _totalController.text = total.toStringAsFixed(1);
    }
  }

  void _showStockItemSelectionSheet(BuildContext context) {
    final allItems = context.read<StockCubit>().state.items;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final existingNames = allItems.map((e) => e.name.toLowerCase()).toSet();
            final defaultItemsToAdd = defaultMasterStockItems
                .where((e) => !existingNames.contains(e.name.toLowerCase()))
                .map((e) => StockItem(
                      id: 'static',
                      propertyId: widget.propertyId,
                      name: e.name,
                      category: e.category,
                      unit: e.unit,
                      currentQuantity: 0,
                      minimumThreshold: 5,
                      pricePerUnit: 0,
                      createdBy: 'static',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ))
                .toList();

            final combinedItems = [...allItems, ...defaultItemsToAdd];
            final filteredItems = combinedItems.where((item) {
              final query = searchQuery.toLowerCase();
              final nameEn = item.name.toLowerCase();
              final nameLoc = StockConstants.getLocalizedNameForEntity(item, context.locale.languageCode).toLowerCase();
              return nameEn.contains(query) || nameLoc.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringUtils.translate('select_stock_item', context: context),
                        style: TextStyle(
                          color: const Color(0xFF2C5990),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      BouncingWrapper(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, size: 18.sp, color: const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFF2C5990)),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setSheetState(() => searchQuery = val);
                      },
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
                      decoration: InputDecoration(
                        hintText: StringUtils.translate('search_ingredients', context: context),
                        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 15.sp),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48.sp, color: const Color(0xFFCBD5E1)),
                                SizedBox(height: 12.h),
                                Text(
                                  searchQuery.isNotEmpty 
                                      ? StringUtils.translate('no_matching_items', context: context) 
                                      : StringUtils.translate('no_items_available', context: context),
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                                ),
                                if (searchQuery.isNotEmpty) ...[
                                  SizedBox(height: 16.h),
                                  BouncingWrapper(
                                    onTap: () {
                                      setState(() {
                                        _nameController.text = searchQuery;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C5990),
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Text(
                                        StringUtils.translate('use_query', namedArgs: {'query': searchQuery}, context: context),
                                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length + (searchQuery.isNotEmpty ? 1 : 0),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (searchQuery.isNotEmpty && index == 0) {
                                return BouncingWrapper(
                                  onTap: () {
                                    setState(() {
                                      _nameController.text = searchQuery;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    padding: EdgeInsets.all(16.r),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C5990).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: const Color(0xFF2C5990).withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_circle_outline, color: const Color(0xFF2C5990), size: 20.sp),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            StringUtils.translate('use_query', namedArgs: {'query': searchQuery}, context: context),
                                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2C5990)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final item = filteredItems[searchQuery.isNotEmpty ? index - 1 : index];
                              return BouncingWrapper(
                                onTap: () {
                                  setState(() {
                                    _nameController.text = item.name;
                                    if (_categories.contains(item.category)) {
                                      _selectedCategory = item.category;
                                    }
                                    if (_units.contains(item.unit)) {
                                      _selectedUnit = item.unit;
                                    }
                                    if (item.pricePerUnit > 0 && _priceController.text == '0.0') {
                                      _priceController.text = item.pricePerUnit.toString();
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          StockConstants.getLocalizedNameForEntity(item, context.locale.languageCode),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1E293B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        StringUtils.translate(item.category.toLowerCase(), context: context),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockCubit, StockState>(
      listener: (context, state) {
        if (state is StockActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF10B981)));
          Navigator.pop(context);
        } else if (state is StockError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: const Color(0xFF1A1A1A), size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            StringUtils.translate('quick_entry', context: context),
            style: TextStyle(color: const Color(0xFF1A1A1A), fontSize: 20.sp, fontWeight: FontWeight.w900),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BouncingWrapper(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: const Color(0xFF2C5990), size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 20.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                _buildLabel(StringUtils.translate('item_name_label', context: context)),
                BouncingWrapper(
                  onTap: () => _showStockItemSelectionSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _nameController.text.isEmpty ? StringUtils.translate('search_placeholder', context: context) : StockConstants.getLocalizedNameForString(_nameController.text, context.locale.languageCode),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: _nameController.text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(StringUtils.translate('category_label', context: context)),
                          _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!)),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(StringUtils.translate('unit_label', context: context)),
                          _buildDropdown(_selectedUnit, _units, (val) => setState(() => _selectedUnit = val!)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(StringUtils.translate('quantity_label', context: context)),
                          _buildTextField(_quantityController, '1', keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(StringUtils.translate('price_unit_label', context: context)),
                          _buildTextField(_priceController, '0.0', keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                _buildLabel(StringUtils.translate('total_amount_label', context: context)),
                _buildTextField(_totalController, '0.0', keyboardType: TextInputType.number),
                SizedBox(height: 24.h),

                _buildLabel(StringUtils.translate('payment_mode_label', context: context)),
                Row(
                  children: _paymentModes.map((mode) {
                    final isSelected = _selectedPaymentMode == mode;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: BouncingWrapper(
                          onTap: () => setState(() => _selectedPaymentMode = mode),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2C5990) : Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: isSelected ? const Color(0xFF2C5990) : const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Text(
                                StringUtils.translate(mode.toLowerCase().replaceAll(' ', '_'), context: context),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),

                _buildLabel(StringUtils.translate('notes_optional_label', context: context)),
                _buildTextField(_notesController, StringUtils.translate('add_note_hint', context: context)),
                
                SizedBox(height: 48.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF4B5563)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        validator: (value) {
          if (controller == _notesController || controller == _priceController || controller == _totalController) return null;
          return value == null || value.isEmpty ? 'Required' : null;
        },
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(StringUtils.translate(e.toLowerCase().replaceAll(' ', '_'), context: context)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BouncingWrapper(
      onTap: () {
        if (_formKey.currentState!.validate() && _nameController.text.isNotEmpty) {
          context.read<StockCubit>().addTransaction(
            propertyId: widget.propertyId,
            itemName: _nameController.text,
            category: _selectedCategory,
            unit: _selectedUnit,
            quantity: double.tryParse(_quantityController.text) ?? 1,
            totalAmount: double.tryParse(_totalController.text) ?? 0,
            paymentMode: _selectedPaymentMode,
            notes: _notesController.text,
          );
        } else if (_nameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(StringUtils.translate('select_item_error', context: context)), backgroundColor: Colors.redAccent));
        }
      },
      child: Container(
        height: 56.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2C5990),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2C5990).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Text(
            StringUtils.translate('save_entry', context: context),
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
