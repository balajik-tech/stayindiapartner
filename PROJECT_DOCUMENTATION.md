# STAY INDIA OWNER - KNOWLEDGE TRANSFER (KT) & TECHNICAL DOCUMENTATION

---

## 1. EXECUTIVE SYSTEM OVERVIEW & ARCHITECTURE

### 1.1 Project Information
- **Application Name:** Stay India Owner (`stayindia_owner`)
- **Version:** `1.0.11+15`
- **Target Audience:** PG / Hostel Owners & Property Managers
- **Flutter Framework Version:** SDK `^3.10.7`
- **Supported Platforms:** Android (minSdk: 21), iOS
- **Repository Root:** `/Users/balajik/Desktop/STAY INDIA/Projects/Stay-India-Owner`

### 1.2 Architectural Paradigm: Clean Architecture
The Stay India Owner mobile application is engineered following **Clean Architecture Principles** combined with the **BLoC / Cubit Design Pattern**. The application codebase is split into feature-based modules located in `lib/features/` and cross-cutting core modules in `lib/core/`.

```
lib/
├── core/                        # Global & Shared Infrastructure
│   ├── constants/               # API URLs, UI constants, environment definitions
│   ├── di/                      # Feature dependency injection initializers
│   ├── error/                   # Failure classes & Exception handling
│   ├── location/                # Location Cubit & Service
│   ├── network/                 # Dio Interceptors (Logger, Retry, Error, Connectivity)
│   ├── services/                # AppBootstrapper, TokenStorage, DeepLink, Notifications, OfflineQueue
│   ├── socket/                  # WebSockets Client (Socket.IO)
│   ├── theme/                   # Light & Dark App Themes, Color Palette
│   └── widgets/                 # Common reusable widgets (Toast, ScaffoldMessenger, Avatars, etc.)
├── features/                    # Domain Feature Modules
│   ├── auth/                    # OTP Authentication, Google Login, Profile Completion
│   ├── bank_account/            # Bank Accounts, IFSC Lookup, PAN/Bank Verification
│   ├── bookings/                # Booking Requests, Check-in, QR Scanner, Bed Assignment
│   ├── communities/             # Owner Association Portal, Executive Body, Wings, Chat, SOS
│   ├── dashboard/               # Daily Operations Dashboard, Occupancy Stats, Rent Due Summary
│   ├── electricity_bills/       # Electricity Meter Readings, Bill Split, Tenant Payment Sheet
│   ├── finance/                 # Financial Statistics, Revenue Analytics, Trend Charts
│   ├── maintenance/             # Maintenance Ticket System, Resolution Status
│   ├── movement_history/        # Tenant Move-in/Move-out Logs
│   ├── notices/                 # Property Notice Board Broadcasting
│   ├── notifications/           # FCM Push Notification Center & Deep-link routing
│   ├── offers/                  # Banner & Promotional Offer Management
│   ├── payments/                # Rent Payments, Cash/UPI Collection, Bulk Reminders
│   ├── profile/                 # Hostel Setup, House Rules, Owner Profile, Terms & Privacy
│   ├── property_setup/          # Room & Bed Infrastructure Creation
│   ├── razorpay/                # Razorpay Payment Gateway Handler
│   ├── staff/                   # Staff Member Roles, Access Management
│   ├── stock_management/        # Asset & Inventory Tracking
│   └── tenants/                 # Tenant Directory, Manual Entry, Bulk CSV Import
└── main.dart                    # Application Entry Point
```

### 1.3 Key Architectural Layer Breakdown
1. **Presentation Layer (`presentation/`):**
   - **Pages & Widgets:** Built with Flutter Widgets, responsive layouts (`flutter_screenutil`, `responsive_sizer`).
   - **Cubits & States:** Managing UI state immutably (`flutter_bloc`, `hydrated_bloc`, `equatable`).
2. **Domain Layer (`domain/`):**
   - **Entities:** Pure Dart models representing business concepts.
   - **Repositories (Interfaces):** Abstraction contracts for data access.
   - **Use Cases:** Granular single-responsibility business logic executors (e.g., `VerifyOtpUseCase`, `CheckOutBookingUseCase`).
3. **Data Layer (`data/`):**
   - **Data Sources (`remote_datasource`, `local_datasource`):** Execute HTTP API calls using `Dio` or manage storage with `Hive`/`SharedPreferences`/`FlutterSecureStorage`.
   - **Models:** DTOs containing `fromJson()` and `toJson()` mapping methods.
   - **Repository Implementation (`repositories/*_impl.dart`):** Converts exceptions into clean business failures (`Either<Failure, Success>`).

---

## 2. ENVIRONMENT VARIABLES & REMOTE CONFIGURATION

### 2.1 Compile-Time Environment Flags
The app supports build-time configuration using Flutter `--dart-define` flags. Defaults are set in `lib/core/constants/api_constants.dart` and `lib/core/services/app_config_service.dart`.

| Environment Variable | Description | Default / Staging Fallback |
| :--- | :--- | :--- |
| `APP_ENV` | Target environment identifier | `STAGING` |
| `API_BASE_URL` | Base API Endpoint for backend services | `https://api.stayindia.in/api/v1` |
| `S3_BUCKET_URL` | AWS S3 Bucket storage URL for image assets | `https://stayindia.s3.ap-south-2.amazonaws.com` |
| `TERMS_AND_CONDITIONS_URL` | Terms & Conditions web link | `https://www.stayindia.in/privacy.html` |
| `ABOUT_US_URL` | About Us information URL | `https://www.stayindia.in/aboutus.html` |
| `APP_CONFIG_APP` | Remote configuration app key header (`x-app`) | `PARTNER` |
| `APP_CONFIG_API_KEY` | Remote configuration API key (`x-api-key`) | `OOcC7N4PxAy4LZbIKk8hfVC6` |
| `PARTNER_APP_URL` | Partner app promotion link | `http://stayindia.in/partner` |
| `SHARE_LINK_BASE_URL` | Deep Link Base URL for app referral sharing | `https://share.stayindia.in` |

### 2.2 Remote Configuration Service (`AppConfigService`)
During startup in `AppBootstrapper`, the app fetches dynamic parameters from `/app-config` with security headers (`x-app`, `x-api-key`).

**Endpoint:** `GET /app-config`

**Dynamic Config Keys Loaded at Runtime:**
- `app`: Application identifier mode (`PARTNER`)
- `razorpayKey`: Razorpay API Key ID for in-app payment collection.
- `digilocker.companyName`: Company name registered for DigiLocker KYC verification.
- `digilocker.partnerCode`: Partner authorization code for verification.
- `digilocker.secretToken`: Authorization secret token.
- `digilocker.redirectUrl`: OAuth redirect URL for verification callbacks.

---

## 3. FIREBASE & CLOUD INFRASTRUCTURE CONFIGURATION

### 3.1 Firebase Setup Overview
Firebase is initialized in `AppBootstrapper` using `DefaultFirebaseOptions.currentPlatform` defined in `lib/firebase_options.dart`.

### 3.2 Target Platform Credentials

#### Android Options
- **Project ID:** `stay-india-partner`
- **Storage Bucket:** `stay-india-partner.firebasestorage.app`
- **App ID:** `1:533876795078:android:7cab8fa7b279fe4cd459c7`
- **API Key:** `AIzaSyBsfFis5IjB8CtYmoP_vcZNhV8gE35IZlo`
- **Messaging Sender ID:** `533876795078`

#### iOS Options
- **Project ID:** `stay-india-partner`
- **Storage Bucket:** `stay-india-partner.firebasestorage.app`
- **Bundle ID:** `com.stayindia.stayindiaowner`
- **App ID:** `1:533876795078:ios:42cf2d47354d4c3cd459c7`
- **API Key:** `AIzaSyDDY6jTVn53jBrx4VFQfbYkzM8PSzoSUJI`
- **Google Client IDs:**
  - Android Client ID: `730093151187-b9i8hboeqmd6i8tk5ribcqn1teq4anig.apps.googleusercontent.com`
  - iOS Client ID: `730093151187-dh312ecscfthjepn87g0e14jjs15f4ua.apps.googleusercontent.com`

#### Web Options
- **Project ID:** `stay-india-owner`
- **App ID:** `1:730093151187:web:88b68af2f1a207768b8526`
- **Measurement ID:** `G-WJJLB2R9DJ`

### 3.3 Firebase Features Utilized
1. **Firebase Core (`firebase_core`):** Application initialization & state context.
2. **Firebase Cloud Messaging (`firebase_messaging`):** Handling background & foreground push notifications. Registers FCM tokens to backend via `/auth/device-token`.
3. **Firebase Crashlytics (`firebase_crashlytics`):** Captures unhandled Flutter framework errors & platform async exceptions.

---

## 4. THIRD-PARTY SDK INTEGRATIONS

| SDK / Library | Purpose | Configuration Details |
| :--- | :--- | :--- |
| `razorpay_flutter` | Payment Gateway for Subscriptions & Association fees | Initialized dynamically using key fetched from `AppConfigService`. |
| `flutter_digilocker_aadhar_pan` | Identity & PAN/Bank Verification | Uses company credentials, partner tokens, and DigiLocker SDK webview. |
| `mobile_scanner` | Camera QR Scanner for fast booking check-in | Requires Camera permission in `AndroidManifest.xml` & `Info.plist`. |
| `google_sign_in` | One-tap Google Login authentication | Integrates with Firebase OAuth. |
| `google_phone_number_hint` | One-tap SIM Phone hint selection during OTP login | Reduces manual entry during login. |
| `socket_io_client` | Real-time WebSockets communication | Connects to base server socket for community chat and real-time alerts. |
| `printing` & `pdf` | PDF preview & export of rent receipts and reports | Renders vector graphics and documents natively on Android/iOS. |
| `google_mlkit_*` | Text recognition, face detection, & image labeling | Offline document verification helper. |
| `app_links` | Deep linking & App Links / Universal Links support | Intercepts `https://share.stayindia.in/r/:id` for referral & post links. |

---

## 5. COMPLETE API ENDPOINT REFERENCE MANUAL

### Headers Sent on Every Request
All API requests (managed via `Dio`) automatically attach the following standard headers:
- `Authorization`: `Bearer <jwt_token>` (stored securely in `TokenStorage`)
- `app-type`: `OWNER_APP`
- `Content-Type`: `application/json` (or omitted for `FormData` file uploads)
- `Accept`: `application/json`

---

### 5.1 Authentication & Profile APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/request-otp` | Request OTP for phone authentication | `{"phoneNumber": "9876543210"}` | `{"success": true, "message": "OTP sent"}` |
| `POST` | `/auth/verify-otp` | Verify login OTP | `{"phoneNumber": "...", "otp": "123456"}` | `{"token": "JWT...", "user": {...}}` |
| `POST` | `/auth/google-login` | Authenticate using Google ID Token | `{"idToken": "..."}` | `{"token": "JWT...", "user": {...}}` |
| `POST` | `/auth/login` | Staff user password login | `{"phone": "...", "password": "..."}` | `{"token": "JWT...", "staff": {...}}` |
| `GET` | `/auth/me` | Fetch authenticated owner profile details | None | Owner entity payload |
| `POST` | `/auth/device-token` | Register FCM push notification token | `{"token": "fcm_token_string", "platform": "android"}` | `{"success": true}` |
| `PUT` | `/users/profile` | Update profile information | `{"name": "...", "email": "...", "address": "..."}` | Updated owner model |
| `POST` | `/users/complete-profile` | Complete initial owner onboarding | `{"ownerName": "...", "hostelName": "..."}` | Owner model |
| `POST` | `/users/accept-policy` | Record policy & terms acceptance | `{"accepted": true, "version": "1.0"}` | `{"success": true}` |
| `DELETE` | `/users/delete-account` | Request account deletion | None | `{"message": "Account scheduled for deletion"}` |
| `POST` | `/account-settings/recover` | Restore deactivated owner account | `{"phoneNumber": "..."}` | `{"success": true}` |
| `POST` | `/account-settings/deactivate` | Temporarily deactivate owner account | `{"reason": "..."}` | `{"success": true}` |

---

### 5.2 Hostels, Rooms & Property Infrastructure APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/hostels` | List all hostels owned by owner | None | List of hostel entities |
| `POST` | `/hostels` | Add a new hostel property | `{"name": "...", "address": "...", "city": "...", "totalBeds": 50}` | Created hostel object |
| `PUT` | `/hostels/:id` | Update hostel details | `{"name": "...", "amenities": [...]}` | Updated hostel object |
| `DELETE` | `/hostels/:id` | Delete a hostel property | None | `{"success": true}` |
| `GET` | `/rooms` | List rooms for a hostel | `?hostelId=xxx` | Room models list |
| `GET` | `/rooms/occupancy/:hostelId` | Fetch room occupancy details | Path param: `hostelId` | Occupancy statistics breakdown |
| `GET` | `/rooms/floors` | Fetch list of available floor levels | `?hostelId=xxx` | Floor numbers list |
| `GET` | `/rooms/by-floor` | Fetch rooms filtered by floor | `?hostelId=xxx&floor=1` | Filtered rooms list |
| `POST` | `/rooms` | Create a room | `{"hostelId": "...", "roomNumber": "101", "sharingType": 2, "rent": 6000}` | Created room object |
| `PUT` | `/rooms/:id` | Update room configuration | `{"roomNumber": "101A", "rent": 6500}` | Updated room object |
| `DELETE` | `/rooms/:id` | Delete room | None | `{"success": true}` |
| `GET` | `/rooms/bed` | Fetch detailed bed occupancy history | `?bedId=xxx` | Bed detail & tenant logs |

---

### 5.3 Dashboard & Analytics APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/dashboard/daily-operations` | Fetch daily operational statistics | `?hostelId=xxx` | Check-in/out counts, pending actions |
| `GET` | `/dashboard/occupancy` | Fetch overall occupancy matrix | `?hostelId=xxx` | Occupied, vacant, reserved counts |
| `GET` | `/dashboard/rent-due` | Fetch rent due summary card data | `?hostelId=xxx` | Total due, overdue amount, tenant list |
| `GET` | `/dashboard/bulk-data` | High-performance bulk sync endpoint | `?hostelId=xxx` | Combined hostel, room & tenant state |

---

### 5.4 Bookings & QR Check-In APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/bookings/owner-bookings` | Fetch list of booking requests | `?hostelId=xxx&status=PENDING` | List of booking models |
| `POST` | `/bookings/manual-checkin` | Process manual offline tenant check-in | `{"name": "...", "phone": "...", "roomId": "...", "bedNumber": "1"}` | Created booking object |
| `POST` | `/bookings/scan` | Verify scanned QR code payload | `{"qrData": "..."}` | Verified booking details |
| `POST` | `/bookings/checkin` | Finalize check-in and assign bed | `{"bookingId": "...", "roomId": "...", "bedNumber": "2"}` | Updated booking entity |
| `POST` | `/bookings/checkout` | Process tenant booking check-out | `{"bookingId": "...", "settlementAmount": 500}` | Settlement receipt payload |
| `POST` | `/bookings/cancel` | Reject or cancel a booking request | `{"bookingId": "...", "reason": "..."}` | Cancellation response |

---

### 5.5 Tenant Management APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/tenants` | List all active/past tenants | `?hostelId=xxx&page=1&limit=50&search=john` | Paginated tenant list |
| `GET` | `/tenants/:id` | Get detailed profile of single tenant | Path param: `tenantId` | Full tenant model (KYC, rent history) |
| `POST` | `/tenants/:hostelId/bulk` | Bulk import tenants via CSV file | Multipart form upload (`file`) | `{"imported": 15, "errors": []}` |
| `GET` | `/tenants/hostels/:id/tenant-import-template` | Download CSV template | Path param: `hostelId` | CSV File download URL |
| `POST` | `/tenants/manual` | Create new tenant manually | `{"name": "...", "phone": "...", "roomId": "..."}` | Created tenant entity |
| `GET` | `/tenants/manual/exists` | Check if tenant phone already exists | `?phone=9876543210` | `{"exists": true, "tenant": {...}}` |

---

### 5.6 Electricity Bills APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/electricity-bills` | Fetch list of electricity bills | `?hostelId=xxx&dateFrom=2025-01-01&dateTo=2025-01-31` | Electricity bills list with reading data |
| `POST` | `/electricity-bills` | Create electricity bill for room/floor | `{"hostelId": "...", "roomId": "...", "previousReading": 100, "currentReading": 250, "ratePerUnit": 8}` | Created bill object |
| `PUT` | `/electricity-bills/:id` | Update electricity bill details | `{"currentReading": 260, "ratePerUnit": 8.5}` | Updated bill object |
| `DELETE` | `/electricity-bills/:id` | Delete electricity bill | Path param: `billId` | `{"status": "success"}` |
| `PATCH` | `/electricity-bills/:id/tenants/:tenantId/status` | Update tenant electricity bill payment status | `{"paid": true, "amount": 600, "paymentMode": "CASH"}` | Updated tenant bill breakdown |

---

### 5.7 Rent Payments & Reminder APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/payments` | Fetch payments overview and list | `?hostelId=xxx&month=2025-02&status=PENDING` | Hostel payment summary model |
| `POST` | `/payments` | Create a rental payment bill entry | `{"tenantId": "...", "rent": 6000, "dueDate": "2025-02-05"}` | Payment model object |
| `PATCH` | `/payments/:id/pay` | Record rental payment collection | `{"amount": 6000, "paymentType": "CASH", "transactionId": "TXN123"}` | Payment updated response |
| `POST` | `/payments/:id/remind` | Send SMS/WhatsApp reminder to single tenant | `{"channel": "WHATSAPP", "message": "Custom reminder"}` | `{"success": true}` |
| `POST` | `/payments/remind-bulk` | Broadcast bulk payment reminders | `{"hostelId": "...", "bucket": "OVERDUE"}` | Bulk delivery report |
| `GET` | `/payments/reminders` | Fetch history of sent reminders | `?hostelId=xxx` | List of reminder log objects |
| `GET` | `/bills/:tenantId` | Fetch itemized bills for tenant | `?hostelId=xxx` | Rental + Electricity + Maintenance breakdown |
| `GET` | `/tenant-rental/tenant/:tenantId/hostel/:hostelId` | Fetch tenant rental payment records | Path params: `tenantId`, `hostelId` | List of rental models |

---

### 5.8 Bank Accounts & DigiLocker Verification APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/bankaccounts` | List owner bank accounts | None | List of bank account objects |
| `POST` | `/bankaccounts` | Add bank account manually | `{"accountNumber": "...", "ifscCode": "...", "accountHolderName": "..."}` | Created bank account entity |
| `PUT` | `/bankaccounts/:id` | Set bank account as primary settlement account | `{"setAsPrimary": true}` | Updated account object |
| `DELETE` | `/bankaccounts/:id` | Delete bank account | Path param: `accountId` | `{"success": true}` |
| `POST` | `/digilocker/bank-verification` | Verify bank account with Penny Drop API | `{"accountNumber": "...", "ifsc": "..."}` | Verification result (`nameAtBank`, `isMatch`) |
| `POST` | `/digilocker/pan-verification` | Verify owner PAN card | `{"panNumber": "ABCDE1234F"}` | PAN Verification result entity |

---

### 5.9 Maintenance & Complaints APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/tickets` | List maintenance complaint tickets | `?hostelId=xxx&status=OPEN` | List of ticket objects |
| `POST` | `/tickets` | Raise maintenance ticket | `{"hostelId": "...", "title": "Plumbing Leak", "priority": "HIGH"}` | Ticket model |
| `PUT` | `/tickets/:id` | Update ticket status / assign staff | `{"status": "IN_PROGRESS", "assignedStaffId": "..."}` | Updated ticket model |

---

### 5.10 Staff Management APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/staff` | List staff members assigned to hostel | `?hostelId=xxx` | Staff list payload |
| `POST` | `/staff` | Add new staff member | `{"name": "...", "phone": "...", "role": "MANAGER", "hostelId": "..."}` | Created staff object |
| `PUT` | `/staff/:id` | Update staff role or permissions | `{"role": "CARETAKER"}` | Updated staff entity |
| `DELETE` | `/staff/:id` | Remove staff access | Path param: `staffId` | `{"success": true}` |

---

### 5.11 Community & Association Portal APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/association-portal/associations` | List registered owner associations | None | List of association entities |
| `GET` | `/association-portal/details/:id` | Get association detail & governance info | Path param: `associationId` | Full association model |
| `GET` | `/association-portal/working-body/:id` | Fetch working committee members | Path param: `associationId` | Executive members list |
| `GET` | `/association-portal/user-feed` | Fetch community social feed posts | None | Feed posts list |
| `POST` | `/posts` | Create a post in community feed | `{"content": "...", "images": [...]}` | Created post object |
| `DELETE` | `/posts/:id` | Delete post | Path param: `postId` | `{"success": true}` |
| `POST` | `/sos` | Broadcast emergency SOS alert | `{"hostelId": "...", "latitude": 17.38, "longitude": 78.48, "message": "Emergency"}` | SOS response entity |
| `GET` | `/association-memberships/applications/mine` | List owner's membership applications | None | Membership application list |
| `POST` | `/association-memberships/applications/:id/payment-order` | Create Razorpay order for membership fee | Path param: `applicationId` | `{"orderId": "order_xxx", "amount": 1000}` |
| `POST` | `/association-memberships/payments/verify` | Verify Razorpay payment signature | `{"razorpayOrderId": "...", "razorpayPaymentId": "...", "signature": "..."}` | Verification status |

---

### 5.12 Subscription Plans APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/subscriptions/plans` | Fetch available owner subscription tiers | None | Plans array (Starter, Growth, Pro) |
| `POST` | `/subscriptions/subscribe` | Initiate subscription purchase | `{"planId": "...", "billingCycle": "ANNUAL"}` | Order payload |
| `POST` | `/subscriptions/verify-payment` | Verify Razorpay subscription payment | `{"paymentId": "...", "signature": "..."}` | Activated subscription info |
| `GET` | `/subscriptions/my/receipts` | Fetch payment receipts history | None | Receipts list |

---

### 5.13 Finance Stats & Revenue Analytics APIs

| Method | Endpoint | Description | Query / Request Payload | Response Data |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/finance/stats` | Fetch financial KPI cards | `?hostelId=xxx` | Total revenue, pending, collection rate |
| `GET` | `/finance/analytics` | Fetch revenue trend analytics | `?hostelId=xxx&startDate=2025-01-01&endDate=2025-01-31&interval=MONTHLY` | Chart trend data points |
| `GET` | `/finance/revenue-history` | Fetch detailed itemized revenue logs | `?hostelId=xxx&type=RENT` | Revenue transaction list |

---

## 6. FEATURE MODULES TECHNICAL BREAKDOWN (KT TRANSFER)

### 6.1 Feature Module 1: Authentication (`lib/features/auth/`)
- **Use Cases:** `RequestOtpUseCase`, `VerifyOtpUseCase`, `GetCurrentOwnerUseCase`, `CompleteProfileUseCase`, `AcceptPolicyUseCase`, `DeleteAccountUseCase`, `RestoreAccountUseCase`, `LogoutUseCase`.
- **State Management:** `AuthCubit` (States: `AuthInitial`, `AuthLoading`, `AuthOtpSent`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthProfileCompleted`, `AuthSessionRestoreError`, `AuthGoogleNeedsPhone`).
- **Data Source:** `AuthRemoteDataSource` (`Dio`), `OtpAttemptLocalDataSource` (Throttles OTP requests locally).
- **Key Flow:** User enters phone number -> Phone Hint helper auto-fills -> Request OTP sent -> User verifies OTP -> Receives JWT token -> `TokenStorage` persists token -> Cubit fetches `/auth/me` -> If onboarding incomplete, navigate to `RegistrationPersonalPage`, else navigate to `MainNavigationPage`.

### 6.2 Feature Module 2: Dashboard (`lib/features/dashboard/`)
- **Use Cases:** `GetDailyOperationsUseCase`, `GetOccupancyStatsUseCase`, `GetRentDueSummaryUseCase`, `SyncBulkDashboardUseCase`.
- **State Management:** `DashboardCubit` (States: `DashboardInitial`, `DashboardLoading`, `DashboardLoaded`, `DashboardError`).
- **Widgets:** `SummaryCards`, `CheckoutSettlementModal`, `DailyOpsWidget`.
- **Key Flow:** Home screen initializes `DashboardCubit` with current `hostelId`. Loads cards summarizing Occupancy, Overdue Rent, Pending Check-ins/outs, and open complaint tickets.

### 6.3 Feature Module 3: Bookings & QR Scanner (`lib/features/bookings/`)
- **Use Cases:** `GetBookingsUseCase`, `ScanBookingUseCase`, `FinalizeCheckinUseCase`, `CheckoutBookingUseCase`, `CancelBookingUseCase`.
- **State Management:** `BookingsCubit` (States: `BookingsInitial`, `BookingsLoading`, `BookingsLoaded`, `BookingScanSuccess`, `BookingCheckinSuccess`, `BookingsError`).
- **Widgets:** `QrScannerScreen`, `BookingCheckinSheet`, `BookingCard`.
- **Key Flow:** Owner can tap QR Scanner button -> `MobileScanner` scans QR code from tenant app -> Returns token -> Backend verifies booking -> Opens `BookingCheckinSheet` showing room selection -> Selects room/bed -> Posts `/bookings/checkin` -> Bed occupancy updated automatically.

### 6.4 Feature Module 4: Tenant Directory & Bulk Import (`lib/features/tenants/`)
- **Use Cases:** `GetTenantsUseCase`, `GetTenantDetailUseCase`, `CreateTenantManualUseCase`, `ImportTenantsBulkUseCase`.
- **State Management:** `TenantCubit` & `TenantState`.
- **Widgets:** `TenantCard`, `TenantDetailsSheet`, `AddTenantSheet`.
- **Key Flow:** Supports filtering tenants by Room, Payment Status (Paid, Pending, Overdue), and Search text. Allows downloading a CSV template, picking a file using `file_picker`, uploading to `/tenants/:hostelId/bulk`, and viewing instant validation errors or success counts.

### 6.5 Feature Module 5: Electricity Bills Management (`lib/features/electricity_bills/`)
- **Use Cases:** `FetchElectricityBillsUseCase`, `CreateElectricityBillUseCase`, `UpdateElectricityBillUseCase`, `DeleteElectricityBillUseCase`, `UpdateTenantBillStatusUseCase`.
- **State Management:** `ElectricityBillCubit` & `ElectricityBillState`.
- **Widgets:** `CollectTenantPaymentSheet`, `ElectricityBillCard`, `CreateElectricityBillModal`.
- **Key Flow:** Owner logs monthly meter readings for rooms or floors (`previousReading`, `currentReading`, `ratePerUnit`). Backend calculates total bill and splits amongst room tenants. Owner can collect payments per tenant and mark status via `CollectTenantPaymentSheet`.

### 6.6 Feature Module 6: Bank Account & Verification (`lib/features/bank_account/`)
- **Use Cases:** `AddBankAccountUseCase`, `GetPropertiesWithAccountsUseCase`, `LookupIfscUseCase`, `SetPrimaryAccountUseCase`, `VerifyBankAccountUseCase`, `VerifyPanUseCase`.
- **State Management:** `BankAccountCubit`, `AddBankAccountCubit`.
- **Integration:** Calls `/digilocker/bank-verification` (Penny Drop verification) to confirm name match between registered owner and bank account holder before enabling online settlements.

---

## 7. LOCAL STORAGE, CACHING STRATEGY & OFFLINE QUEUE

### 7.1 Persistence Libraries
1. **`FlutterSecureStorage`:** Stores encrypted authentication tokens (`access_token`, `refresh_token`) securely in Keychain (iOS) and KeyStore (Android).
2. **`HydratedBloc`:** Persists BLoC UI states across app restarts (e.g. active hostel selection, theme settings).
3. **`Hive`:** Fast key-value local NoSQL database used for caching offline records and temporary lookup tables.
4. **`SharedPreferences`:** Stores lightweight flags such as `has_seen_onboarding`.

### 7.2 Offline Queue Service (`OfflineQueueService`)
When network connectivity is lost (`ConnectivityInterceptor` detects no internet connection), write requests are intercepted and serialized into `OfflineQueueService`. Once connection is restored via `connectivity_plus` streams, queued requests are automatically replayed in order to keep backend and client synced seamlessly.

---

## 8. DEVELOPER BUILD & RUN GUIDE

### 8.1 Prerequisites
- Flutter SDK `^3.10.7`
- Dart SDK `^3.1.0`
- Java Development Kit (JDK) 17
- Android Studio / Xcode (with CocoaPods installed)

### 8.2 Installation & Dependency Sync
```bash
# Navigate to project directory
cd "/Users/balajik/Desktop/STAY INDIA/Projects/Stay-India-Owner"

# Clean build artifacts
flutter clean

# Fetch Dart dependencies
flutter pub get
```

### 8.3 Running the Application

#### Staging Mode (Default)
```bash
flutter run
```

#### Production Mode
```bash
flutter run \
  --dart-define=APP_ENV=PRODUCTION \
  --dart-define=API_BASE_URL=https://api.stayindia.in/api/v1 \
  --dart-define=S3_BUCKET_URL=https://stayindia.s3.ap-south-2.amazonaws.com
```

### 8.4 Building Production Release Bundles

#### Build Android APK
```bash
flutter build apk --release \
  --dart-define=APP_ENV=PRODUCTION \
  --dart-define=API_BASE_URL=https://api.stayindia.in/api/v1
```

#### Build Android App Bundle (AAB for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=APP_ENV=PRODUCTION \
  --dart-define=API_BASE_URL=https://api.stayindia.in/api/v1
```

#### Build iOS IPA (App Store)
```bash
flutter build ipa --release \
  --dart-define=APP_ENV=PRODUCTION \
  --dart-define=API_BASE_URL=https://api.stayindia.in/api/v1
```

---
*Documentation maintained by Stay India Engineering Team.*
