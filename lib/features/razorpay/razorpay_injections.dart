import 'package:get_it/get_it.dart';
import 'presentation/bloc/razorpay_cubit.dart';

void registerRazorpayFeature(GetIt sl) {
  // Cubit
  sl.registerFactory(() => RazorpayCubit());
}
