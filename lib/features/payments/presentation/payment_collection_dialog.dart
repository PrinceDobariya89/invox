import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/payment_providers.dart';

class PaymentCollectionDialog extends ConsumerStatefulWidget {
  final String? invoiceId;
  final String? invoiceNumber;
  final String customerId;
  final String customerName;
  final double dueAmount;

  const PaymentCollectionDialog({
    super.key,
    this.invoiceId,
    this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.dueAmount,
  });

  @override
  ConsumerState<PaymentCollectionDialog> createState() => _PaymentCollectionDialogState();
}

class _PaymentCollectionDialogState extends ConsumerState<PaymentCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _refNoController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMode = 'UPI';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _modes = ['UPI', 'Bank Transfer', 'Cash', 'Cheque'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.dueAmount > 0 ? widget.dueAmount.toStringAsFixed(2) : '',
    );
    _refNoController.text = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refNoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount must be greater than zero')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(paymentNotifierProvider.notifier).recordPayment(
            invoiceId: widget.invoiceId ?? 'inv_general',
            customerId: widget.customerId,
            amount: amount,
            paymentMode: _paymentMode,
            referenceNo: _refNoController.text.trim(),
            paymentDate: DateFormatter.toIso(_paymentDate),
            notes: _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of ${CurrencyFormatter.format(amount)} recorded successfully!'),
            backgroundColor: AppColors.received,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: $e'),
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.receivedLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.payments_outlined, color: AppColors.received, size: 20.sp),
                        ),
                        SizedBox(width: 10.w),
                        Text('Record Payment', style: AppTextStyles.h3),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Customer & Balance Context Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.customerName, style: AppTextStyles.bodyLarge),
                            if (widget.invoiceNumber != null)
                              Text(
                                'Invoice: ${widget.invoiceNumber}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Due Amount', style: AppTextStyles.caption),
                          Text(
                            CurrencyFormatter.format(widget.dueAmount),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.outstanding,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Amount Input
                Text('Amount Received (₹) *', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.h2.copyWith(color: AppColors.received),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Text('₹', style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter amount';
                    final num = double.tryParse(v);
                    if (num == null || num <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
                SizedBox(height: 8.h),

                // Quick Amount Chips
                if (widget.dueAmount > 0)
                  Row(
                    children: [
                      ActionChip(
                        label: Text('Full Balance (${CurrencyFormatter.formatCompact(widget.dueAmount)})',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.primarySurface,
                        onPressed: () {
                          _amountController.text = widget.dueAmount.toStringAsFixed(2);
                        },
                      ),
                      SizedBox(width: 8.w),
                      ActionChip(
                        label: Text('50%', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.background,
                        onPressed: () {
                          _amountController.text = (widget.dueAmount * 0.5).toStringAsFixed(2);
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 14.h),

                // Payment Mode Selection
                Text('Payment Mode *', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8.w,
                  children: _modes.map((mode) {
                    final isSelected = _paymentMode == mode;
                    return ChoiceChip(
                      label: Text(mode),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _paymentMode = mode);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),

                // Reference / Txn No
                Text('Transaction / Ref / Cheque No.', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _refNoController,
                  decoration: InputDecoration(
                    hintText: 'e.g. UTR / UPI Ref / Cheque #',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 14.h),

                // Payment Date
                Text('Payment Date', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _paymentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => _paymentDate = picked);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormatter.toDisplay(_paymentDate), style: AppTextStyles.bodyMedium),
                        Icon(Icons.calendar_today_outlined, size: 18.sp, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Notes
                Text('Notes (Optional)', style: AppTextStyles.bodyMedium),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Cleared via GooglePay',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 22.h),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.received,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Record Payment', style: AppTextStyles.button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

