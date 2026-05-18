import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../core/stock_constants.dart';
import '../../data/models/stock_item_model.dart';

class QuickAddTransactionPage extends StatefulWidget {
  final String propertyId;
  const QuickAddTransactionPage({super.key, required this.propertyId});

  @override
  State<QuickAddTransactionPage> createState() =>
      _QuickAddTransactionPageState();
}

class _QuickAddTransactionPageState extends State<QuickAddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _totalController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Grocery';
  String _selectedUnit = 'kg';
  String _selectedPaymentMode = 'Cash';
  String? _selectedTeluguName;

  final List<String> _categories = [
    'Grocery',
    'Perishables',
    'Utilities',
    'Maintenance',
    'Staff',
    'Misc',
  ];
  final List<String> _units = ['kg', 'liters', 'pieces', 'packets', 'units'];
  final List<String> _paymentModes = ['UPI', 'Cash', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (qty > 0 && price > 0) {
      _totalController.text = (qty * price).toStringAsFixed(2);
    }
  }

  void _onItemSearch(String query) {
    final allItems = StockConstants.getAllItems();
    final langCode = context.locale.languageCode;
    final match = allItems.firstWhere((item) {
      final name = item['name']!.toLowerCase();
      final nameTe = item['nameTelugu']?.toLowerCase() ?? '';
      final nameHi = item['nameHindi']?.toLowerCase() ?? '';
      final nameTa = item['nameTamil']?.toLowerCase() ?? '';
      final nameKn = item['nameKannada']?.toLowerCase() ?? '';
      final q = query.toLowerCase();
      return name == q ||
          nameTe == q ||
          nameHi == q ||
          nameTa == q ||
          nameKn == q ||
          StockConstants.getLocalizedName(item, langCode).toLowerCase() == q;
    }, orElse: () => {});

    if (match.isNotEmpty) {
      setState(() {
        _selectedCategory = match['category']!;
        _selectedUnit = match['unit']!;
        _selectedTeluguName = langCode == 'en'
            ? null
            : StockConstants.getLocalizedName(match, langCode);
        if (_nameController.text != match['name']) {
          _nameController.text = match['name']!;
        }
      });
    } else {
      setState(() {
        _selectedTeluguName = null;
      });
    }

    final existingItems = context.read<StockCubit>().state.items;
    final existingMatch = existingItems.firstWhere(
      (item) {
        final name = item.name.toLowerCase();
        final q = query.toLowerCase();
        return name == q ||
            (item.nameTelugu != null && item.nameTelugu!.toLowerCase() == q);
      },
      orElse: () => StockItemModel(
        id: '',
        propertyId: '',
        name: '',
        category: '',
        unit: '',
        currentQuantity: 0,
        minimumThreshold: 0,
        pricePerUnit: 0,
        createdBy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingMatch.id.isNotEmpty) {
      if (_priceController.text.isEmpty) {
        _priceController.text = existingMatch.pricePerUnit.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockCubit, StockState>(
      listener: (context, state) {
        if (state is StockActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        } else if (state is StockError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Quick Entry',
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(),
                SizedBox(height: 24.h),

                _buildLabel('Item Name'),
                _buildAutocompleteField(),
                if (_selectedTeluguName != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 4.w),
                    child: Text(
                      _selectedTeluguName!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
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
                          _buildLabel('Category'),
                          _buildDropdown(
                            _selectedCategory,
                            _categories,
                            (val) => setState(() => _selectedCategory = val!),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Unit'),
                          _buildDropdown(
                            _selectedUnit,
                            _units,
                            (val) => setState(() => _selectedUnit = val!),
                          ),
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
                          _buildLabel('Quantity'),
                          _buildTextField(
                            _quantityController,
                            '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price/Unit (₹)'),
                          _buildTextField(
                            _priceController,
                            '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                _buildLabel('Total Amount (₹)'),
                _buildTextField(
                  _totalController,
                  '0.0',
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
                SizedBox(height: 24.h),

                _buildLabel('Payment Mode'),
                _buildPaymentModeSelector(),
                SizedBox(height: 24.h),

                _buildLabel('Notes (Optional)'),
                _buildTextField(
                  _noteController,
                  'Add a note...',
                  isOptional: true,
                ),

                SizedBox(height: 48.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return BouncingWrapper(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF2C5990),
              size: 20,
            ),
            SizedBox(width: 12.w),
            Text(
              DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField() {
    final allItems = StockConstants.getAllItems();
    final langCode = context.locale.languageCode;

    final currentValue =
        _nameController.text.isNotEmpty &&
            allItems.any((item) => item['name'] == _nameController.text)
        ? _nameController.text
        : null;

    return FormField<String>(
      initialValue: currentValue,
      validator: (value) => _nameController.text.isEmpty ? 'Required' : null,
      builder: (state) {
        final hasError = state.hasError;
        final selectedItemName = _nameController.text.isNotEmpty
            ? (() {
                final matched = allItems.firstWhere(
                  (item) => item['name'] == _nameController.text,
                  orElse: () => {},
                );
                return matched.isNotEmpty
                    ? StockConstants.getLocalizedName(matched, langCode)
                    : _nameController.text;
              })()
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showSearchableBottomSheet(context, state),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: hasError
                        ? Colors.red.shade400
                        : const Color(0xFFE2E8F0),
                    width: hasError ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedItemName ?? 'Select Stock Item...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: selectedItemName != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selectedItemName != null
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: hasError
                          ? Colors.red.shade400
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  state.errorText ?? 'Required',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showSearchableBottomSheet(
    BuildContext context,
    FormFieldState<String> formState,
  ) {
    final allItems = StockConstants.getAllItems();
    final langCode = context.locale.languageCode;
    final searchController = TextEditingController();
    String searchVal = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredItems = allItems.where((item) {
              final name = item['name']!.toLowerCase();
              final nameTe = item['nameTelugu']?.toLowerCase() ?? '';
              final nameHi = item['nameHindi']?.toLowerCase() ?? '';
              final nameTa = item['nameTamil']?.toLowerCase() ?? '';
              final nameKn = item['nameKannada']?.toLowerCase() ?? '';
              final q = searchVal.toLowerCase();

              return name.contains(q) ||
                  nameTe.contains(q) ||
                  nameHi.contains(q) ||
                  nameTa.contains(q) ||
                  nameKn.contains(q) ||
                  StockConstants.getLocalizedName(
                    item,
                    langCode,
                  ).toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setSheetState(() {
                            searchVal = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return ListTile(
                            title: Text(
                              StockConstants.getLocalizedName(item, langCode),
                            ),
                            onTap: () {
                              _nameController.text = item['name']!;
                              _onItemSearch(item['name']!);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool readOnly = false,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: isOptional
          ? null
          : (val) => val == null || val.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildPaymentModeSelector() {
    return Wrap(
      spacing: 12.w,
      children: _paymentModes.map((mode) {
        final isSelected = _selectedPaymentMode == mode;
        return ChoiceChip(
          label: Text(mode),
          selected: isSelected,
          onSelected: (val) {
            if (val) setState(() => _selectedPaymentMode = mode);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final qty = double.tryParse(_quantityController.text) ?? 0;
            final total = double.tryParse(_totalController.text) ?? 0;

            context.read<StockCubit>().addTransaction(
              propertyId: widget.propertyId,
              itemName: _nameController.text,
              category: _selectedCategory,
              unit: _selectedUnit,
              quantity: qty,
              totalAmount: total,
              paymentMode: _selectedPaymentMode,
              notes: _noteController.text,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: const Color(0xFF2C5990),
        ),
        child: Text(
          'Submit Entry',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
