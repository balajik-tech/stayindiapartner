# Stay India Owner App - Major Functionalities & Core Changes (July 1st to Present)
### 4-Month Major Features & Architectural Milestones Report

---

## Executive Summary

This document focuses **exclusively on the major functionalities, core feature implementations, and key architectural changes** completed in the **Stay India Owner Application** over the last 4 months (July 1st to Present). All minor UI polish items, simple bug fixes, and minor text/label updates have been filtered out to highlight only the high-impact system capabilities.

---

## 1. Core Architecture & System Infrastructure

### 1.1 Clean Architecture & Cubit State Management Migration
* **Modular Code Structure:** Re-architected code from monolithic directories into feature-first modules (`features/auth`, `features/bookings`, `features/dashboard`, `features/tenants`, `features/payments`, `features/electricity_bills`, `features/finance`, `features/communities`, `features/bank_account`, `features/profile`).
* **Cubit State Management:** Replaced legacy BLoC implementations with lightweight feature Cubits (`DashboardCubit`, `TenantCubit`, `BookingsCubit`, `FinanceCubit`, `HostelCubit`, `CommunityCubit`, `RazorpayCubit`).
* **Modular Dependency Injection:** Decentralized dependency injection into modular bindings (e.g. `auth_injections.dart`, `profile_injections.dart`) registered via `injection_container.dart`.

### 1.2 Universal Deep Linking Framework (`share.stayindia.in`)
* **Deep Link Service:** Integrated `app_links` package with custom `DeepLinkService` (`lib/core/services/deep_link_service.dart`) to handle incoming referral links and route parameters directly to app screens.
* **Platform Manifest Configurations:** Configured Android `AndroidManifest.xml` intent filters and iOS `Runner.entitlements` / `Info.plist` associated domains for `share.stayindia.in`.
* **Domain Verification Assets:** Hosted and linked verification assets (`.well-known/apple-app-site-association` and `.well-known/assetlinks.json`).

### 1.3 Multi-Environment Build System & Flavor Configurations
* **Environment Configurations:** Created `config/env.dev.json` and `config/env.prod.json` defining base API endpoints, Socket servers, S3 hosts, and Razorpay keys.
* **Automated Build Scripts:** Created shell script `build_app.sh` for automated production and development APK/IPA compilation.

---

## 2. Authentication, Onboarding & Recovery Flow

### 2.1 DigiLocker & Automated eKYC Integration
* **DigiLocker Integration:** Built modular DigiLocker eKYC workflow with OAuth webview integration to fetch verified identity documents directly from government servers.
* **Identity State Machine:** Created `DocumentCubit` state handler for `Pending`, `Approved`, and `Rejected` verification statuses.

### 2.2 Account Recovery & Self-Service Account Management
* **Deactivated Account Restoration:** Developed account recovery modal on login for deactivated user accounts, executing backend restoration API calls.
* **Self-Service Account Controls:** Built self-service account deletion and account deactivation options within profile settings.

### 2.3 Geofence Intro Screen & Permission Setup
* **Location Setup Flow:** Designed geofencing intro screen and location permission request workflow prior to property configuration.

---

## 3. Property Setup & Hostel Configuration

### 3.1 Hostel Setup Wizard & Draft Recovery
* **Setup Wizard Stepper:** Redesigned `HostelConfigurationPage` supporting dashed property creation cards and multi-property management.
* **Property Media Upload:** Embedded property image upload step directly within the property setup stepper.
* **Resume Setup Drafts:** Added feature to automatically detect and resume incomplete property setup drafts.
* **Flexible Onboarding:** Allowed property creation without requiring mandatory upfront KYC verification.

### 3.2 Room & Sharing Configuration Rules
* **AC / Non-AC Toggles:** Added quick selection toggles for AC and Non-AC room categories.
* **Sharing Capacity & Pricing Rules:** Capped custom room sharing values to prevent overflow errors and fixed silent rewriting of bed pricing amounts.
* **Pricing Master Ceiling:** Defaulted tenant assignment pricing calculations to match Pricing Master rates when beds are occupied, and enforced a ₹50,000 price ceiling check for bulk price edits.

---

## 4. Dashboard & Bed Status Management

### 4.1 Real-Time Bed Occupancy Mapping
* **Occupancy Status Tracking:** Filtered room grids to display occupied beds and mapped status enums (`Booked`, `Reserved`, `Occupied`, `Away`) with visual status color chips.

### 4.2 Direct Room Change Navigation
* **Bed Click Action:** Modified bed click action on occupied bed cards to directly launch `RoomSelectionPage` instead of triggering intermediate modal sheets.

---

## 5. Tenant Management, Identity Verification & Bulk Upload

### 5.1 Identity Verification (DigiLocker, Aadhaar OCR & PAN Verification)
* **Camera/Gallery Aadhaar OCR:** Built OCR text recognition to parse tenant Aadhaar numbers and automatically split full names into first and last name fields.
* **Interactive Image Cropper:** Integrated `image_cropper` package for cropping front and back Aadhaar card photos.
* **PAN Card API Verification:** Added PAN card text input with real-time API verification calls and green "PAN Verified" checkmarks.

### 5.2 Standalone Bulk Tenant Upload Feature
* **Bulk Upload Page:** Created `AddBulkTenantPage` supporting multipart CSV/Excel document uploads.
* **Validation & Reset Engine:** Implemented row-by-row validation feedback and form reset capabilities.

### 5.3 Tenant Onboarding & Movement History Log
* **Validation Rules:** Defaulted check-in date selection to today, enforced Indian mobile number formatting (`+91` 10-digit check), and blocked owners from entering their own phone number as a tenant contact.
* **Emergency Contacts:** Added guardian mobile number, employee ID proof, and relation dropdown selector.
* **Compact History Log:** Redesigned `TenantHistoryPage` into a compact movement log layout detailing check-in, check-out dates, room numbers, and financial payment histories.

---

## 6. Rent Payments, Offline Billing & Checkout Settlement

### 6.1 Offline Payment Engine (Cash & UPI Direct Options)
* **Instant Offline Collection:** Created offline payment modal allowing owners to record Cash and UPI rent payments manually with reference IDs and payment timestamps.
* **Pro-Rata Rent Calculation:** Built date-wise daily pro-rata rent calculation engine for partial-month joiners.
* **Renewal Payment Workflow:** Integrated offline renewal payment flows to calculate next cycle due dates automatically upon collection.

### 6.2 Unified Checkout Settlement Engine (`CheckoutSettlementModal`)
* **Settlement Workflow:** Developed complete Checkout Settlement workflow (`CheckoutSettlementModal`) embedded into active booking cards.
* **Automated Calculations:** Automatically computes total unpaid rent, pending electricity bills, security deposit deductions, and balance refunds into a single transaction payload.

### 6.3 Digital PDF Invoice Generator
* **Invoice Export Service:** Built PDF generator service to compile formatted digital invoice receipts upon payment completion.

---

## 7. Electricity Bill Management

### 7.1 Electricity Bill Feature Launch
* **Dedicated Module:** Created complete `ElectricityBill` feature module under `lib/features/electricity_bills` with Cubit state management for creating, editing, sharing, and deleting bills per room.

### 7.2 Billing Validations & Checkout Integration
* **Duplicate Bill Prevention:** Enforced date validation checks preventing creation of duplicate bills within the same billing month.
* **WhatsApp Sharing & Checkout Integration:** Formatted WhatsApp text summary sharing for electricity bills and tied pending bills directly into the tenant checkout settlement slip.

---

## 8. Financial Analytics & Revenue Insights

### 8.1 Performance Insights Dashboard (`FinancialDashboardPage`)
* **Dashboard Page:** Built `FinancialDashboardPage` with custom sliver scaffold, dark blue gradient header, and multi-language support.
* **Metric Grid:** Displays 4 key metrics: Total Revenue, This Month Revenue, Occupancy Rate %, and Pending Payments.
* **Visual Charts:** Integrated daily revenue line trend chart (`RevenueChart`) and pie breakdown chart (`RevenueBreakdownChart`).
* **Tax Base Calculations:** Updated invoice calculation engine to handle GST tax exclusions and inclusions accurately.

---

## 9. Subscriptions & Razorpay Integration

### 9.1 Razorpay Payment Gateway Integration
* **SDK Integration:** Integrated Razorpay payment SDK with `RazorpayCubit` state handler.
* **Payment Flow:** Built `PaymentSuccessScreen` and `PaymentFailedScreen` with detailed transaction breakdowns and retry options.

### 9.2 Subscription Plan Design & Expiry Alerts
* **Tailored Hostel Plans:** Redesigned `SubscriptionPage` supporting hostel property plans with custom bed count tiers.
* **Validity Tracking:** Displayed active subscription validity dates with 7-day prior renewal alerts and lapsed state indicators.

---

## 10. Bank Account Management & Account Settings

### 10.1 Unified Account Settings & Penny-Drop Verification
* **Unified Screen:** Replaced standalone bank section with consolidated `AccountSettingsPage`.
* **Penny-Drop Verification:** Implemented backend API penny-drop verification checking account holder names and IFSC codes, displaying green "Verified" status badges.
* **Entity Classification:** Added entity classification selector (Individual vs Business/Proprietorship).

---

## 11. Association, PG Owners Forum & Community Chat

### 11.1 PG Owners Forum / Association Portal
* **Executive Portal:** Built `AssociationPortal` displaying Executive Committee members, IT Wing, and General Members.
* **Search & Property Requests:** Created association search page (`association_search_page.dart`) and property join request modal sheets.

### 11.2 Real-Time Community & Personal Chat Architecture
* **Isolated Routes:** Migrated chat routes to clean isolated `/community/chat` and `/chat/` sub-routes.
* **Doodle Wallpaper Background:** Integrated organic doodle wallpaper background for WhatsApp-style chat screens.
* **Timezone Offset Fix:** Converted server UTC timestamps to device local dates.

---

## 12. Service Requests, Notices & App Support

### 12.1 Raise a Service Request Feature
* **Service Request Workflow:** Implemented Service Request workflow (`Select Service Modal`, `My Requests Tracker Page`, `Request Sent Confirmation Screen`).

### 12.2 Notice Management & Referral
* **General & Vacate Notices:** Built dialog modals for issuing general hostel notices or initiating tenant vacate notices.
* **Enhanced Share App:** Enhanced `ShareAppBottomSheet` with custom copyable referral links (`share.stayindia.in`) and social sharing intent launchers.

---

## Summary Matrix of Major Functionalities

| # | Major Feature / Architectural Capability | Primary Module | Target Impact |
| :-: | :--- | :--- | :--- |
| **1** | Clean Architecture & Cubit State Management Migration | Core System | Modular codebase & faster state execution |
| **2** | Universal Deep Linking Framework (`share.stayindia.in`) | Core System | Referral tracking & direct screen launching |
| **3** | Multi-Environment Build Infrastructure & Flavors | Core System | Production vs Staging build separation |
| **4** | DigiLocker Automated eKYC Integration | Auth / Tenants | Official government identity verification |
| **5** | Account Restoration & Deactivation Workflow | Auth / Profile | Self-service account recovery & deletion |
| **6** | Property Setup Wizard & Resume Unfinished Drafts | Hostel Config | Smooth multi-property onboarding |
| **7** | Pricing Master & AC/Non-AC Room Rules | Hostel Config | Automated price calculations & caps |
| **8** | Real-Time Bed Occupancy Mapping & Room Change | Dashboard | Quick room switching & bed state visibility |
| **9** | Aadhaar Camera OCR with Cropping & PAN Check | Tenants | Instant identity data extraction & check |
| **10** | Standalone Bulk Tenant Upload Feature | Tenants | CSV/Excel multi-tenant upload |
| **11** | Offline Rent Payment Engine (Cash & UPI Direct) | Payments | Direct offline rent collection tracking |
| **12** | Unified Checkout Settlement Engine | Payments | Automatic rent, bill, deposit & refund slip |
| **13** | Digital PDF Invoice Generator | Payments | Auto-generated digital PDF receipts |
| **14** | Dedicated Electricity Bill Management Module | Electricity | Room-level electricity billing & WhatsApp share |
| **15** | Financial Analytics & Performance Dashboard | Finance | Daily revenue trends & income charts |
| **16** | Razorpay Payment SDK & Subscription Tiers | Subscriptions | Seamless plan renewal & expiry warnings |
| **17** | Penny-Drop Bank Account Verification API | Bank Account | Verified payout bank details validation |
| **18** | PG Owners Forum & Executive Directory | Community | Association networking & property requests |
| **19** | Real-Time Chat with WhatsApp Doodle Wallpaper | Community | High-performance real-time messaging |
| **20** | Raise a Service Request Workflow | Maintenance | Service request submission & tracking |
| **21** | Notice Broadcast & Vacate Notice Dialogs | Notices | Instant tenant notice broadcasts |

