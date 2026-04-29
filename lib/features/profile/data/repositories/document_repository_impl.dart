import 'package:stayindia_owner/features/profile/domain/entities/document.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Document>> getDocuments(String hostelId) async {
    return await remoteDataSource.getDocuments(hostelId);
  }

  @override
  Future<Document> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  }) async {
    return await remoteDataSource.uploadDocument(
      hostelId: hostelId,
      licenseType: licenseType,
      licenseNumber: licenseNumber,
      expiryDate: expiryDate,
      filePath: filePath,
    );
  }

  @override
  Future<void> deleteDocument(String id) async {
    return await remoteDataSource.deleteDocument(id);
  }
}
