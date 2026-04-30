import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/hostel_repository.dart';

class GetHostelsUseCase {
  final HostelRepository repository;
  GetHostelsUseCase(this.repository);

  Future<List<Hostel>> call() {
    return repository.getHostels();
  }
}

class CreateHostelUseCase {
  final HostelRepository repository;
  CreateHostelUseCase(this.repository);

  Future<Hostel> call(Hostel hostel) {
    return repository.createHostel(hostel);
  }
}

class UpdateHostelUseCase {
  final HostelRepository repository;
  UpdateHostelUseCase(this.repository);

  Future<Hostel> call(Hostel hostel) {
    return repository.updateHostel(hostel);
  }
}

class DeleteHostelUseCase {
  final HostelRepository repository;
  DeleteHostelUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteHostel(id);
  }
}

class UploadHostelImagesUseCase {
  final HostelRepository repository;
  UploadHostelImagesUseCase(this.repository);

  Future<Hostel> call(String id, List<String> filePaths) {
    return repository.uploadHostelImages(id, filePaths);
  }
}

class UpdateHostelLocationUseCase {
  final HostelRepository repository;
  UpdateHostelLocationUseCase(this.repository);

  Future<void> call(String id, double lat, double lng) {
    return repository.updateHostelLocation(id, lat, lng);
  }
}
