import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/features/auth/domain/models/guest_session.dart';

class GuestSessionCubit extends Cubit<GuestSession> {
  GuestSessionCubit()
      : super(const GuestSession(isGuest: true, isKycComplete: false)) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? true;
    final isKyc = prefs.getBool('isKycComplete') ?? false;
    emit(GuestSession(isGuest: isGuest, isKycComplete: isKyc));
  }

  Future<void> setGuest(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', isGuest);
    emit(state.copyWith(isGuest: isGuest));
  }

  Future<void> setKycComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isKycComplete', isComplete);
    emit(state.copyWith(isKycComplete: isComplete));
  }
}
