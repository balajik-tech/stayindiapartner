import 'package:stayindia_owner/features/profile/domain/entities/document.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/document_repository.dart';

class GetDocumentsUseCase {
  final DocumentRepository repository;
  GetDocumentsUseCase(this.repository);

  Future<List<Document>> call(String hostelId) {
    return repository.getDocuments(hostelId);
  }
}

class UploadDocumentUseCase {
  final DocumentRepository repository;
  UploadDocumentUseCase(this.repository);

  Future<Document> call({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  }) {
    return repository.uploadDocument(
      hostelId: hostelId,
      licenseType: licenseType,
      licenseNumber: licenseNumber,
      expiryDate: expiryDate,
      filePath: filePath,
    );
  }
}

class DeleteDocumentUseCase {
  final DocumentRepository repository;
  DeleteDocumentUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteDocument(id);
  }
}
