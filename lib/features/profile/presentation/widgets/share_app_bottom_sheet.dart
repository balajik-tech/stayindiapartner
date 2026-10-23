import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Referral invite; `{link}` is replaced with the owner's referral link.
  static const String referralMessage = '🚀 ATTENTION PG OWNERS! 🏢\n'
      'GO DIGITAL WITH STAY INDIA!\n'
      '\n'
      '✅ Unlimited Free Tenant Leads\n'
      '🛡️ Verified Tenant Management\n'
      '💰 Automated Rent Reminders\n'
      '🛏️ Smart Bed Management\n'
      '📲 Paperless, Stress-Free Operations\n'
      '\n'
      '🎁 BONUS: 1-Month FREE Trial – Full Access!\n'
      '\n'
      '📥 Download Now 👇\n'
      '{link}\n'
      '\n'
      '🇮🇳 Stay India – The Future of Living!';

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
        String shareMessage = referralMessage,
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

  String get _fullMessage => widget.shareMessage.contains('{link}')
      ? widget.shareMessage.replaceAll('{link}', widget.shareLink)
      : '${widget.shareMessage} ${widget.shareLink}';

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
    final media = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + media.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 8),
            _buildHeader(context),
            const SizedBox(height: 16),
            // Only the middle scrolls; the header and share buttons stay visible.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageCard(),
                    const SizedBox(height: 12),
                    _buildLinkCard(context),
                    const SizedBox(height: 12),
                    _buildQrSection(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildShareActionsRow(context),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'refer_friend'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Invite PG owners to ${widget.appName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B6A67),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _isActionInProgress
              ? null
              : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Preview of exactly what gets shared, with the link highlighted.
  Widget _buildMessageCard() {
    final base = GoogleFonts.inter(
      fontSize: 13.5,
      height: 1.5,
      color: const Color(0xFF1F1F1E),
      fontWeight: FontWeight.w500,
    );
    final headline = base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    );
    final link = base.copyWith(
      color: AppColors.primaryBlue,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryBlue,
    );

    // Paragraphs are separated by blank lines; the first one is the headline
    // and the last one is the sign-off.
    final paragraphs = _fullMessage.split('\n\n');
    final children = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      final isFirst = i == 0;
      final isLast = i == paragraphs.length - 1 && paragraphs.length > 1;
      final style = isFirst
          ? headline
          : isLast
              ? base.copyWith(fontWeight: FontWeight.w700)
              : base;

      final parts = paragraphs[i].split(widget.shareLink);
      final spans = <TextSpan>[];
      for (var j = 0; j < parts.length; j++) {
        spans.add(TextSpan(text: parts[j]));
        if (j < parts.length - 1) {
          spans.add(TextSpan(text: widget.shareLink, style: link));
        }
      }

      if (i > 0) children.add(const SizedBox(height: 10));
      children.add(Text.rich(TextSpan(style: style, children: spans)));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLinkCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shareLink,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your personal invite link',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF6B6A67),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _isActionInProgress
                ? null
                : () => _runAction(() => _copyLink(context)),
            icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryBlue),
            label: Text(
              'Copy',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareActionsRow(BuildContext context) {
    return Row(
      children: [
        _ShareActionButton(
          icon: Icons.chat_bubble,
          image: 'assets/images/whatsapp_icon.png',
          iconColor: const Color(0xFF25D366),
          backgroundColor: const Color(0xFFD9F2DE),
          label: 'WhatsApp',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(() => _shareViaWhatsApp(context)),
        ),
        _ShareActionButton(
          icon: Icons.sms,
          image: 'assets/images/comment.png',
          iconColor: const Color(0xFF1565C0),
          backgroundColor: const Color(0xFFD6E7FA),
          label: 'SMS',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(() => _shareViaSms(context)),
        ),
        _ShareActionButton(
          icon: Icons.ios_share_rounded,
          image: '',
          iconColor: Colors.black87,
          backgroundColor: const Color(0xFFEEEFF1),
          label: 'More',
          onTap: _isActionInProgress
              ? () {}
              : () => _runAction(() => _shareViaSystemSheet(context)),
        ),
      ].map((button) => Expanded(child: button)).toList(),
    );
  }

  Widget _buildQrSection(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isActionInProgress
          ? null
          : () => _showEnlargedQr(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EAED)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: QrImageView(
                data: widget.shareLink,
                version: QrVersions.auto,
                size: 56,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share in person',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to enlarge the QR code for scanning',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B6A67),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
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
    await SharePlus.instance.share(
      ShareParams(text: _fullMessage, subject: widget.appName),
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
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13,color: Color(0xFF646361),fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
