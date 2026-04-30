import '../entities/hostel.dart';

abstract class HostelRepository {
  Future<List<Hostel>> getHostels();
  Future<Hostel> createHostel(Hostel hostel);
  Future<Hostel> updateHostel(Hostel hostel);
  Future<void> deleteHostel(String id);
  Future<Hostel> uploadHostelImages(String id, List<String> filePaths);
  Future<void> updateHostelLocation(String id, double lat, double lng);
}
