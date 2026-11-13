import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../providers/customer_providers.dart';

class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final customer = await ref.read(customerListProvider.notifier).addCustomer(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            address: _addressController.text.trim(),
            gstin: '',
          );

      if (mounted) {
        Navigator.pop(context, customer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${customer.name}" created successfully'),
            backgroundColor: AppColors.received,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add customer: $e'),
            backgroundColor: AppColors.outstanding,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add New Customer', style: AppTextStyles.h3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Name
                Text('Customer / Business Name *', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Apex Logistics',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                ),
                SizedBox(height: 12.h),

                // Phone
                Text('Phone Number *', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                ),
                SizedBox(height: 12.h),

                // Email
                Text('Email Address (Optional)', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'accounts@company.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 12.h),

                // Address
                Text('Address / City', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Shop / Office, City, Pincode',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 20.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('Cancel', style: AppTextStyles.bodyMedium),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save Customer', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
