import 'package:equatable/equatable.dart';

/// A single member of the State Executive Committee
/// (President, Secretary, Treasurer, Vice President, Joint Secretary).
class CommitteeMemberEntity extends Equatable {
  final String id; // e.g. TNIT-EC-01
  final String name;
  final String position;
  final String photoUrl;
  final String phone;

  /// true => President / Secretary / Treasurer (bold + blue in UI)
  /// false => Vice President / Joint Secretary (muted gray in UI)
  final bool isHighlighted;

  const CommitteeMemberEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.photoUrl,
    required this.phone,
    this.isHighlighted = false,
  });

  @override
  List<Object?> get props => [id, name, position, photoUrl, isHighlighted];
}