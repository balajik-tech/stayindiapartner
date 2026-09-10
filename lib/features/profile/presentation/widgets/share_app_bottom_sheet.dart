import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

class ShareAppBottomSheet extends StatefulWidget {
  const ShareAppBottomSheet({
    super.key,
    this.appName = 'Stay India Partner',
    this.appTagline = 'Manage Simply · Grow Rapidly',
    this.shareLink = 'https://stayindia.in/partner',
    this.shareMessage =
    'I run my PG on Stay India Partner — bookings, beds, rent and '
        'tenants in one place. Manage simply, grow rapidly:',
    this.appIconAsset = 'assets/images/login_logo_nobg.png',
  });

  final String appName;
  final String appTagline;
  final String shareLink;
  final String shareMessage;
  final String appIconAsset;

  static Future<void> show(
      BuildContext context, {
        String appName = 'Stay India Partner',
        String appTagline = 'Manage Simply · Grow Rapidly',
        String shareLink = 'https://stayindia.in/partner',
        String shareMessage =
        "Hi! I’ve been using Stay India Partner for my PG, and it's a game-changer. "
            "Get 100% verified tenants with lifetime free leads—no broker commissions! "
            "Easily manage beds, rent, and tenants all in one place. "
            "Download the app and grow your business rapidly:",
        String appIconAsset = 'assets/images/app_icon.png',
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareAppBottomSheet(
        appName: appName,
        appTagline: appTagline,
        shareLink: shareLink,
        shareMessage: shareMessage,
        appIconAsset: appIconAsset,
      ),
    );
  }

  @override
  State<ShareAppBottomSheet> createState() =>
      _ShareAppBottomSheetState();
}

class _ShareAppBottomSheetState
    extends State<ShareAppBottomSheet> {

  bool _isActionInProgress = false;

  String get _fullMessage =>
      '${widget.shareMessage} ${widget.shareLink}';

  /// Only one action can run at a time.
  Future<void> _runAction(
      Future<void> Function() action,
      ) async {
    if (_isActionInProgress) {
      return;
    }

    // Lock immediately.
    _isActionInProgress = true;

    try {
      await action();
    } catch (e) {
      debugPrint('Share action error: $e');
    } finally {
      _isActionInProgress = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 4),
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildAppCard(),
            const SizedBox(height: 16),
            _buildMessageCard(context),
            const SizedBox(height: 16),
            _buildShareActionsRow(context),
            const SizedBox(height: 16),
            _buildOrDivider(),
            const SizedBox(height: 16),
            _buildQrSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFCECECE),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'refer_friend'.tr(),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.grey,
          ),
          onPressed: _isActionInProgress
              ? null
              : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildAppCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.appTagline,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF575654),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shareMessage,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.4,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(
            height: 0,
            thickness: 0.2,
            color: Color(0xFFCECECE),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                'assets/images/link.png',
                width: 14,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.shareLink,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Your personal invite link',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF52514F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: _isActionInProgress
                      ? null
                      : () => _runAction(
                        () => _copyLink(context),
                  ),
                  child: Text(
                    'Copy',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ShareActionButton(
          icon: Icons.chat_bubble,
          image: 'assets/images/whatsapp_icon.png',
          iconColor: const Color(0xFF25D366),
          backgroundColor: const Color(0xFFD9F2DE),
          label: 'WhatsApp',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(
                () => _shareViaWhatsApp(context),
          ),
        ),

        _ShareActionButton(
          icon: Icons.sms,
          image: 'assets/images/comment.png',
          iconColor: const Color(0xFF1565C0),
          backgroundColor: const Color(0xFFD6E7FA),
          label: 'SMS',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(
                () => _shareViaSms(context),
          ),
        ),

        _ShareActionButton(
          icon: Icons.copy_all_outlined,
          image: 'assets/images/copy.png',
          iconColor: Colors.black87,
          backgroundColor: Colors.white,
          label: 'Copy link',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(
                () => _copyLink(context),
          ),
        ),

        _ShareActionButton(
          icon: Icons.more_horiz,
          image: '',
          iconColor: Colors.black87,
          backgroundColor: Colors.white,
          label: 'More',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(
                () => _shareViaSystemSheet(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Text(
            'or share in person',
            style: GoogleFonts.inter(
              color: const Color(0xFF898782),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildQrSection(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isActionInProgress
          ? null
          : () => _showEnlargedQr(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            QrImageView(
              data: widget.shareLink,
              version: QrVersions.auto,
              size: 64,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan to download',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to enlarge for scanning',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF52514F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.shareLink,
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
        ),
      );
    }
  }

  Future<void> _shareViaWhatsApp(
      BuildContext context,
      ) async {
    final uri = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(_fullMessage)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      await _shareViaSystemSheet(context);
    }
  }

  Future<void> _shareViaSms(
      BuildContext context,
      ) async {
    final uri = Uri(
      scheme: 'sms',
      path: '',
      queryParameters: {
        'body': _fullMessage,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      await _shareViaSystemSheet(context);
    }
  }

  Future<void> _shareViaSystemSheet(
      BuildContext context,
      ) async {
    await Share.share(
      _fullMessage,
      subject: widget.appName,
    );
  }

  void _showEnlargedQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan to download',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: widget.shareLink,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareActionButton extends StatelessWidget {
  const _ShareActionButton({
    required this.icon,
    required this.image,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String image;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: backgroundColor,
            child: Center(
              child: image.isNotEmpty ?
              Container(
                margin: EdgeInsets.only(top: 3,left: 3),
                  child: Image.asset(image,width: 24,height: 24,color: iconColor)) : Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style:  GoogleFonts.inter(fontSize: 13,color: Color(0xFF646361),fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
