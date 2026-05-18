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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stayindia_owner/core/utils/image_compressor.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';

class TenantsChatPage extends StatelessWidget {
  final String hostelId;
  final String? communityName;
  final String? communityIcon;
  final String? communityDescription;
  final bool isOwnerChat;
  final String? status;

  const TenantsChatPage({
    super.key,
    required this.hostelId,
    this.communityName,
    this.communityIcon,
    this.communityDescription,
    this.isOwnerChat = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return const _TenantsChatView();
  }
}

class _TenantsChatView extends StatefulWidget {
  const _TenantsChatView();

  @override
  State<_TenantsChatView> createState() => _TenantsChatViewState();
}

class _TenantsChatViewState extends State<_TenantsChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CommunityCubit>();
      final ownerId = context.read<AuthCubit>().currentOwner?.id;
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;

      if (ownerId != null) {
        cubit.loadCommunityData(page.hostelId);
        cubit.joinCommunity(page.hostelId, ownerId);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 40) {
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
      context.read<CommunityCubit>().loadOlderMessages(page.hostelId);
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
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
      final owner = context.read<AuthCubit>().currentOwner;

      context.read<CommunityCubit>().sendMessage(
        page.hostelId,
        text,
        senderId: owner?.id,
        senderName: owner?.name,
        senderAvatar: owner?.avatar,
      );
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compressing and sending image...')),
      );

      final compressedFile = await ImageCompressor.compressImage(
        File(image.path),
      );
      if (compressedFile != null) {
        if (!mounted) return;
        final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
        final owner = context.read<AuthCubit>().currentOwner;

        context.read<CommunityCubit>().sendImageMessage(
          page.hostelId,
          compressedFile.path,
          senderId: owner?.id,
          senderName: owner?.name,
          senderAvatar: owner?.avatar,
        );
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
    final isPending = page.status?.toUpperCase() == 'PENDING';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, page),
      body: isPending
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 64.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Verification Pending',
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your community is currently under review by our executive team. Once verified, chat and media sharing features will be instantly enabled.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        color: AppColors.greyText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: const CustomPaint(
                    painter: ChatWallpaperPainter(),
                  ),
                ),
                Column(
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
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          }
                        });

                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 64.sp,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No messages yet',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    color: AppColors.greyText,
                                  ),
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
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (!state.hasMoreMessages) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: Text(
                                      ' Beginning of conversation',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.sp,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final message = messages[index - 1];

                            final owner = context
                                .read<AuthCubit>()
                                .currentOwner;
                            final currentOwnerId = owner?.id;

                            final isMe =
                                (currentOwnerId != null &&
                                message.senderId.isNotEmpty &&
                                message.senderId == currentOwnerId);

                            final updatedMessage = CommunityMessageEntity(
                              id: message.id,
                              senderId: message.senderId,
                              senderName: message.senderName,
                              senderAvatar: message.senderAvatar,
                              text: message.text,
                              imageUrl: message.imageUrl,
                              roomId: message.roomId,
                              createdAt: message.createdAt,
                              type: message.type,
                              isSystem: message.isSystem,
                              isMe: isMe,
                            );

                            return ChatMessageBubble(message: updatedMessage);
                          },
                        );
                      }
                      if (state is CommunityError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 48.sp,
                                  color: Colors.red.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.greyText,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: () {
                                    final page = context
                                        .findAncestorWidgetOfExactType<
                                          TenantsChatPage
                                        >()!;
                                    context
                                        .read<CommunityCubit>()
                                        .loadCommunityData(page.hostelId);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _buildInputSection(page),
              ],
            ),
          ],
        ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TenantsChatPage page) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: BouncingWrapper(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              image: page.communityIcon != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(page.communityIcon!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: page.communityIcon == null
                ? Icon(
                    Icons.groups_rounded,
                    color: AppColors.primaryBlue,
                    size: 20.sp,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.communityName ?? 'Tenants Community',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                ),
                if (page.isOwnerChat)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      page.status?.toUpperCase() == 'PENDING'
                          ? 'Verification Pending ⏳'
                          : 'Verified National Network',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: page.status?.toUpperCase() == 'PENDING'
                            ? Colors.orange.shade700
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (page.isOwnerChat)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: BouncingWrapper(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CommunityDetailPage(communityId: page.hostelId),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 22.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputSection(TenantsChatPage page) {
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
          if (page.isOwnerChat) ...[
            BouncingWrapper(
              onTap: _pickAndSendImage,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
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
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatWallpaperPainter extends CustomPainter {
  const ChatWallpaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintColor = Colors.black.withValues(alpha: 0.045); // subtle background icons

    final icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.local_phone_outlined,
      Icons.camera_alt_outlined,
      Icons.music_note_outlined,
      Icons.favorite_border_rounded,
      Icons.sentiment_satisfied_alt_outlined,
      Icons.coffee_outlined,
      Icons.lightbulb_outline_rounded,
      Icons.star_border_rounded,
      Icons.wb_sunny_outlined,
      Icons.directions_bike_outlined,
      Icons.umbrella_outlined,
      Icons.photo_outlined,
      Icons.pets_outlined,
      Icons.cloud_queue_rounded,
      Icons.explore_outlined,
      Icons.brush_outlined,
      Icons.headset_mic_outlined,
      Icons.anchor_outlined,
      Icons.watch_later_outlined,
      Icons.sailing_outlined,
      Icons.flight_outlined,
      Icons.cake_outlined,
      Icons.edit_outlined,
    ];

    const double gridStep = 55.0; // high-density WhatsApp layout
    int rowIndex = 0;

    for (double y = 25.0; y < size.height; y += gridStep) {
      final double xStart = (rowIndex % 2 == 0) ? 25.0 : 25.0 + (gridStep / 2);
      for (double x = xStart; x < size.width; x += gridStep) {
        final int seed = (x.toInt() * 7 + y.toInt() * 13).abs();
        
        final icon = icons[seed % icons.length];
        
        final double angleDegrees = ((seed % 90) - 45).toDouble();
        final double angleRadians = angleDegrees * 3.141592653589793 / 180.0;
        
        final double fontSize = 15.0 + (seed % 8);
        
        final double jitterX = ((seed % 20) - 10).toDouble();
        final double jitterY = (((seed >> 2) % 20) - 10).toDouble();

        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: paintColor,
            ),
          ),
        );
        
        textPainter.layout();
        
        canvas.save();
        canvas.translate(x + jitterX, y + jitterY);
        canvas.rotate(angleRadians);
        
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        
        canvas.restore();
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
