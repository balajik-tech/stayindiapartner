import 'dart:isolate';
import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_status_entity.dart';
import '../models/occupancy_model.dart';
import '../models/daily_operations_model.dart';
import '../models/rent_due_model.dart';
import '../models/occupancy_status_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl({required this.remote});

  @override
  Future<DashboardData> getDashboardData(String hostelIds) async {
    try {
      final rawData = await remote.getBulkDashboardData(hostelIds);

      final result = await Isolate.run(() {
        final allResults = rawData
            .map((item) {
              try {
                if (item['success'] == false) {
                  return null;
                }
                return DashboardData(
                  occupancy: OccupancyModel.fromJson(item['occupancy'] ?? {}),
                  dailyOperations: DailyOperationsModel.fromJson(
                    item['dailyOperations'] ?? {},
                  ),
                  rentDueDetails: RentDueDetailsModel.fromJson(
                    item['rentDueDetails'] ?? {},
                  ),
                  occupancyStatus: OccupancyStatusModel.fromJson(
                    item['occupancyStatus'] ?? {},
                  ),
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<DashboardData>()
            .toList();

        if (allResults.isEmpty) {
          return null;
        }

        if (allResults.length == 1) {
          return allResults.first;
        }

        int totalBeds = 0;
        int freeBeds = 0;
        int occupiedBeds = 0;
        int noticeBeds = 0;
        int awayBeds = 0;
        int reservedBeds = 0;
        int overdueBeds = 0;
        int maintenanceBeds = 0;
        List<FloorData> allFloors = [];

        int todayCheckIns = 0;
        int todayCheckOuts = 0;
        int rentDueTodayCount = 0;
        double rentDueTodayAmount = 0;
        int overdueRentCount = 0;
        double overdueRentAmount = 0;
        int pendingMaintenance = 0;
        int pendingComplaints = 0;
        int pendingTickets = 0;

        int statusTotal = 0;
        int statusInside = 0;
        int statusOutside = 0;
        int statusUnknown = 0;

        List<RentPayment> allOverdue = [];
        List<RentPayment> allUpcoming = [];

        for (var data in allResults) {
          totalBeds += data.occupancy.totalBeds;
          freeBeds += data.occupancy.freeBeds;
          occupiedBeds += data.occupancy.occupiedBeds;
          noticeBeds += data.occupancy.noticeBeds;
          awayBeds += data.occupancy.awayBeds;
          reservedBeds += data.occupancy.reservedBeds;
          overdueBeds += data.occupancy.overdueBeds;
          maintenanceBeds += data.occupancy.maintenanceBeds;
          allFloors.addAll(data.occupancy.floors);

          todayCheckIns += data.dailyOperations.todayCheckIns;
          todayCheckOuts += data.dailyOperations.todayCheckOuts;
          rentDueTodayCount += data.dailyOperations.rentDueToday.count;
          rentDueTodayAmount += data.dailyOperations.rentDueToday.amount;
          overdueRentCount += data.dailyOperations.overdueRent.count;
          overdueRentAmount += data.dailyOperations.overdueRent.amount;
          pendingMaintenance += data.dailyOperations.pendingMaintenance;
          pendingComplaints += data.dailyOperations.pendingComplaints;
          pendingTickets += data.dailyOperations.pendingTickets;

          statusTotal += data.occupancyStatus.total;
          statusInside += data.occupancyStatus.inside;
          statusOutside += data.occupancyStatus.outside;
          statusUnknown += data.occupancyStatus.unknown;

          allOverdue.addAll(data.rentDueDetails.overdue);
          allUpcoming.addAll(data.rentDueDetails.upcoming);
        }

        return DashboardData(
          occupancy: Occupancy(
            totalBeds: totalBeds,
            freeBeds: freeBeds,
            occupiedBeds: occupiedBeds,
            noticeBeds: noticeBeds,
            awayBeds: awayBeds,
            reservedBeds: reservedBeds,
            overdueBeds: overdueBeds,
            maintenanceBeds: maintenanceBeds,
            floors: allFloors,
          ),
          dailyOperations: DailyOperations(
            todayCheckIns: todayCheckIns,
            todayCheckOuts: todayCheckOuts,
            rentDueToday: RentStats(
              count: rentDueTodayCount,
              amount: rentDueTodayAmount,
            ),
            overdueRent: RentStats(
              count: overdueRentCount,
              amount: overdueRentAmount,
            ),
            pendingMaintenance: pendingMaintenance,
            pendingComplaints: pendingComplaints,
            pendingTickets: pendingTickets,
            alertBanner: AlertBanner(
              count: pendingTickets,
              message: '$pendingTickets pending items requiring attention',
            ),
          ),
          rentDueDetails: RentDueDetails(
            overdue: allOverdue,
            upcoming: allUpcoming,
          ),
          occupancyStatus: OccupancyStatus(
            total: statusTotal,
            inside: statusInside,
            outside: statusOutside,
            unknown: statusUnknown,
          ),
        );
      });

      if (result == null) {
        throw Exception('no_dashboard_data_found'.tr());
      }
      return result;
    } catch (e) {
      AppLogger.error('Error in DashboardRepositoryImpl.getDashboardData: $e');
      rethrow;
    }
  }

  @override
  Future<RentDueDetails> getRentDueDetails(String hostelId) {
    return remote.getRentDueDetails(hostelId);
  }
}
