import 'dart:io';

import '../services/app_config_service.dart';

class ApiConstants {


  static const String _api_Version = '/api/v1';

  static const String productionUrl = 'https://aws-api.stayindia.in';

  static const String stagingUrl = 'https://api.stayindia.in';

  static const String _prodUrl = '$stagingUrl$_api_Version';



  static const int paginationLimit = 100;

  
  static String get baseUrl {
    const url = String.fromEnvironment('API_BASE_URL', defaultValue: _prodUrl);
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  static String get effectiveBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    final url = fromEnv.isNotEmpty ? fromEnv : _prodUrl;
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  static final String sampleCSVURL = '$baseUrl/sample.csv';

  static const String remoteConfig = '/app-config';

  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String staffLogin = '/auth/login';
  static const String getMe = '/auth/me';
  static const String deviceToken = '/auth/device-token';
  static const String googleLogin = '/auth/google-login';

  static const String hostels = '/hostels';
  static const String hostelsHome = '/hostels/home';

  static const String bookings = '/bookings';
  static const String ownerBookings = '/bookings/owner-bookings';
  static const String myBookings = '/bookings/my-bookings';
  static const String manualCheckin = '/bookings/manual-checkin';
  static const String scanBooking = '/bookings/scan';
  static const String assignRoom = '/bookings/checkin';
  static const String checkoutBooking = '/bookings/checkout';
  static const String cancelBooking = '/bookings/cancel';
  static const String confirmBooking = '/bookings/confirm';
  static const String pendingBookings = '/bookings/owner-bookings';

  static const String rooms = '/rooms';
  static const String roomsOccupancy = '/rooms/occupancy';
  static const String roomsFloors = '/rooms/floors';
  static const String roomsByFloor = '/rooms/by-floor';
  static const String roomBeds = '/rooms';
  static const String roomBedDetail = '/rooms/bed';
  static const String roomBedHistory = '/rooms/bed-history';
  static const String roomsPublic = '/rooms/public/hostel';

  static const String dashboardBase = '/dashboard';
  static const String dashboardDailyOps = '/dashboard/daily-operations';
  static const String dashboardOccupancy = '/dashboard/occupancy';
  static const String dashboardRentDue = '/dashboard/rent-due';
  static const String dashboardBulkData = '/dashboard/bulk-data';
  static const String propertyOccupancyStatus = '/property';

  static const String foodMenu = '/food-menu';
  static const String foodMenuWeekly = '/food-menu/weekly';
  static const String foodMenuPublic = '/food-menu/public';

  static const String settings = '/settings';

  static const String tenants = '/tenants';
  static const String tenantDetail = '/tenants';
  static String bulkTenants(String hostelId) => '/tenants/$hostelId/bulk';
  static String tenantImportTemplate(String hostelId) => '/tenants/hostels/$hostelId/tenant-import-template';

  static const String community = '/community';

  static const String ownerCommunity = '/owner-community';
  static const String ownerCommunities = '/owner-communities';

  static const String announcements = '/announcements';
  static const String associations = '/associations';
  static const String associationsSearch = '/associations/search';
  static const String associationsPortal = '/association-portal/associations';
  static const String associationFeed = '/association-portal/feed';
  static const String associationPortalDetails = '/association-portal/details';
  static const String associationWorkingBody = '/association-portal/working-body';
  static const String associationTeamLeads = '/association-portal/teamleads';
  static const String associationExecutiveMembers = '/association-portal/executive-members';
  static const String associationPortMembers = '/association-portal/portal-members';
  static const String associationExecutiveStructure = '/association-portal/structure/leaders';
  static const String associationEligibleProperties = '/association-memberships/eligible-properties';
  static const String associationMembershipApplications = '/association-memberships/applications';
  static const String associationMyApplications = '/association-memberships/applications/mine';
  static String associationPaymentDetails(String membershipId) => '/association-memberships/applications/$membershipId/payment-details';
  static String associationCreatePaymentOrder(String membershipId) => '/association-memberships/applications/$membershipId/payment-order';
  static String associationCreateRenewalOrder(String membershipId) => '/association-memberships/memberships/$membershipId/renewal-order';
  static const String associationVerifyPayment = '/association-memberships/payments/verify';
  static const String sos = '/sos';
  static const String socialPosts = '/posts';

  static const String tickets = '/tickets';

  static const String notices = '/notices';
  static const String notifications = '/notifications';
  static const String offers = '/offers';
  static const String offerUploadImage = '/offers/upload';
  static const String payments = '/payments';
  static const String paymentPay = '/payments';
  static const String paymentRemind = '/payments';
  static const String paymentRemindBulk = '/payments/remind-bulk';
  static const String paymentReminders = '/payments/reminders';
  static const String bills = '/bills';
  static const String bankAccounts = '/bankaccounts';

  static const String externalBankVerification = '/digilocker/bank-verification';
      //'https://api.digiverification.com/api/v2/account-verification/verify';
  static const String panVerification = '/digilocker/pan-verification';
      //'https://api.digiverification.com/api/v4/pan/comprehensive';

  static const String panJwtToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXJ0bmVySWQiOiJFU1AwMDE0MiIsInRpbWVzdGFtcCI6MTc4NTkyNjU2OX0=.RdCyQR79CF73Ozvf8SH_Xweby7UQ1VhVz2ljN5hq9Ro=";
  static const String bankJwtToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYXJ0bmVySWQiOiJFU1AwMDE0MiIsInRpbWVzdGFtcCI6MTc4NTkyNjU2OX0=.RdCyQR79CF73Ozvf8SH_Xweby7UQ1VhVz2ljN5hq9Ro=";

  static String get razorpayKey => AppConfigService.instance.razorpayKey;
  static String get digilockerCompanyName =>
      AppConfigService.instance.digilockerCompanyName;
  static String get partnerCode => AppConfigService.instance.partnerCode;
  static String get digilockerRedirectUrl =>
      AppConfigService.instance.digilockerRedirectUrl;

  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionSubscribe = '/subscriptions/subscribe';
  static const String subscriptionVerifyPayment = '/subscriptions/verify-payment';
  static const String subscriptionPaymentSummary = '/subscriptions/payments';
  static const String subscriptionPaymentReceipt = '/subscriptions/payments';

  static const String transactions = '/transactions';

  static const String bookingsCheckin = '/bookings/checkin';
  static const String bookingsCheckinData = '/bookings/checkin-data';
  static const String bookingsConfirmed = '/bookings/confirmed';

  static const String tenantsManual = '/tenants/manual';
  static const String tenantRentalOrderCash = '/tenant-rental/orderby/cash';
  static const String tenantRentalOrderUpi = '/tenant-rental/orderby/upi';
  static const String tenantRentalPayments = '/tenant-rental/payments';
  static String tenantRentalPaymentCash(String rentalId) => '/tenant-rental/$rentalId/payment/cash';
  static String tenantRentalPaymentUpi(String rentalId) => '/tenant-rental/$rentalId/payment/upi';

  static const String staff = '/staff';

  static const String financeStats = '/finance/stats';
  static const String financeAnalytics = '/finance/analytics';
  static const String financeRevenueHistory = '/finance/revenue-history';

  static const String reports = '/reports';
  static const String reportsPayments = '/reports/payments';
  static const String reportsTenants = '/reports/tenants';
  static const String reportsBookings = '/reports/bookings';

  static const String documents = '/documents';
  static const String documentsHostel = '/documents/hostel';

  static const String reviews = '/reviews';
  static const String reviewsHostel = '/reviews/hostel';

  static const String userProfile = '/users/profile';
  static const String userCompleteProfile = '/users/complete-profile';
  static const String userDeleteAccount = '/users/delete-account';
  static const String userRestoreAccount = '/account-settings/recover';
  static const String userDeactivateAccount = '/account-settings/deactivate';
  static const String userProfileImage = '/users/profile';
  static const String userAcceptPolicy = '/users/accept-policy';

  static const String userHostels = '/users/hostels';
  static const String generateReferral = '/referrals/generate';
  static const String rateUs = '/app-config/rate-us?app=PARTNER';

  static const String partnerAppLink = "http://stayindia.in/partner";

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http')) return path;

    if (path.startsWith('stay-india/')) {
      // return 'https://stay-india.s3.amazonaws.com/$path';
      return 'https://stayindia.s3.ap-south-2.amazonaws.com/$path';
    }

    String serverRoot = baseUrl;
    if (serverRoot.endsWith('/api/v1')) {
      serverRoot = serverRoot.substring(0, serverRoot.length - 7);
    } else if (serverRoot.endsWith('/api')) {
      serverRoot = serverRoot.substring(0, serverRoot.length - 4);
    }

    String cleanPath = path.replaceAll('\\', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    if (!cleanPath.startsWith('uploads/')) {
      cleanPath = 'uploads/$cleanPath';
    }

    return '$serverRoot/$cleanPath';
  }

  static String getPlaceholderImageUrl(
    String? path, {
    String text = 'Accommodation',
  }) {
    final url = getImageUrl(path);
    if (url != null) return url;
    return "https://placehold.co/600x400/png?text=$text";
  }
}
