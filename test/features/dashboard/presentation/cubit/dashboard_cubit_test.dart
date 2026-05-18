import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_status_entity.dart';

class MockGetDashboardDataUseCase extends Mock implements GetDashboardDataUseCase {}
class MockDeleteRoomUseCase extends Mock implements DeleteRoomUseCase {}

void main() {
  late DashboardCubit cubit;
  late MockGetDashboardDataUseCase mockGetDashboardData;
  late MockDeleteRoomUseCase mockDeleteRoom;

  setUp(() {
    mockGetDashboardData = MockGetDashboardDataUseCase();
    mockDeleteRoom = MockDeleteRoomUseCase();
    cubit = DashboardCubit(
      getDashboardDataUseCase: mockGetDashboardData,
      deleteRoomUseCase: mockDeleteRoom,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DashboardCubit', () {
    const tHostelId = '672465360662d53920703811';
    final tDashboardData = DashboardData(
      occupancy: Occupancy(
        totalBeds: 10,
        freeBeds: 5,
        occupiedBeds: 5,
        noticeBeds: 0,
        awayBeds: 0,
        reservedBeds: 0,
        overdueBeds: 0,
        maintenanceBeds: 0,
        floors: [],
      ),
      dailyOperations: DailyOperations(
        todayCheckIns: 1,
        todayCheckOuts: 0,
        rentDueToday: RentStats(count: 0, amount: 0),
        overdueRent: RentStats(count: 0, amount: 0),
        pendingMaintenance: 0,
        pendingComplaints: 0,
        pendingTickets: 0,
        alertBanner: AlertBanner(count: 0, message: ''),
      ),
      rentDueDetails: RentDueDetails(overdue: [], upcoming: []),
      occupancyStatus: OccupancyStatus(total: 5, inside: 5, outside: 0, unknown: 0),
    );

    test('initial state should be DashboardInitial', () {
      expect(cubit.state, const DashboardInitial());
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when fetchDashboardData is successful',
      build: () {
        when(() => mockGetDashboardData(any())).thenAnswer((_) async => tDashboardData);
        return cubit;
      },
      act: (cubit) => cubit.fetchDashboardData(tHostelId),
      expect: () => [
        const DashboardLoading(),
        DashboardLoaded(data: tDashboardData),
      ],
      verify: (_) {
        verify(() => mockGetDashboardData(tHostelId)).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [DashboardLoading, DashboardError] when fetchDashboardData fails',
      build: () {
        when(() => mockGetDashboardData(any())).thenThrow(Exception('Network Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchDashboardData(tHostelId),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardError>(),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'updates selectedFloorIndex when selectFloor is called',
      build: () => cubit,
      seed: () => DashboardLoaded(data: tDashboardData),
      act: (cubit) => cubit.selectFloor(1),
      expect: () => [
        DashboardLoaded(data: tDashboardData, selectedFloorIndex: 1),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'updates searchQuery when updateSearchQuery is called',
      build: () => cubit,
      seed: () => DashboardLoaded(data: tDashboardData),
      act: (cubit) => cubit.updateSearchQuery('Room 101'),
      expect: () => [
        DashboardLoaded(data: tDashboardData, searchQuery: 'Room 101'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'toggles view mode when toggleViewType is called',
      build: () => cubit,
      seed: () => DashboardLoaded(data: tDashboardData, isGridView: true),
      act: (cubit) => cubit.toggleViewType(false),
      expect: () => [
        DashboardLoaded(data: tDashboardData, isGridView: false),
      ],
    );
  });
}
