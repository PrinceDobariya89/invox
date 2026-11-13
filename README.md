# Invox - Fast, Lightweight Invoicing & Cashflow Analytics

Invox is a production-grade, clean-architecture business mobile and web application built with Flutter 3.x and Dart. It is strictly engineered for SME and B2B owners to manage **Customers & Ledgers**, generate **GST/Tax Invoices**, track **Payment Collections**, and visualize **Cashflow Analytics** without the bloat of generic ERPs.

---

## 🚀 Key Modules & Capabilities

1. **Financial Analytics & Cashflow Dashboard (`features/analytics`)**:
   - **KPI Metric Summary Cards**: Real-time cards for Billed (Blue), Received (Emerald), Outstanding (Crimson), and Overdue (Dark Red) with collection efficiency % indicator.
   - **Month-wise Cashflow Bar Chart (`fl_chart`)**: Interactive comparison of Billed Sales vs Received Collections with horizontal month picker.
   - **12-Month Annual Trends (`fl_chart`)**: Dual-line trend chart tracking billing vs collection curves across the fiscal year.
   - **Receivables Aging Report**: Categorized into 0–30 days (Current), 31–60 days (Moderate Risk), and 60+ days (High Risk) with proportional progress indicators.
   - **Export Engine**:
     - One-click **Excel (.xlsx)** export containing Executive Summary, Monthly Cashflow, and Aging sheets (`excel`).
     - Executive **Financial Report PDF** generation and print/share support (`pdf` & `printing`).

2. **Invoice Generation & Real-Time PDF Builder (`features/invoices`)**:
   - Dynamic line items editor with dynamic Add/Remove row.
   - Real-time calculation of item taxable amounts, discount %, GST/Tax %, Subtotal, and Grand Total.
   - Full vector **Tax Invoice PDF Generator** adhering to Indian SME standards (GSTIN, line item table, tax breakdown, bank NEFT/RTGS & UPI details, authorized signatory).
   - In-app **PDF Viewer** (`PdfPreview`), direct system thermal/A4 printing (`Printing.layoutPdf`), and WhatsApp share with pre-formatted invoice text.

3. **Payment Collection & Auto-Status Updates (`features/payments`)**:
   - Rapid payment modal with quick chips ("Full Balance", "50%").
   - Multi-channel collection tracking: UPI, Bank Transfer (NEFT/RTGS), Cash, Cheque.
   - Automatically transitions invoice status (`UNPAID` ➔ `PARTIAL` ➔ `PAID`).
   - Instantly updates customer balance and dashboard analytics.

4. **Customer Ledger & Balances (`features/customers`)**:
   - Directory with live search by name, phone, or GSTIN.
   - Prominent **Outstanding Amount** status chips on each customer card.
   - Complete **Customer Ledger**: Chronological transaction timeline combining billed invoices and payment receipts with running balances.

---

## 🛠️ Technology Stack & Architecture

- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: `flutter_riverpod` (AsyncNotifierProvider, StateNotifier, StateProvider, FutureProvider)
- **Networking**: `dio` (with Bearer token injection, Mock API Interceptor, and unified `ApiException` handler)
- **Navigation**: `go_router` (with authentication guards and `StatefulShellRoute.indexedStack` bottom navigation)
- **Typography & UI Scaling**: `flutter_screenutil` (responsive design for 375x812 base) and `google_fonts` (Poppins)
- **Visual Analytics**: `fl_chart`
- **Document / Export**: `pdf`, `printing`, `excel`
- **Local Storage**: `shared_preferences`

---

## 📂 Project Directory Structure

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart           # Dio instance, interceptors, error wrappers
│   │   ├── api_endpoints.dart        # Centralized REST API endpoints contract
│   │   ├── api_exception.dart        # Strongly-typed error parsing
│   │   ├── api_provider.dart         # Riverpod client provider
│   │   └── mock_api_interceptor.dart # In-memory mock server & demo data fallback
│   ├── constants/
│   │   ├── app_colors.dart           # Emerald, Crimson, Indigo, Slate palette
│   │   └── app_text_styles.dart      # Poppins typography scale with ScreenUtil
│   ├── routes/
│   │   └── app_router.dart           # GoRouter config with auth redirect & shells
│   └── utils/
│       ├── currency_formatter.dart   # INR (₹) formatting (Standard, Compact, Short)
│       └── date_formatter.dart       # Display, short, ISO formatters & overdue helper
├── features/
│   ├── analytics/
│   │   ├── data/analytics_repository.dart
│   │   ├── export/
│   │   │   ├── excel_export_service.dart
│   │   │   └── financial_report_pdf_builder.dart
│   │   ├── models/
│   │   │   ├── aging_report_model.dart
│   │   │   ├── analytics_summary_model.dart
│   │   │   ├── monthly_analytics_model.dart
│   │   │   └── yearly_analytics_model.dart
│   │   ├── presentation/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── aging_distribution_widget.dart
│   │   │       ├── kpi_summary_card.dart
│   │   │       ├── monthly_cashflow_chart.dart
│   │   │       └── yearly_trend_chart.dart
│   │   └── providers/analytics_providers.dart
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── models/user_model.dart
│   │   ├── presentation/login_page.dart
│   │   └── providers/auth_provider.dart
│   ├── customers/
│   │   ├── data/customer_repository.dart
│   │   ├── models/
│   │   │   ├── customer_detail_model.dart
│   │   │   └── customer_model.dart
│   │   ├── presentation/
│   │   │   ├── customer_detail_screen.dart
│   │   │   ├── customer_list_screen.dart
│   │   │   └── widgets/add_customer_dialog.dart
│   │   └── providers/customer_providers.dart
│   ├── invoices/
│   │   ├── data/invoice_repository.dart
│   │   ├── models/
│   │   │   ├── invoice_item_model.dart
│   │   │   └── invoice_model.dart
│   │   ├── pdf/invoice_pdf_builder.dart
│   │   ├── presentation/
│   │   │   ├── invoice_create_screen.dart
│   │   │   ├── invoice_detail_screen.dart
│   │   │   └── invoice_list_screen.dart
│   │   └── providers/invoice_providers.dart
│   ├── navigation/
│   │   └── main_navigation_shell.dart
│   └── payments/
│       ├── data/payment_repository.dart
│       ├── models/payment_model.dart
│       ├── presentation/payment_collection_dialog.dart
│       └── providers/payment_providers.dart
└── main.dart
```

---

## 🔌 REST API Endpoints Contract

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/login` | Returns JWT token & user profile |
| `GET` | `/api/customers` | Query: `search`, `page`. Returns customer list |
| `POST` | `/api/customers` | Body: `{ name, phone, address, gstin, email }` |
| `GET` | `/api/customers/{id}` | Returns customer profile + financial totals + ledger timeline |
| `GET` | `/api/invoices` | Query: `customer_id`, `status`, `month`, `year`, `page` |
| `POST` | `/api/invoices` | Body: `{ customer_id, invoice_number, date, due_date, items, notes }` |
| `GET` | `/api/invoices/{id}` | Full invoice details & item breakdown |
| `POST` | `/api/payments` | Body: `{ invoice_id, customer_id, amount, payment_mode, reference_no, payment_date }` |
| `GET` | `/api/payments?invoice_id={id}` | Payment receipts list for an invoice |
| `GET` | `/api/analytics/summary` | `{ total_billed, total_collected, total_outstanding, overdue_amount }` |
| `GET` | `/api/analytics/monthly` | Query: `year`, `month`. Monthly breakdown |
| `GET` | `/api/analytics/yearly` | Query: `year`. 12-month trend array for charts |
| `GET` | `/api/analytics/aging` | Aging report `{ bucket_0_30, bucket_31_60, bucket_60_plus }` |

> **Mock Mode & Standalone Execution**:
> The `ApiClient` incorporates a seamless in-memory `MockApiInterceptor` pre-populated with realistic Indian B2B customer accounts, invoices, payments, and 12-month analytics. Creating an invoice, recording a payment, or adding a customer immediately reflects across ledgers, charts, and summary cards. When connected to a live server, it communicates with the configured REST backend.

---

## 🧪 Testing & Verification

Run the test suite:
```bash
flutter test
```

Run code analysis:
```bash
flutter analyze
```
All unit tests for financial calculations, invoice item taxes/discounts, and INR formatting execute cleanly.
