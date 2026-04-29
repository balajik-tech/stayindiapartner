import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../models/community_model.dart';

abstract class CommunityRemoteDataSource {
  Future<CommunityDetailsModel> getCommunityDetails(String hostelId);
  Future<List<CommunityMessageModel>> getMessages(
    String hostelId, {
    int limit,
    String? before,
  });
  Future<void> sendMessage(String hostelId, String text);
  Future<List<AnnouncementModel>> getAnnouncements(String hostelId);
  Future<void> postAnnouncement(String hostelId, String title, String content);
  Future<List<OwnerDiscussionModel>> getOwnerDiscussions(String hostelId);
  Future<void> createOwnerDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  });

  
  Future<List<CommunityDetailsModel>> getJoinedOwnerCommunities();
  Future<List<CommunityDetailsModel>> getAvailableOwnerCommunities();
  Future<void> joinOwnerCommunity(String communityId);
  Future<List<Map<String, dynamic>>> getPendingJoinRequests();
  Future<void> handleJoinRequest(String communityId, String requesterId, String action);
  Future<Map<String, dynamic>> getCommunityInfo(String communityId);
  Future<void> createOwnerCommunity({
    required String name,
    String? description,
    String? imagePath,
  });
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final Dio _dio;

  CommunityRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<CommunityDetailsModel> getCommunityDetails(String hostelId) async {
    AppLogger.info('Fetching community details for hostel: $hostelId');
    final response = await _dio.get('${ApiConstants.community}/$hostelId');
    
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return CommunityDetailsModel.fromJson(data);
    }
    throw Exception('Failed to fetch community details');
  }

  @override
  Future<List<CommunityMessageModel>> getMessages(
    String hostelId, {
    int limit = 50,
    String? before,
  }) async {
    AppLogger.info('Fetching community messages (limit: $limit, before: $before)');
    final queryParams = <String, dynamic>{'limit': limit};
    if (before != null) queryParams['before'] = before;

    final response = await _dio.get(
      '${ApiConstants.community}/$hostelId/messages',
      queryParameters: queryParams,
    );
    
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      final messages = data['messages'] as List<dynamic>? ?? [];
      return messages
          .map((m) => CommunityMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch messages');
  }

  @override
  Future<void> sendMessage(String hostelId, String text) async {
    AppLogger.info('Sending community message');
    final response = await _dio.post(
      '${ApiConstants.community}/message',
      data: {'hostelId': hostelId, 'text': text},
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements(String hostelId) async {
    AppLogger.info('Fetching announcements');
    final response = await _dio.get('${ApiConstants.announcements}/$hostelId');
    
    if (response.statusCode == 200) {
      final dynamic rawData = response.data['data'];
      final List<dynamic> data = rawData is Map 
          ? (rawData['results'] ?? []) 
          : (rawData is List ? rawData : []);
      return data.map((a) => AnnouncementModel.fromJson(a as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch announcements');
  }

  @override
  Future<void> postAnnouncement(String hostelId, String title, String content) async {
    AppLogger.info('Posting announcement');
    final response = await _dio.post(
      ApiConstants.announcements,
      data: {
        'hostelId': hostelId,
        'title': title,
        'content': content,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to post announcement');
    }
  }

  @override
  Future<List<OwnerDiscussionModel>> getOwnerDiscussions(String hostelId) async {
    AppLogger.info('Fetching owner discussions');
    final response = await _dio.get(
      ApiConstants.ownerCommunity,
      queryParameters: {'hostelId': hostelId},
    );
    
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> items = (raw is List) 
          ? raw 
          : (raw is Map && raw['data'] is List ? raw['data'] : []);
      return items
          .map((d) => OwnerDiscussionModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch discussions');
  }

  @override
  Future<void> createOwnerDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) async {
    AppLogger.info('Creating owner discussion');
    final response = await _dio.post(
      ApiConstants.ownerCommunity,
      data: {
        'title': title,
        'description': description,
        'type': type,
        'hostelId': hostelId,
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create discussion');
    }
  }

  @override
  Future<List<CommunityDetailsModel>> getJoinedOwnerCommunities() async {
    AppLogger.info('Fetching joined owner communities');
    final response = await _dio.get('${ApiConstants.ownerCommunities}/joined');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((c) => CommunityDetailsModel.fromJson(c as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch joined communities');
  }

  @override
  Future<List<CommunityDetailsModel>> getAvailableOwnerCommunities() async {
    AppLogger.info('Fetching available owner communities');
    final response = await _dio.get('${ApiConstants.ownerCommunities}/available');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((c) => CommunityDetailsModel.fromJson(c as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch available communities');
  }

  @override
  Future<void> joinOwnerCommunity(String communityId) async {
    AppLogger.info('Requesting to join owner community: $communityId');
    final response = await _dio.post(
      '${ApiConstants.ownerCommunities}/join',
      data: {'communityId': communityId},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to request to join community');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingJoinRequests() async {
    AppLogger.info('Fetching pending join requests');
    final response = await _dio.get('${ApiConstants.ownerCommunities}/requests');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    }
    throw Exception('Failed to fetch pending requests');
  }

  @override
  Future<void> handleJoinRequest(String communityId, String requesterId, String action) async {
    AppLogger.info('Handling join request: $action for $requesterId in $communityId');
    final response = await _dio.post(
      '${ApiConstants.ownerCommunities}/handle-request',
      data: {
        'communityId': communityId,
        'requesterId': requesterId,
        'action': action,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to handle join request');
    }
  }

  @override
  Future<Map<String, dynamic>> getCommunityInfo(String communityId) async {
    if (communityId.isEmpty) {
      return {};
    }
    AppLogger.info('Fetching community info: $communityId');
    final response = await _dio.get('${ApiConstants.ownerCommunities}/info/$communityId');
    if (response.statusCode == 200) {
      return response.data['data'] ?? {};
    }
    throw Exception('Failed to fetch community info');
  }

  @override
  Future<void> createOwnerCommunity({
    required String name,
    String? description,
    String? imagePath,
  }) async {
    AppLogger.info('Creating owner community: $name');
    
    dynamic data;
    if (imagePath != null) {
      data = FormData.fromMap({
        'name': name,
        'description': description,
        'image': await MultipartFile.fromFile(imagePath),
      });
    } else {
      data = {
        'name': name,
        'description': description,
      };
    }

    final response = await _dio.post(
      '${ApiConstants.ownerCommunities}/create',
      data: data,
      options: Options(
        headers: {
          if (imagePath != null) 'x-upload-folder': 'communities',
        },
      ),
    );
    
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create community');
    }
  }
}
