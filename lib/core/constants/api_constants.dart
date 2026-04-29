class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.koushiksoftwaresolutions.online/api/v1',
  );

  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String getMe = '/auth/me';

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

  static const String foodMenu = '/food-menu'; 
  static const String foodMenuWeekly = '/food-menu/weekly'; 
  static const String foodMenuPublic = '/food-menu/public'; 

  static const String settings = '/settings'; 

  static const String tenants = '/tenants';
  static const String tenantDetail = '/tenants'; 

  static const String community = '/community'; 

  static const String ownerCommunity = '/owner-community'; 
  static const String ownerCommunities = '/owner-communities'; 

  static const String announcements = '/announcements';

  static const String tickets = '/tickets'; 

  static const String notices = '/notices'; 

  static const String payments = '/payments'; 
  static const String paymentPay = '/payments'; 
  static const String paymentRemind = '/payments'; 
  static const String paymentRemindBulk = '/payments/remind-bulk';
  static const String paymentReminders = '/payments/reminders';
  static const String bills = '/bills'; 

  static const String transactions = '/transactions'; 

  static const String bookingsCheckin = '/bookings/checkin'; 
  static const String bookingsCheckinData = '/bookings/checkin-data'; 
  static const String bookingsConfirmed = '/bookings/confirmed'; 

  static const String tenantsManual = '/tenants/manual'; 

  static const String staff = '/staff'; 

  static const String financeStats = '/finance/stats';
  static const String financeAnalytics = '/finance/analytics';
  static const String financeRevenueHistory = '/finance/revenue-history';

  static const String documents = '/documents'; 
  static const String documentsHostel = '/documents/hostel'; 

  static const String reviews = '/reviews'; 
  static const String reviewsHostel = '/reviews/hostel'; 

  static const String userProfile = '/users/profile'; 
  static const String userCompleteProfile = '/users/complete-profile'; 
  static const String userDeleteAccount = '/users/delete-account'; 
  static const String userProfileImage = '/users/profile-image'; 

  static const String userHostels = '/users/hostels'; 

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http')) return path;

    if (path.startsWith('stay-india/')) {
      const String s3BucketUrl = 'https://stay-india.s3.us-east-1.amazonaws.com';
      return '$s3BucketUrl/$path';
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

  static String getPlaceholderImageUrl(String? path, {String text = 'Accommodation'}) {
    final url = getImageUrl(path);
    if (url != null) return url;
    return "https://placehold.co/600x400/png?text=$text";
  }
}
