import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/personal_chat_page.dart';

class OwnersListPage extends StatefulWidget {
  const OwnersListPage({super.key});

  @override
  State<OwnersListPage> createState() => _OwnersListPageState();
}

class _OwnersListPageState extends State<OwnersListPage> {
  List<Map<String, dynamic>> _allOwners = [];
  List<Map<String, dynamic>> _filteredOwners = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _filteredChats = [];
  bool _isChatsLoading = true;
  bool _showChats = true;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChatsList();
    _fetchOwners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChatsList() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${ApiConstants.baseUrl}${ApiConstants.ownerCommunities}/personal-chat/list');
      if (response.statusCode == 200) {
        final List<dynamic> fetched = response.data['data'] ?? [];
        final list = List<Map<String, dynamic>>.from(fetched);
        if (mounted) {
          setState(() {
            _chats = list;
            _filteredChats = list;
            _isChatsLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      AppLogger.error('Error fetching personal chats list: $e');
    }
    if (mounted) {
      setState(() {
        _isChatsLoading = false;
      });
    }
  }

  String _formatChatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
        return '$hour:$min $ampm';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _fetchOwners() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${ApiConstants.ownerCommunities}/all-owners');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final list = List<Map<String, dynamic>>.from(data);
        if (mounted) {
          setState(() {
            _allOwners = list;
            _filteredOwners = list;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      AppLogger.error('Error fetching owners list: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      final lowercaseQuery = query.toLowerCase();
      
      if (_showChats) {
        if (query.trim().isEmpty) {
          _filteredChats = _chats;
        } else {
          _filteredChats = _chats.where((c) {
            final name = (c['name'] as String? ?? '').toLowerCase();
            final lastMsg = (c['lastMessage']?['text'] as String? ?? '').toLowerCase();
            return name.contains(lowercaseQuery) || lastMsg.contains(lowercaseQuery);
          }).toList();
        }
      } else {
        if (query.trim().isEmpty) {
          _filteredOwners = _allOwners;
        } else {
          _filteredOwners = _allOwners.where((o) {
            final name = (o['name'] as String? ?? '').toLowerCase();
            final city = (o['city'] as String? ?? '').toLowerCase();
            final address = (o['address'] as String? ?? '').toLowerCase();
            final state = (o['state'] as String? ?? '').toLowerCase();
            
            return name.contains(lowercaseQuery) ||
                city.contains(lowercaseQuery) ||
                address.contains(lowercaseQuery) ||
                state.contains(lowercaseQuery);
          }).toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _showChats,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_showChats) {
          _searchController.clear();
          _filterData('');
          setState(() {
            _showChats = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        floatingActionButton: _showChats
            ? FloatingActionButton(
                onPressed: () {
                  _searchController.clear();
                  _filterData('');
                  setState(() {
                    _showChats = false;
                  });
                },
                backgroundColor: AppColors.primaryBlue,
                shape: const CircleBorder(),
                child: Icon(Icons.add, color: Colors.white, size: 24.sp),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              Expanded(
                child: _showChats
                    ? (_isChatsLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : _buildChatsList())
                    : (_isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : _filteredOwners.isEmpty
                            ? _buildEmptyState()
                            : _buildOwnersList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          BouncingWrapper(
            onTap: () {
              if (!_showChats) {
                _searchController.clear();
                _filterData('');
                setState(() {
                  _showChats = true;
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showChats ? "Personal Chats" : "Global Community Members",
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _showChats
                    ? (_isChatsLoading
                        ? (_isLoading ? "Recent conversations" : "Recent conversations • ${_allOwners.length} owners")
                        : (_isLoading ? "Recent conversations (${_chats.length})" : "Recent conversations (${_chats.length}) • ${_allOwners.length} owners"))
                    : (_isLoading
                        ? "Registered staying partners and hosts"
                        : "Registered staying partners and hosts (${_allOwners.length})"),
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: _showChats
                    ? 'Search by name or message...'
                    : 'Search by name, area or address...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            BouncingWrapper(
              onTap: () {
                _searchController.clear();
                _filterData('');
              },
              child: Container(
                padding: EdgeInsets.all(6.r),
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.greyText,
                  size: 14.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOwnersList() {
    return RefreshIndicator(
      onRefresh: () async {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _isLoading = true;
        });
        await _fetchOwners();
      },
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: _filteredOwners.length,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          final o = _filteredOwners[index];
          final avatarUrl = o['avatar'] as String?;
          final name = o['name'] as String;
          final fullAddress = o['address'] as String? ?? '';
          
          return BouncingWrapper(
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              );
              try {
                final dio = sl<Dio>();
                final response = await dio.post(
                  '${ApiConstants.baseUrl}${ApiConstants.ownerCommunities}/personal-chat/get-or-create',
                  data: {'targetUserId': o['id']},
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (response.statusCode == 200) {
                  final chatData = response.data['data'];
                  _searchController.clear();
                  _filterData('');
                  setState(() {
                    _showChats = true;
                  });
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalChatPage(
                        chatId: chatData['id'],
                        otherUserName: name,
                        otherUserAvatar: avatarUrl ?? '',
                        isOnline: chatData['isOnline'] ?? false,
                      ),
                    ),
                  );
                  _fetchChatsList();
                }
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                debugPrint('Error starting personal chat: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to start chat. Please retry.')),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(ApiConstants.getImageUrl(avatarUrl)!)
                        : null,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Icon(
                            Icons.person_rounded,
                            color: AppColors.primaryBlue,
                            size: 24.sp,
                          )
                        : null,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (fullAddress.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.home_work_rounded,
                                size: 12.sp,
                                color: AppColors.greyText.withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  fullAddress,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.sp,
                                    color: AppColors.greyText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Container(
        height: 400.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 12.h),
            Text(
              "No Owners Found",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Try searching for another name, area, or address details.",
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    return RefreshIndicator(
      onRefresh: _fetchChatsList,
      color: AppColors.primaryBlue,
      child: _filteredChats.isEmpty
          ? _buildEmptyChatsState()
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              itemCount: _filteredChats.length,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                final avatarUrl = chat['avatar'] as String?;
                final name = chat['name'] as String? ?? 'PG Owner';
                final lastMsg = chat['lastMessage']?['text'] as String? ?? 'No messages yet';
                final time = _formatChatTime(chat['lastMessage']?['createdAt']);
                final isOnline = chat['isOnline'] as bool? ?? false;

                return BouncingWrapper(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalChatPage(
                          chatId: chat['id'],
                          otherUserName: name,
                          otherUserAvatar: avatarUrl ?? '',
                          isOnline: isOnline,
                        ),
                      ),
                    );
                    _fetchChatsList();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 22.r,
                              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? CachedNetworkImageProvider(ApiConstants.getImageUrl(avatarUrl)!)
                                  : null,
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                              child: (avatarUrl == null || avatarUrl.isEmpty)
                                  ? Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 24.sp,
                                    )
                                  : null,
                            ),
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12.r,
                                  height: 12.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (time.isNotEmpty)
                                    Text(
                                      time,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.sp,
                                        color: AppColors.greyText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                lastMsg,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyChatsState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Container(
        height: 400.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 12.h),
            Text(
              "No Chats Yet",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Start a conversation with other owners by clicking the '+' button.",
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
