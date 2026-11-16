import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../payments/presentation/payment_collection_dialog.dart';
import '../../payments/providers/payment_providers.dart';
import '../models/invoice_model.dart';
import '../pdf/invoice_pdf_builder.dart';
import '../providers/invoice_providers.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareViaWhatsApp(Invoice invoice) async {
    final pdfBytes = await InvoicePdfBuilder.buildPdf(invoice);
    final message = '''
Dear ${invoice.customerName},
Please find attached Invoice *${invoice.invoiceNumber}* for *${CurrencyFormatter.format(invoice.totalAmount)}*.
Due Date: ${DateFormatter.toDisplay(DateTime.tryParse(invoice.dueDate))}
Pending Balance: *${CurrencyFormatter.format(invoice.balanceAmount)}*

Payment Options:
UPI ID: invox@hdfcbank
Bank: HDFC Bank | A/C: 50200012345678 | IFSC: HDFC0001234

Thank you for your business!
- Invox
''';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${invoice.invoiceNumber}.pdf',
      subject: 'Invoice ${invoice.invoiceNumber}',
      body: message,
    );
  }

  Future<void> _openCollectPayment(Invoice invoice) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => PaymentCollectionDialog(
        invoiceId: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        dueAmount: invoice.balanceAmount,
      ),
    );
    if (res == true) {
      ref.invalidate(invoiceDetailProvider(widget.invoiceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));
    final paymentsAsync =
        ref.watch(paymentsByInvoiceProvider(widget.invoiceId));
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Invoice Preview', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          invoiceAsync.when(
            data: (invoice) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: AppColors.primary),
                  tooltip: 'Share WhatsApp / Email',
                  onPressed: () => _shareViaWhatsApp(invoice),
                ),
                IconButton(
                  icon: const Icon(Icons.print_outlined,
                      color: AppColors.textPrimary),
                  tooltip: 'Print Invoice',
                  onPressed: () async {
                    final bytes = await InvoicePdfBuilder.buildPdf(invoice);
                    await Printing.layoutPdf(
                      onLayout: (_) => bytes,
                      name: invoice.invoiceNumber,
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
        bottom: isWide
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(
                      icon: Icon(Icons.picture_as_pdf_outlined),
                      text: 'PDF Document'),
                  Tab(
                      icon: Icon(Icons.receipt_outlined),
                      text: 'Details & Payments'),
                ],
              ),
      ),
      bottomNavigationBar: (!isWide)
          ? invoiceAsync.maybeWhen(
              data: (invoice) {
                if (invoice.balanceAmount <= 0) return const SizedBox.shrink();

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Balance Due', style: AppTextStyles.caption),
                          Text(
                            CurrencyFormatter.format(invoice.balanceAmount),
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.outstanding),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _openCollectPayment(invoice),
                        icon: const Icon(Icons.payments_outlined,
                            color: Colors.white, size: 18),
                        label: Text('Collect Payment',
                            style: AppTextStyles.button),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.received,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            )
          : null,
      body: invoiceAsync.when(
        data: (invoice) {
          if (isWide) {
            // Wide Desktop / Web Split Screen: Left (Details & Ledger), Right (Live PDF Preview)
            return ResponsiveCenter(
              maxWidth: 1600,
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel: Details, Items, Payments & Collect Payment Action
                  SizedBox(
                    width: 480,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInvoiceStatusCard(invoice),
                          const SizedBox(height: 16),
                          _buildLineItemsCard(invoice),
                          const SizedBox(height: 16),
                          _buildPaymentsCard(paymentsAsync),
                          if (invoice.balanceAmount > 0) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _openCollectPayment(invoice),
                                icon: const Icon(Icons.payments_outlined,
                                    color: Colors.white, size: 20),
                                label: Text(
                                  'Collect Payment (${CurrencyFormatter.format(invoice.balanceAmount)})',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.received,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right Panel: Live PDF Document Preview
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PdfPreview(
                        build: (format) => InvoicePdfBuilder.buildPdf(invoice),
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        allowSharing: true,
                        allowPrinting: true,
                        pdfFileName: '${invoice.invoiceNumber}.pdf',
                        previewPageMargin: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile / Tablet Tabbed View
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Live Interactive PDF Preview
              PdfPreview(
                build: (format) => InvoicePdfBuilder.buildPdf(invoice),
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                allowSharing: true,
                allowPrinting: true,
                pdfFileName: '${invoice.invoiceNumber}.pdf',
                previewPageMargin: EdgeInsets.all(12.w),
              ),

              // Tab 2: Detailed Line Items & Payments
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInvoiceStatusCard(invoice),
                    SizedBox(height: 16.h),
                    _buildLineItemsCard(invoice),
                    SizedBox(height: 16.h),
                    _buildPaymentsCard(paymentsAsync),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading invoice: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(invoiceDetailProvider(widget.invoiceId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceStatusCard(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(invoice.invoiceNumber, style: AppTextStyles.h2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: invoice.status == 'PAID'
                      ? AppColors.receivedLight
                      : (invoice.status == 'PARTIAL'
                          ? AppColors.partialLight
                          : AppColors.outstandingLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invoice.status,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: invoice.status == 'PAID'
                        ? AppColors.received
                        : (invoice.status == 'PARTIAL'
                            ? AppColors.partial
                            : AppColors.outstanding),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Billed to: ${invoice.customerName}',
              style: AppTextStyles.bodyLarge),
          const SizedBox(height: 4),
          Text(
            'Issue Date: ${DateFormatter.toDisplay(DateTime.tryParse(invoice.date))} • Due Date: ${DateFormatter.toDisplay(DateTime.tryParse(invoice.dueDate))}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsCard(Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items (${invoice.items.length})', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.description, style: AppTextStyles.bodyMedium),
                        Text(
                          '${item.qty.toStringAsFixed(0)} x ${CurrencyFormatter.formatCompact(item.rate)}${item.discount > 0 ? " • Disc ${item.discount.toStringAsFixed(0)}%" : ""}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.amount),
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Invoiced', style: AppTextStyles.h3),
              Text(
                CurrencyFormatter.format(invoice.totalAmount),
                style: AppTextStyles.h2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsCard(AsyncValue<List<dynamic>> paymentsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Receipts', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          paymentsAsync.when(
            data: (payments) {
              if (payments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No payments recorded yet.',
                      style: AppTextStyles.bodySmall),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, idx) {
                  final p = payments[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.paymentMode} • ${p.referenceNo}',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              DateFormatter.toDisplay(
                                  DateTime.tryParse(p.paymentDate)),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(p.amount),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.received,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error loading payments: $e'),
          ),
        ],
      ),
    );
  }
}
