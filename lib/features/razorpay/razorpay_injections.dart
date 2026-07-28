import 'package:get_it/get_it.dart';
import 'presentation/bloc/razorpay_cubit.dart';
import 'presentation/utils/razorpay_manager.dart';

void registerRazorpayFeature(GetIt sl) {
  // Utils
  sl.registerLazySingleton(() => RazorpayManager(apiKey: "rzp_test_TIonMLOPKwlfCt"));

  // Cubit
  sl.registerFactory(() => RazorpayCubit());
}
