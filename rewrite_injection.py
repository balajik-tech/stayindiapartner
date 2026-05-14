import re

with open("lib/injection_container.dart", "r") as f:
    content = f.read()

replacements = {
    "'package:stayindia_owner/domain/repositories/hostel_repository.dart'": "'package:stayindia_owner/features/profile/domain/repositories/hostel_repository.dart'",
    "'package:stayindia_owner/domain/repositories/room_repository.dart'": "'package:stayindia_owner/features/profile/domain/repositories/room_repository.dart'",
    "'package:stayindia_owner/domain/repositories/food_menu_repository.dart'": "'package:stayindia_owner/features/profile/domain/repositories/food_menu_repository.dart'",
    "'package:stayindia_owner/domain/repositories/settings_repository.dart'": "'package:stayindia_owner/features/profile/domain/repositories/settings_repository.dart'",
    "'package:stayindia_owner/domain/repositories/complaints_repository.dart'": "'package:stayindia_owner/features/tenants/domain/repositories/complaints_repository.dart'",
    "'package:stayindia_owner/domain/repositories/notice_repository.dart'": "'package:stayindia_owner/features/notices/domain/repositories/notice_repository.dart'",
    "'package:stayindia_owner/domain/repositories/payment_repository.dart'": "'package:stayindia_owner/features/payments/domain/repositories/payment_repository.dart'",
    "'package:stayindia_owner/domain/repositories/maintenance_repository.dart'": "'package:stayindia_owner/features/maintenance/domain/repositories/maintenance_repository.dart'",
    "'package:stayindia_owner/domain/repositories/staff_repository.dart'": "'package:stayindia_owner/features/staff/domain/repositories/staff_repository.dart'",
    "'package:stayindia_owner/domain/repositories/document_repository.dart'": "'package:stayindia_owner/features/profile/domain/repositories/document_repository.dart'",
    "'package:stayindia_owner/data/data_sources/hostel_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/hostel_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/room_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/room_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/food_menu_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/food_menu_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/settings_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/settings_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/complaints_remote_data_source.dart'": "'package:stayindia_owner/features/tenants/data/datasources/complaints_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/notice_remote_data_source.dart'": "'package:stayindia_owner/features/notices/data/datasources/notice_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/payment_remote_data_source.dart'": "'package:stayindia_owner/features/payments/data/datasources/payment_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/maintenance_remote_data_source.dart'": "'package:stayindia_owner/features/maintenance/data/datasources/maintenance_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/staff_remote_data_source.dart'": "'package:stayindia_owner/features/staff/data/datasources/staff_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/document_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/document_remote_datasource.dart'",
    "'package:stayindia_owner/data/data_sources/user_remote_data_source.dart'": "'package:stayindia_owner/features/profile/data/datasources/profile_remote_datasource.dart'",
    "'package:stayindia_owner/data/repositories/hostel_repository_impl.dart'": "'package:stayindia_owner/features/profile/data/repositories/hostel_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/room_repository_impl.dart'": "'package:stayindia_owner/features/profile/data/repositories/room_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/food_menu_repository_impl.dart'": "'package:stayindia_owner/features/profile/data/repositories/food_menu_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/settings_repository_impl.dart'": "'package:stayindia_owner/features/profile/data/repositories/settings_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/complaints_repository_impl.dart'": "'package:stayindia_owner/features/tenants/data/repositories/complaints_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/notice_repository_impl.dart'": "'package:stayindia_owner/features/notices/data/repositories/notice_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/payment_repository_impl.dart'": "'package:stayindia_owner/features/payments/data/repositories/payment_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/maintenance_repository_impl.dart'": "'package:stayindia_owner/features/maintenance/data/repositories/maintenance_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/staff_repository_impl.dart'": "'package:stayindia_owner/features/staff/data/repositories/staff_repository_impl.dart'",
    "'package:stayindia_owner/data/repositories/document_repository_impl.dart'": "'package:stayindia_owner/features/profile/data/repositories/document_repository_impl.dart'",
    "'package:stayindia_owner/presentation/profile/cubit/hostel_cubit.dart'": "'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart'",
    "'package:stayindia_owner/presentation/profile/cubit/room_cubit.dart'": "'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart'",
    "'package:stayindia_owner/presentation/profile/cubit/food_menu_cubit.dart'": "'package:stayindia_owner/features/profile/presentation/cubit/food_menu_cubit.dart'",
    "'package:stayindia_owner/presentation/profile/cubit/settings_cubit.dart'": "'package:stayindia_owner/features/profile/presentation/cubit/settings_cubit.dart'",
    "'package:stayindia_owner/presentation/notices/cubit/notice_cubit.dart'": "'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart'",
    "'package:stayindia_owner/presentation/payments/cubit/payment_cubit.dart'": "'package:stayindia_owner/features/payments/presentation/cubit/payment_cubit.dart'",
    "'package:stayindia_owner/presentation/maintenance/cubit/maintenance_cubit.dart'": "'package:stayindia_owner/features/maintenance/presentation/cubit/maintenance_cubit.dart'",
    "'package:stayindia_owner/presentation/staff/cubit/staff_cubit.dart'": "'package:stayindia_owner/features/staff/presentation/cubit/staff_cubit.dart'",
    "UserRemoteDataSource": "ProfileRemoteDataSource",
    "UserRemoteDataSourceImpl": "ProfileRemoteDataSourceImpl",
    "HostelRemoteDataSource": "HostelRemoteDatasource",
    "HostelRemoteDataSourceImpl": "HostelRemoteDatasourceImpl",
    "RoomRemoteDataSource": "RoomRemoteDatasource",
    "RoomRemoteDataSourceImpl": "RoomRemoteDatasourceImpl",
    "FoodMenuRemoteDataSource": "FoodMenuRemoteDatasource",
    "FoodMenuRemoteDataSourceImpl": "FoodMenuRemoteDatasourceImpl",
    "SettingsRemoteDataSource": "SettingsRemoteDatasource",
    "SettingsRemoteDataSourceImpl": "SettingsRemoteDatasourceImpl",
    "ComplaintsRemoteDataSource": "ComplaintsRemoteDatasource",
    "ComplaintsRemoteDataSourceImpl": "ComplaintsRemoteDatasourceImpl",
    "NoticeRemoteDataSource": "NoticeRemoteDatasource",
    "NoticeRemoteDataSourceImpl": "NoticeRemoteDatasourceImpl",
    "PaymentRemoteDataSource": "PaymentRemoteDatasource",
    "PaymentRemoteDataSourceImpl": "PaymentRemoteDatasourceImpl",
    "MaintenanceRemoteDataSource": "MaintenanceRemoteDatasource",
    "MaintenanceRemoteDataSourceImpl": "MaintenanceRemoteDatasourceImpl",
    "StaffRemoteDataSource": "StaffRemoteDatasource",
    "StaffRemoteDataSourceImpl": "StaffRemoteDatasourceImpl",
    "DocumentRemoteDataSource": "DocumentRemoteDatasource",
    "DocumentRemoteDataSourceImpl": "DocumentRemoteDatasourceImpl"
}

for old, new in replacements.items():
    content = content.replace(old, new)

# wait, line 79 has error: "The named parameter 'getDocumentsUseCase' is required..."
# sl.registerFactory(() => DocumentCubit(documentRepository: sl()));
# the error says: The named parameter 'getDocumentsUseCase' is required, but there's no corresponding argument.
content = content.replace(
    "sl.registerFactory(() => DocumentCubit(documentRepository: sl()));",
    "sl.registerFactory(() => DocumentCubit(getDocumentsUseCase: sl(), uploadDocumentUseCase: sl(), deleteDocumentUseCase: sl(), documentRepository: sl()));"
)

with open("lib/injection_container.dart", "w") as f:
    f.write(content)
