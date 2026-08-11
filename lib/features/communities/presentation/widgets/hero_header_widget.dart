import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/community_theme_entity.dart';
import 'associate_info_sheets.dart';
import 'hex_color.dart';

class HeroHeaderWidget extends StatelessWidget {
  final CommunityThemeEntity theme;
  const HeroHeaderWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final primaryLight = theme.primaryColorLight.toColor();
    final accent = theme.accentColor.toColor();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primaryLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _iconButton(Icons.phone, accent),
              const SizedBox(width: 10),
              _iconButton(Icons.campaign_outlined, accent),
              // const SizedBox(width: 10),
              // _iconButton(Icons.wb_sunny_outlined, accent),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'TAMIL NADU',
                style: GoogleFonts.inter(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'IT Hostels & PG Owners',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      'Welfare Association',
                      style: GoogleFonts.inter(
                        color: accent,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LogoBadge(accent: accent),
            ],
          ),
          const SizedBox(height: 16),
           Text(
            'United for the welfare of hostel & PG owners across Tamil Nadu',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
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
              _PillButton(
                label: 'Donations',
                onPressed: () => _showSheet(context, 'Donations'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssociateInfoSheet(type: type, theme: theme),
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
  const _LogoBadge({required this.accent});

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
      child: Image.asset(
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
  const _PillButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
    );
  }
}