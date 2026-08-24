import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/domain/entities/association_portal_entity.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';

import 'community_home_page.dart';


class AssociationSearchPage extends StatefulWidget {
  const AssociationSearchPage({super.key});

  @override
  State<AssociationSearchPage> createState() => _AssociationSearchPageState();
}

class _AssociationSearchPageState extends State<AssociationSearchPage> {
  static const _recentSearchesKey = 'owner_community_recent_association_searches';
  static const _maxRecents = 6;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<_RecentAssociation> _recents = [];
  bool _loadingRecents = true;

  @override
  void initState() {
    super.initState();
    _loadRecents();
    // Defensive refresh in case this page is opened before the cubit has
    // ever loaded associations (e.g. deep link).
    context.read<OwnerCommunityCubit>().loadCommunities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_recentSearchesKey) ?? [];
      setState(() {
        _recents = stored
            .map((s) {
              try {
                return _RecentAssociation.fromJson(jsonDecode(s));
              } catch (_) {
                return null;
              }
            })
            .whereType<_RecentAssociation>()
            .toList();
        _loadingRecents = false;
      });
    } catch (e) {
      AppLogger.error('Error loading recent association searches: $e');
      setState(() => _loadingRecents = false);
    }
  }

  Future<void> _addToRecents(AssociationPortalEntity a) async {
    final entry = _RecentAssociation(id: a.id, name: a.name, logo: a.logo);
    setState(() {
      _recents.removeWhere((r) => r.id == entry.id);
      _recents.insert(0, entry);
      if (_recents.length > _maxRecents) {
        _recents = _recents.sublist(0, _maxRecents);
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _recentSearchesKey,
        _recents.map((r) => jsonEncode(r.toJson())).toList(),
      );
    } catch (e) {
      AppLogger.error('Error saving recent association searches: $e');
    }
  }

  void _openAssociation(AssociationPortalEntity a) {
    _addToRecents(a);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssociateHomePage(associationId: a.id),
      ),
    );
  }

  void _openRecent(_RecentAssociation r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssociateHomePage(associationId: r.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(query),
            const Divider(height: 1),
            Expanded(
              child: query.isEmpty
                  ? _buildRecentsSection()
                  : BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
                      builder: (context, state) {
                        final List<CommunityDetailsEntity> joined =
                            state is OwnerCommunityLoaded
                                ? state.joinedCommunities
                                : <CommunityDetailsEntity>[];
                        // NOTE: assumes CommunityDetailsEntity exposes an
                        // `id` matching AssociationPortalEntity.id. Adjust
                        // the field name here if it differs in your entity.
                        final joinedIds = joined.map((c) => c.id).toSet();

                        final associations = state is OwnerCommunityLoaded
                            ? state.associations
                            : <AssociationPortalEntity>[];

                        final results = associations
                            .where((a) => a.name
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();

                        if (results.isEmpty) {
                          return _buildNoResults(query);
                        }

                        return _buildResultsList(results, joinedIds, query);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(String query) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: _searchFocusNode.hasFocus
                      ? AppColors.primaryBlue
                      : Colors.grey.shade300,
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: AppColors.primaryBlue, size: 22.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search associations',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.greyText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (query.isNotEmpty)
                    BouncingWrapper(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.cancel_rounded,
                        color: Colors.grey.shade400,
                        size: 18.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  color: AppColors.darkText, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentsSection() {
    if (_loadingRecents) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded,
                  size: 48.sp, color: Colors.grey.shade300),
              SizedBox(height: 12.h),
              Text(
                'No recent searches',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Associations you open will show up here',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
          child: Text(
            'RECENT',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grayColor3,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ..._recents.map((r) => _RecentTile(
              recent: r,
              onTap: () => _openRecent(r),
            )),
      ],
    );
  }

  Widget _buildResultsList(
    List<AssociationPortalEntity> results,
    Set<String> joinedIds,
    String query,
  ) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20.w,
        endIndent: 20.w,
        color: Colors.grey.shade100,
      ),
      itemBuilder: (context, index) {
        final a = results[index];
        return _AssociationResultTile(
          association: a,
          query: query,
          isJoined: joinedIds.contains(a.id),
          onTap: () => _openAssociation(a),
        );
      },
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                color: Colors.grey.shade400,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No associations found',
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Nothing matched "$query". Try a different spelling or search by city.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.greyText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row for an item in the "RECENT" list.
class _RecentTile extends StatelessWidget {
  final _RecentAssociation recent;
  final VoidCallback onTap;

  const _RecentTile({required this.recent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            _AssociationAvatar(name: recent.name, logo: recent.logo, size: 44),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recent.name,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // NOTE: city / member count placeholders below mirror the
                  // existing "Suggested near you" tile in
                  // OwnersCommunityPage, since AssociationPortalEntity does
                  // not currently expose these fields. Wire up real values
                  // here once the entity/API surfaces them.
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

/// Row for a search result, with the matching substring highlighted and a
/// checkmark shown if the owner has already joined that association.
class _AssociationResultTile extends StatelessWidget {
  final AssociationPortalEntity association;
  final String query;
  final bool isJoined;
  final VoidCallback onTap;

  const _AssociationResultTile({
    required this.association,
    required this.query,
    required this.isJoined,
    required this.onTap,
  });

  List<TextSpan> _highlightedName() {
    final name = association.name;
    final lowerName = name.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerQuery.isEmpty ? -1 : lowerName.indexOf(lowerQuery);

    final baseStyle = GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    );
    final matchStyle = GoogleFonts.inter(
      fontSize: 15.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.primaryBlue,
    );

    if (matchIndex < 0) {
      return [TextSpan(text: name, style: baseStyle)];
    }

    final before = name.substring(0, matchIndex);
    final match = name.substring(matchIndex, matchIndex + query.length);
    final after = name.substring(matchIndex + query.length);

    return [
      if (before.isNotEmpty) TextSpan(text: before, style: baseStyle),
      TextSpan(text: match, style: matchStyle),
      if (after.isNotEmpty) TextSpan(text: after, style: baseStyle),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            _AssociationAvatar(
              name: association.name,
              logo: association.logo,
              size: 44,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(children: _highlightedName()),
              ),
            ),
            SizedBox(width: 8.w),
            isJoined
                ? Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 16.sp),
                  )
                : Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar with the association logo, falling back to a colored
/// initials badge when there's no logo (matches "AH" / "LS" style badges
/// in the design).
class _AssociationAvatar extends StatelessWidget {
  final String name;
  final String logo;
  final double size;

  const _AssociationAvatar({
    required this.name,
    required this.logo,
    this.size = 44,
  });

  static const List<Color> _palette = [
    Color(0xFF1D2B4F),
    Color(0xFF3E6259),
    Color(0xFFB08B3E),
    Color(0xFF23408E),
    Color(0xFF6B4A8A),
    Color(0xFF9A3B3B),
  ];

  Color get _bgColor {
    if (name.isEmpty) return _palette.first;
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, words.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = logo.isNotEmpty ? ApiConstants.getImageUrl(logo) : null;

    return ClipOval(
      child: Container(
        width: size.w,
        height: size.w,
        color: _bgColor,
        child: (imageUrl != null)
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialsLabel(),
              )
            : _initialsLabel(),
      ),
    );
  }

  Widget _initialsLabel() {
    return Center(
      child: Text(
        _initials,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
        ),
      ),
    );
  }
}

/// Lightweight local model used only to persist the "recent" list.
class _RecentAssociation {
  final String id;
  final String name;
  final String logo;

  _RecentAssociation({required this.id, required this.name, required this.logo});

  factory _RecentAssociation.fromJson(Map<String, dynamic> json) {
    return _RecentAssociation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'logo': logo};
}
