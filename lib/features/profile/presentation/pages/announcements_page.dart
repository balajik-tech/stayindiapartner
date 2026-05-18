import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:intl/intl.dart';

class AnnouncementTemplate {
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;

  AnnouncementTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
  });
}

class SendAnnouncementsPage extends StatefulWidget {
  const SendAnnouncementsPage({super.key});

  @override
  State<SendAnnouncementsPage> createState() => _SendAnnouncementsPageState();
}

class _SendAnnouncementsPageState extends State<SendAnnouncementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  late NoticeCubit _noticeCubit;

  List<String> _getLocalizedCategories(BuildContext context) {
    return [
      StringUtils.translate('category_all', context: context),
      StringUtils.translate('category_food', context: context),
      StringUtils.translate('category_payments', context: context),
      StringUtils.translate('category_maintenance', context: context),
      StringUtils.translate('category_rules', context: context),
      StringUtils.translate('category_events', context: context),
    ];
  }

  List<AnnouncementTemplate> _getLocalizedTemplates(BuildContext context) {
    return [
      AnnouncementTemplate(
        category: StringUtils.translate('category_food', context: context),
        title: StringUtils.translate('template_today_menu_title', context: context),
        description: StringUtils.translate('template_today_menu_desc', context: context),
        icon: Icons.restaurant_rounded,
        color: Colors.orange,
      ),
      AnnouncementTemplate(
        category: StringUtils.translate('category_payments', context: context),
        title: StringUtils.translate('template_rent_reminder_title', context: context),
        description: StringUtils.translate('template_rent_reminder_desc', context: context),
        icon: Icons.payments_rounded,
        color: Colors.green,
      ),
      AnnouncementTemplate(
        category: StringUtils.translate('category_maintenance', context: context),
        title: StringUtils.translate('template_water_update_title', context: context),
        description: StringUtils.translate('template_water_update_desc', context: context),
        icon: Icons.water_drop_rounded,
        color: Colors.blue,
      ),
      AnnouncementTemplate(
        category: StringUtils.translate('category_rules', context: context),
        title: StringUtils.translate('template_gate_timing_title', context: context),
        description: StringUtils.translate('template_gate_timing_desc', context: context),
        icon: Icons.door_front_door_rounded,
        color: Colors.red,
      ),
      AnnouncementTemplate(
        category: StringUtils.translate('category_events', context: context),
        title: StringUtils.translate('template_movie_night_title', context: context),
        description: StringUtils.translate('template_movie_night_desc', context: context),
        icon: Icons.movie_rounded,
        color: Colors.purple,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _noticeCubit = sl<NoticeCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final hostelState = context.read<HostelCubit>().state;
      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
        final index = hostelState.selectedHostelIndex;
        if (index >= 0 && index < hostelState.hostels.length) {
          final hostelId = hostelState.hostels[index].id;
          _noticeCubit.loadNotices(hostelId: hostelId);
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _noticeCubit.close();
    super.dispose();
  }

  List<AnnouncementTemplate> _getFilteredTemplates(BuildContext context) {
    final templates = _getLocalizedTemplates(context);
    final allCategoryLabel = StringUtils.translate('category_all', context: context);
    return templates.where((t) {
      final matchesCategory = _selectedCategory == allCategoryLabel || t.category == _selectedCategory;
      final matchesSearch = t.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final hasNoProperty = hostelState is HostelLoaded && hostelState.hostels.isEmpty;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _noticeCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: hasNoProperty
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    StringUtils.translate('announcements_title', context: context),
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                body: _buildNoPropertyPlaceholder(),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildSliverAppBar(),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTemplatesView(),
                    _buildHistoryView(),
                  ],
                ),
              ),
        bottomNavigationBar: hasNoProperty ? null : _buildWriteNewButton(),
      ),
    );
  }

  Widget _buildNoPropertyPlaceholder() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_rounded,
                size: 64.sp,
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              StringUtils.translate('add_property_first', context: context),
              style: GoogleFonts.dmSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              StringUtils.translate('start_by_adding_property_desc', context: context),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                color: AppColors.greyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        StringUtils.translate('announcements_title', context: context),
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.primaryBlue.withValues(alpha: 0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                top: -20.h,
                child: Icon(Icons.campaign_rounded, size: 200.sp, color: Colors.white.withValues(alpha: 0.1)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BlocBuilder<HostelCubit, HostelState>(
                      builder: (context, state) {
                        String hostelName = "Select Property";
                        if (state is HostelLoaded && state.hostels.isNotEmpty) {
                          final idx = state.selectedHostelIndex;
                          if (idx >= 0 && idx < state.hostels.length) {
                            hostelName = state.hostels[idx].name;
                          }
                        }
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_rounded, color: Colors.white, size: 14.sp),
                              SizedBox(width: 6.w),
                              Text(hostelName, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      StringUtils.translate('broadcasting_center_title', context: context),
                      style: GoogleFonts.dmSans(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      StringUtils.translate('broadcasting_center_desc', context: context),
                      style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 4,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.greyText,
            labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14.sp),
            tabs: [
              Tab(text: StringUtils.translate('templates_tab', context: context)),
              Tab(text: StringUtils.translate('recent_sent_tab', context: context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesView() {
    final filteredTemplates = _getFilteredTemplates(context);
    return Column(
      children: [
        _buildSearchBar(context),
        _buildCategoryFilter(context),
        Expanded(
          child: filteredTemplates.isEmpty
              ? _buildEmptyState(StringUtils.translate('no_templates_found', context: context), Icons.search_off_rounded)
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) => _buildTemplateCard(filteredTemplates[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return BlocBuilder<NoticeCubit, NoticeState>(
      bloc: _noticeCubit,
      builder: (context, state) {
        if (state is NoticeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NoticesLoaded) {
            final announcements = state.announcements;
            if (announcements.isEmpty) {
              return _buildEmptyState("No announcements sent yet", Icons.history_rounded);
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
              itemCount: announcements.length,
              itemBuilder: (context, index) => _buildHistoryCard(announcements[index]),
            );
          }
          return _buildEmptyState("Failed to load history", Icons.error_outline_rounded);
        },
      );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {}),
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: StringUtils.translate('search_templates_hint', context: context),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 20.sp),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = _getLocalizedCategories(context);
    final allCategoryLabel = StringUtils.translate('category_all', context: context);
    
    
    if (_selectedCategory == 'All') _selectedCategory = allCategoryLabel;

    return Container(
      height: 36.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return BouncingWrapper(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(AnnouncementTemplate template) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: template.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(24.r)),
            ),
            child: Icon(template.icon, color: template.color, size: 32.sp),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(template.category.toUpperCase(), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: template.color, letterSpacing: 1)),
                      BouncingWrapper(
                        onTap: () => _confirmAndSend(template.title, template.description),
                        child: Icon(Icons.send_rounded, color: AppColors.primaryBlue, size: 20.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(template.title, style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                  SizedBox(height: 4.h),
                  Text(template.description, style: TextStyle(fontSize: 13.sp, color: AppColors.greyText), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic announcement) {
    final title = announcement.title ?? 'No Title';
    final content = announcement.content ?? '';
    final createdAt = announcement.createdAt != null ? DateFormat('MMM dd, hh:mm a').format(announcement.createdAt) : '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(createdAt, style: TextStyle(fontSize: 11.sp, color: AppColors.greyText, fontWeight: FontWeight.w600)),
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 14.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(title, style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
          SizedBox(height: 6.h),
          Text(content, style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _confirmAndSend(String title, String content, {VoidCallback? onConfirmed}) {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide both subject and message.'), backgroundColor: Colors.red));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(StringUtils.translate('confirm_broadcast_title', context: context), style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 18.sp)),
        content: Text(StringUtils.translate('confirm_broadcast_desc', context: context), style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(StringUtils.translate('cancel', context: context), style: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onConfirmed != null) onConfirmed();
              _sendDirectly(title, content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(StringUtils.translate('send', context: context), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _sendDirectly(String title, String content) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final idx = hostelState.selectedHostelIndex;
      if (idx >= 0 && idx < hostelState.hostels.length) {
        final hostelId = hostelState.hostels[idx].id;
        _noticeCubit.postAnnouncement(
          hostelId: hostelId,
          title: title,
          content: content,
        ).then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(StringUtils.translate('announcement_sent_msg', context: context)), backgroundColor: Colors.green));
          
          _titleController.clear();
          _messageController.clear();
          
          _loadHistory();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(StringUtils.translate('select_property_err', context: context)), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(StringUtils.translate('no_property_data_available', context: context)), backgroundColor: Colors.red));
    }
  }

  Widget _buildWriteNewButton() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: BouncingWrapper(
            onTap: _showWriteNewSheet,
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_document, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    StringUtils.translate('write_custom_announcement', context: context),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWriteNewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WriteNewSheet(
        titleController: _titleController,
        messageController: _messageController,
        onSend: (title, content) {
          _confirmAndSend(title, content, onConfirmed: () {
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}

class _WriteNewSheet extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController messageController;
  final Function(String, String) onSend;

  const _WriteNewSheet({
    required this.titleController,
    required this.messageController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Text(StringUtils.translate('create_announcement_title', context: context), style: GoogleFonts.dmSans(fontSize: 22.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 8.h),
            Text(StringUtils.translate('create_announcement_desc', context: context), style: TextStyle(color: AppColors.greyText, fontSize: 13.sp)),
            SizedBox(height: 32.h),
            _buildTextField(StringUtils.translate('subject_label', context: context), "e.g., WiFi Maintenance Update", titleController, 1),
            SizedBox(height: 20.h),
            _buildTextField(StringUtils.translate('message_label', context: context), "Type your announcement details here...", messageController, 5),
            SizedBox(height: 40.h),
            BouncingWrapper(
              onTap: () => onSend(titleController.text.trim(), messageController.text.trim()),
              child: Container(
                height: 56.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(StringUtils.translate('broadcast_now_btn', context: context), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16.sp)),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.2)),
        SizedBox(height: 12.h),
        TextField(
          controller: controller,
          maxLines: lines,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(16.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
