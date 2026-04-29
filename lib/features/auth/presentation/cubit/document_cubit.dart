import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/document_usecases.dart';
import 'package:stayindia_owner/core/utils/image_utils.dart';
import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final GetDocumentsUseCase _getDocuments;
  final UploadDocumentUseCase _uploadDocument;
  final DeleteDocumentUseCase _deleteDocument;

  DocumentCubit({
    required GetDocumentsUseCase getDocumentsUseCase,
    required UploadDocumentUseCase uploadDocumentUseCase,
    required DeleteDocumentUseCase deleteDocumentUseCase,
  })  : _getDocuments = getDocumentsUseCase,
        _uploadDocument = uploadDocumentUseCase,
        _deleteDocument = deleteDocumentUseCase,
        super(DocumentInitial());

  Future<void> getDocuments(String hostelId) async {
    emit(DocumentLoading());
    try {
      final documents = await _getDocuments(hostelId);
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  }) async {
    emit(DocumentLoading());
    try {
      String finalPath = filePath;
      final ext = filePath.toLowerCase();
      if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png')) {
        final compressed = await ImageUtils.compressImage(File(filePath));
        if (compressed != null) finalPath = compressed.path;
      }

      final document = await _uploadDocument(
        hostelId: hostelId,
        licenseType: licenseType,
        licenseNumber: licenseNumber,
        expiryDate: expiryDate,
        filePath: finalPath,
      );
      emit(DocumentOperationSuccess(
        message: 'Document uploaded successfully',
        document: document,
      ));
    } catch (e) {
      emit(DocumentError(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> deleteDocument(String documentId, String hostelId) async {
    emit(DocumentLoading());
    try {
      await _deleteDocument(documentId);
      emit(DocumentOperationSuccess(
        message: 'Document deleted successfully',
      ));
      await getDocuments(hostelId);
    } catch (e) {
      emit(DocumentError(message: ErrorHandler.getErrorMessage(e)));
    }
  }
}
