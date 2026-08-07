import 'package:equatable/equatable.dart';

/// Theme tokens for this screen. Colors are kept as hex strings in the
/// domain layer so it stays framework-agnostic; the presentation layer
/// converts them to `Color`. This is designed to be swapped for a real
/// remote datasource (API) later without touching the UI code.
class CommunityThemeEntity extends Equatable {
  final String primaryColor;
  final String primaryColorLight;
  final String accentColor;
  final String backgroundColor;
  final String cardColor;
  final String textOnPrimary;
  final String textPrimary;
  final String textSecondary;
  final String badgeBackground;
  final String badgeBorder;
  final String badgeText;

  const CommunityThemeEntity({
    required this.primaryColor,
    required this.primaryColorLight,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textOnPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
  });

  @override
  List<Object?> get props => [
    primaryColor,
    primaryColorLight,
    accentColor,
    backgroundColor,
    cardColor,
    textOnPrimary,
    textPrimary,
    textSecondary,
    badgeBackground,
    badgeBorder,
    badgeText,
  ];
}