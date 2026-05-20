class GuestSession {
  final bool isGuest;
  final bool isKycComplete;

  const GuestSession({required this.isGuest, required this.isKycComplete});

  GuestSession copyWith({bool? isGuest, bool? isKycComplete}) {
    return GuestSession(
      isGuest: isGuest ?? this.isGuest,
      isKycComplete: isKycComplete ?? this.isKycComplete,
    );
  }
}
