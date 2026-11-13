import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/presentation/widgets/add_customer_dialog.dart';
import '../../customers/providers/customer_providers.dart';
import '../providers/invoice_providers.dart';

class _LineItemInput {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController rateController = TextEditingController(text: '0');
  final TextEditingController discountController = TextEditingController(text: '0');

  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    rateController.dispose();
    discountController.dispose();
  }

  double get qty => double.tryParse(qtyController.text) ?? 1.0;
  double get rate => double.tryParse(rateController.text) ?? 0.0;
  double get discountPercent => double.tryParse(discountController.text) ?? 0.0;

  double get lineBase => qty * rate;
  double get lineDiscount => lineBase * (discountPercent / 100);
  double get lineTotal => lineBase - lineDiscount;
}

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  final String? initialCustomerId;

  const InvoiceCreateScreen({super.key, this.initialCustomerId});

  @override
  ConsumerState<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  late final TextEditingController _invoiceNoController;
  final _notesController = TextEditingController(
      text: 'Payment due within 15 days. Thank you for your business.');

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 15));

  final List<_LineItemInput> _items = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _invoiceNoController = TextEditingController(
      text: 'INV-2026-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
    );

    _addItem();
  }

  void _addItem() {
    final item = _LineItemInput();
    item.descriptionController.addListener(() => setState(() {}));
    item.qtyController.addListener(() => setState(() {}));
    item.rateController.addListener(() => setState(() {}));
    item.discountController.addListener(() => setState(() {}));
    setState(() {
      _items.add(item);
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item is required in a bill.')),
      );
      return;
    }
    setState(() {
      final item = _items.removeAt(index);
      item.dispose();
    });
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _invoiceNoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0.0, (sum, i) => sum + i.lineBase);
  double get _totalDiscount => _items.fold(0.0, (sum, i) => sum + i.lineDiscount);
  double get _grandTotal => _subtotal - _totalDiscount;

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer for this bill')),
      );
      return;
    }

    final itemsPayload = _items.map((i) {
      return {
        'description': i.descriptionController.text.trim(),
        'qty': i.qty,
        'rate': i.rate,
        'discount': i.discountPercent,
        'tax': 0.0,
      };
    }).toList();

    setState(() => _isSaving = true);
    try {
      final createdInvoice = await ref.read(invoiceListProvider.notifier).createInvoice(
            customerId: _selectedCustomerId!,
            invoiceNumber: _invoiceNoController.text.trim(),
            date: DateFormatter.toIso(_invoiceDate),
            dueDate: DateFormatter.toIso(_dueDate),
            notes: _notesController.text.trim(),
            items: itemsPayload,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill ${createdInvoice.invoiceNumber} created successfully!'),
            backgroundColor: AppColors.received,
          ),
        );
        context.pushReplacement('/invoices/${createdInvoice.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create bill: $e'),
            backgroundColor: AppColors.outstanding,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Bill / Invoice', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Amount', style: AppTextStyles.caption),
                      Text(
                        CurrencyFormatter.format(_grandTotal),
                        style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveInvoice,
                    icon: _isSaving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save & Generate Bill',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ],
              ),
            ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 1360,
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.w),
          child: Form(
            key: _formKey,
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Bill details & Financial Summary
                      SizedBox(
                        width: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBillDetailsCard(customersAsync),
                            const SizedBox(height: 16),
                            _buildNotesCard(),
                            const SizedBox(height: 16),
                            _buildSummaryCard(showSaveButton: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column: Line items table & quick add
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLineItemsCard(isDesktop: true),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBillDetailsCard(customersAsync),
                      SizedBox(height: 16.h),
                      _buildLineItemsCard(isDesktop: false),
                      SizedBox(height: 16.h),
                      _buildSummaryCard(showSaveButton: false),
                      SizedBox(height: 16.h),
                      _buildNotesCard(),
                      SizedBox(height: 30.h),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard(AsyncValue<List<Customer>> customersAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bill Details', style: AppTextStyles.h3),
              TextButton.icon(
                onPressed: () async {
                  final newCust = await showDialog<Customer>(
                    context: context,
                    builder: (_) => const AddCustomerDialog(),
                  );
                  if (newCust != null && mounted) {
                    setState(() => _selectedCustomerId = newCust.id);
                  }
                },
                icon: const Icon(Icons.person_add_alt, size: 16),
                label: const Text('New'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer Selection Dropdown
          Text('Customer *', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 6),
          customersAsync.when(
            data: (customers) {
              final validInitial = _selectedCustomerId != null &&
                      customers.any((c) => c.id == _selectedCustomerId)
                  ? _selectedCustomerId
                  : (customers.isNotEmpty ? customers.first.id : null);

              return DropdownButtonFormField<String>(
                initialValue: validInitial,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select Customer',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: customers.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(
                      '${c.name} (${CurrencyFormatter.formatCompact(c.outstandingBalance)} due)',
                      style: AppTextStyles.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedCustomerId = val);
                },
                validator: (v) => v == null ? 'Please select a customer' : null,
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text('Error loading customers: $err'),
          ),
          const SizedBox(height: 14),

          // Invoice Number
          Text('Bill / Invoice Number *', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 6),
          TextFormField(
            controller: _invoiceNoController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter invoice number' : null,
          ),
          const SizedBox(height: 14),

          // Date & Due Date Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill Date', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _invoiceDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (p != null) setState(() => _invoiceDate = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormatter.toShort(_invoiceDate),
                                style: AppTextStyles.bodyMedium),
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due Date', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (p != null) setState(() => _dueDate = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormatter.toShort(_dueDate),
                                style: AppTextStyles.bodyMedium),
                            const Icon(Icons.event_outlined,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsCard({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line Items (${_items.length})', style: AppTextStyles.h3),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Item'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (isDesktop) ...[
            // Desktop Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 5, child: Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 10),
                  Expanded(flex: 2, child: Text('QTY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 10),
                  Expanded(flex: 3, child: Text('RATE (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 10),
                  Expanded(flex: 2, child: Text('DISC %', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 10),
                  Expanded(flex: 3, child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                  SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Desktop Table Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: item.descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Item / Product description',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Item name required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: item.qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: item.rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: item.discountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          CurrencyFormatter.format(item.lineTotal),
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.outstanding),
                        onPressed: () => _removeItem(index),
                        tooltip: 'Remove Item',
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            // Mobile Stacked Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: item.descriptionController,
                              decoration: InputDecoration(
                                hintText: 'Item / Product description',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Item name required' : null,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.outstanding),
                            onPressed: () => _removeItem(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Qty', style: AppTextStyles.caption),
                                SizedBox(height: 4.h),
                                TextFormField(
                                  controller: item.qtyController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rate (₹)', style: AppTextStyles.caption),
                                SizedBox(height: 4.h),
                                TextFormField(
                                  controller: item.rateController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Discount %', style: AppTextStyles.caption),
                                SizedBox(height: 4.h),
                                TextFormField(
                                  controller: item.discountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Line Total: ', style: AppTextStyles.caption),
                          Text(
                            CurrencyFormatter.format(item.lineTotal),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required bool showSaveButton}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', amount: CurrencyFormatter.formatCompact(_subtotal)),
          if (_totalDiscount > 0) ...[
            const SizedBox(height: 8),
            _TotalRow(
              label: 'Discount',
              amount: '- ${CurrencyFormatter.formatCompact(_totalDiscount)}',
              isNegative: true,
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyles.h3),
              Text(
                CurrencyFormatter.format(_grandTotal),
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (showSaveButton) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveInvoice,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save & Generate Bill',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes & Terms', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add payment instructions or notes for the customer...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isNegative;

  const _TotalRow({required this.label, required this.amount, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isNegative ? AppColors.received : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
