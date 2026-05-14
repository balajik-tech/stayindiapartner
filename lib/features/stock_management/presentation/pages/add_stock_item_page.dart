import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../data/models/stock_item_model.dart';

class AddStockItemPage extends StatefulWidget {
  final String propertyId;
  const AddStockItemPage({super.key, required this.propertyId});

  @override
  State<AddStockItemPage> createState() => _AddStockItemPageState();
}

class _AddStockItemPageState extends State<AddStockItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Food';
  String _selectedUnit = 'kg';

  final List<String> _categories = ['Food', 'Cleaning', 'Utilities', 'Misc'];
  final List<String> _units = ['kg', 'liters', 'pieces', 'packets', 'units'];

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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Add Stock Item',
            style: TextStyle(color: const Color(0xFF1A1A1A), fontSize: 20.sp, fontWeight: FontWeight.w900),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Item Name'),
                _buildTextField(_nameController, 'e.g. Basmati Rice'),
                SizedBox(height: 24.h),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Category'),
                          _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!)),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Unit'),
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
                          _buildLabel('Initial Quantity'),
                          _buildTextField(_quantityController, '0.0', keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Min. Threshold'),
                          _buildTextField(_thresholdController, '5.0', keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                _buildLabel('Price per Unit (₹)'),
                _buildTextField(_priceController, '0.0', keyboardType: TextInputType.number),
                
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
        color: const Color(0xFFF8FAFC),
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
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BouncingWrapper(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          final item = StockItemModel(
            id: '',
            propertyId: widget.propertyId,
            name: _nameController.text,
            category: _selectedCategory,
            unit: _selectedUnit,
            currentQuantity: double.tryParse(_quantityController.text) ?? 0,
            minimumThreshold: double.tryParse(_thresholdController.text) ?? 5,
            pricePerUnit: double.tryParse(_priceController.text) ?? 0,
            createdBy: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          context.read<StockCubit>().createItem(item);
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
            'Save Item',
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
