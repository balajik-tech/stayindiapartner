import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/community_theme_entity.dart';
import '../../domain/entities/association_details_entity.dart';
import 'associate_info_sheets.dart';
import 'hex_color.dart';

class HeroHeaderWidget extends StatelessWidget {
  final CommunityThemeEntity theme;
  final AssociationDetailsEntity? details;
  final String? detailsError;

  HeroHeaderWidget({
    super.key,
    required this.theme,
    this.details,
    this.detailsError,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

    final name = details?.name.toUpperCase() ?? '';
    final nameWords = name.split(' ');
    final firstNamePart = nameWords.length > 2 
        ? nameWords.take(nameWords.length - 2).join(' ') 
        : nameWords.first;
    final lastTwoWords = nameWords.length > 2 
        ? nameWords.skip(nameWords.length - 2).join(' ') 
        : nameWords.skip(1).join(' ');
    final location = details?.address.toUpperCase();
    final phoneNumber = details?.phone;

    final description = details?.about.description.trim().isNotEmpty == true
        ? details!.about.description
        : '';


    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _makePhoneCall(phoneNumber!),
                child: _iconButton(Icons.phone, accent),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _speak(description),
                child: _iconButton(Icons.campaign_outlined, accent),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                   location ?? '',
                  softWrap: true,
                  style: GoogleFonts.inter(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: Container(height: 1, color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstNamePart,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    lastTwoWords,
                    style: GoogleFonts.inter(
                      color: accent,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (details?.about.description != null &&
                        details!.about.description.isNotEmpty)
                        ? details!.about.description
                        : '',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Transform.translate(
              offset: const Offset(0, -10),
              child: _LogoBadge(
                accent: accent,
                logoUrl: details?.logo,
              ),
            ),
          ],
        ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PillButton(
                label: 'About Us',
                onPressed: () => _showSheet(context, 'About Us'),
              ),
              _PillButton(
                label: 'By Laws',
                onPressed: () => _showSheet(context, 'By Laws'),
              ),
              _PillButton(
                label: 'Founders',
                onPressed: () => _showSheet(context, 'Founders'),
              ),
              // _PillButton(
              //   label: 'Donations',
              //   onPressed: () => _showSheet(context, 'Donations'),
              // ),
              if (details?.rulesRegulations != null && details!.rulesRegulations!.contents.isNotEmpty)...[
                _PillButton(
                  label: 'Rules & Regulation',
                  onPressed: () => _showSheet(context, 'Rules'),
                )
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (detailsError != null && detailsError!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detailsError!,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  void _showSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssociateInfoSheet(type: type, theme: theme, details: details),
    );
  }

  Widget _iconButton(IconData icon, Color accent) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white10,
      child: Icon(icon, color: accent, size: 18),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final Color accent;
  final String? logoUrl;
  const _LogoBadge({required this.accent, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accent,
          width: 2,
        ),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: (logoUrl != null && logoUrl!.isNotEmpty && ApiConstants.getImageUrl(logoUrl) != null)
          ? ClipOval(
              child: Image.network(
                ApiConstants.getImageUrl(logoUrl)!,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/images/associate_logo.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.fill,
                ),
              ),
            )
          : Image.asset(
              'assets/images/associate_logo.png',
              width: 92,
              height: 92,
              fit: BoxFit.fill,
            ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}