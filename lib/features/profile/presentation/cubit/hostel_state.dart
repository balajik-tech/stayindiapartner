import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

abstract class HostelState extends Equatable {
  final DateTime? lastFetched;
  const HostelState({this.lastFetched});

  bool get isStale {
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched!).inMinutes >= 5; 
  }

  @override
  List<Object?> get props => [lastFetched];
}

class HostelInitial extends HostelState {
  const HostelInitial({super.lastFetched});
}

class HostelLoading extends HostelState {
  const HostelLoading({super.lastFetched});
}

class HostelLoaded extends HostelState {
  final List<Hostel> hostels;
  final int selectedHostelIndex;
  
  const HostelLoaded({
    required this.hostels, 
    this.selectedHostelIndex = 0,
    super.lastFetched,
  });

  @override
  List<Object?> get props => [hostels, selectedHostelIndex, lastFetched];
}

class HostelOperationSuccess extends HostelState {
  final String message;
  final String? hostelId;
  const HostelOperationSuccess({required this.message, this.hostelId});

  @override
  List<Object?> get props => [message, hostelId];
}

class HostelError extends HostelState {
  final String message;
  const HostelError({required this.message});

  @override
  List<Object?> get props => [message];
}
