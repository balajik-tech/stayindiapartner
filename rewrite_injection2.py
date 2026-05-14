import re

with open("lib/injection_container.dart", "r") as f:
    content = f.read()

# Add the missing imports for the injection files
imports_to_add = """import 'package:stayindia_owner/features/profile/profile_injections.dart';
import 'package:stayindia_owner/features/notices/notice_injections.dart';
import 'package:stayindia_owner/features/payments/payment_injections.dart';
import 'package:stayindia_owner/features/maintenance/maintenance_injections.dart';
import 'package:stayindia_owner/features/staff/staff_injections.dart';
import 'package:stayindia_owner/features/stock_management/stock_management_injections.dart';
import 'package:stayindia_owner/features/finance/finance_injections.dart';
import 'package:stayindia_owner/features/guest/guest_injections.dart';
import 'package:stayindia_owner/features/notifications/notification_injections.dart';
import 'package:stayindia_owner/features/property_setup/property_setup_injections.dart';
import 'package:stayindia_owner/features/offers/offers_injections.dart';
"""

# replace the imports from domain/repositories, data/data_sources, etc. with nothing
# because the feature injections files handle them.
lines = content.split('\n')
new_lines = []
for line in lines:
    if line.startswith("import 'package:stayindia_owner/features/profile/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/tenants/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/notices/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/payments/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/maintenance/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/staff/domain/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/profile/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/tenants/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/notices/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/payments/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/maintenance/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/staff/data/datasources/") or \
       line.startswith("import 'package:stayindia_owner/features/profile/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/tenants/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/notices/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/payments/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/maintenance/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/staff/data/repositories/") or \
       line.startswith("import 'package:stayindia_owner/features/profile/presentation/cubit/") or \
       line.startswith("import 'package:stayindia_owner/features/notices/presentation/cubit/") or \
       line.startswith("import 'package:stayindia_owner/features/payments/presentation/cubit/") or \
       line.startswith("import 'package:stayindia_owner/features/maintenance/presentation/cubit/") or \
       line.startswith("import 'package:stayindia_owner/features/staff/presentation/cubit/") or \
       line.startswith("import 'package:stayindia_owner/features/auth/presentation/cubit/document_cubit.dart';"):
        continue
    new_lines.append(line)

content = '\n'.join(new_lines)

# Find init() function and replace it
import_match = "import 'package:stayindia_owner/features/tenants/tenants_injections.dart';"
content = content.replace(import_match, import_match + "\n" + imports_to_add)

init_start = content.find("Future<void> init() async {")
init_end = content.find("sl.registerLazySingleton(() => TokenStorage(")

if init_start != -1 and init_end != -1:
    new_init = """Future<void> init() async {
  registerAuthFeature(sl);
  registerDashboardFeature(sl);
  registerBookingsFeature(sl);
  registerCommunityFeature(sl);
  registerTenantsFeature(sl);
  registerProfileFeature(sl);
  registerNoticesFeature(sl);
  registerPaymentsFeature(sl);
  registerMaintenanceFeature(sl);
  registerStaffFeature(sl);
  registerStockManagementFeature(sl);
  registerFinanceFeature(sl);
  registerGuestFeature(sl);
  registerNotificationFeature(sl);
  registerPropertySetupFeature(sl);
  registerOffersFeature(sl);

  sl.registerFactory(() => LocationCubit(sl()));
  sl.registerLazySingleton(() => LocationService());

  """
    content = content[:init_start] + new_init + content[init_end:]

with open("lib/injection_container.dart", "w") as f:
    f.write(content)
