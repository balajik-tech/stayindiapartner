import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'presentation/bloc/razorpay_cubit.dart';
import 'presentation/utils/razorpay_manager.dart';

void registerRazorpayFeature(GetIt sl) {
  // Utils
  sl.registerLazySingleton(() => RazorpayManager(apiKey: ApiConstants.razorpayKey));

  // Cubit
  sl.registerFactory(() => RazorpayCubit(sl<RazorpayManager>()));
}
