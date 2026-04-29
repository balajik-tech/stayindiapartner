import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/chat_message_bubble.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TenantsChatPage extends StatefulWidget {
  final String hostelId;
  final String? communityName;
  final String? communityIcon;
  final String? communityDescription;

  const TenantsChatPage({
    super.key,
    required this.hostelId,
    this.communityName,
    this.communityIcon,
    this.communityDescription,
  });

  @override
  State<TenantsChatPage> createState() => _TenantsChatPageState();
}

class _TenantsChatPageState extends State<TenantsChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    final cubit = context.read<CommunityCubit>();
    final ownerId = context.read<AuthCubit>().currentOwner?.id;
    if (ownerId != null) {
      cubit.joinCommunity(widget.hostelId, ownerId);
    }

    
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 40) {
      context.read<CommunityCubit>().loadOlderMessages(widget.hostelId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<CommunityCubit>().sendMessage(widget.hostelId, text);
      _controller.clear();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommunityCubit, CommunityState>(
              builder: (context, state) {
                if (state is CommunityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommunityLoaded) {
                  final messages = state.messages;
                  
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64.sp, color: Colors.grey.shade300),
                          SizedBox(height: 16.h),
                          Text(
                            'No messages yet',
                            style: GoogleFonts.outfit(fontSize: 16.sp, color: AppColors.greyText),
                          ),
                        ],
                      ),
                    );
                  }

                  
                  final itemCount = messages.length + 1; 
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(20.w),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      
                      if (index == 0) {
                        if (state.isLoadingMoreMessages) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                          );
                        }
                        if (!state.hasMoreMessages) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                ' Beginning of conversation',
                                style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.greyText),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final message = messages[index - 1]; 
                      
                      final owner = context.read<AuthCubit>().currentOwner;
                      final currentOwnerId = owner?.id;

                      final isMe = (currentOwnerId != null && 
                                   message.senderId.isNotEmpty && 
                                   message.senderId == currentOwnerId);
                      
                      final updatedMessage = CommunityMessageEntity(
                        id: message.id,
                        senderId: message.senderId,
                        senderName: message.senderName,
                        senderAvatar: message.senderAvatar,
                        text: message.text,
                        createdAt: message.createdAt,
                        type: message.type,
                        isSystem: message.isSystem,
                        isMe: isMe,
                      );

                      return ChatMessageBubble(message: updatedMessage);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: BouncingWrapper(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
      ),
      title: BouncingWrapper(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityDetailPage(communityId: widget.hostelId),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                image: widget.communityIcon != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(widget.communityIcon!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.communityIcon == null
                  ? Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 20.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.communityName ?? 'Tenants Community',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    'Tap for info',
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: const [],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h), 
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.outfit(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          BouncingWrapper(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
