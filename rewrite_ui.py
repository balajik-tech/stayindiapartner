import re

with open('lib/features/communities/presentation/pages/explore_communities_page.dart', 'r') as f:
    content = f.read()

# 1. Change font
content = content.replace('GoogleFonts.dmSans', 'GoogleFonts.plusJakartaSans')

# 2. Update Scaffold
scaffold_old = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopSection(),
            ),
            SliverToBoxAdapter(
              child: _buildStatesSection(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 32.h),
            ),
            SliverToBoxAdapter(
              child: _buildBottomContent(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }"""

scaffold_new = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopSection(),
            ),
            SliverToBoxAdapter(
              child: _buildStatesSection(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 48.h),
            ),
            SliverToBoxAdapter(
              child: _buildBottomContent(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(color: const Color(0xFFF8FAFC)),
            ),
          ],
        ),
      ),
    );
  }"""
content = content.replace(scaffold_old, scaffold_new)

# 3. Update _buildTopSection
top_section_old = """  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          SizedBox(height: 32.h),
          Text(
            'explore_communities_by_state'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'select_state_desc'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {
                      _searchQuery = val;
                      _maxCount = 8;
                    }),
                    style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: 'search_state_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 15.sp),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20.sp),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18.sp),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _maxCount = 8;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 52.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: _isGridView ? AppColors.primaryBlue : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: !_isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.view_list_rounded,
                          color: !_isGridView ? AppColors.primaryBlue : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }"""

top_section_new = """  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.darkText, size: 20.sp),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'explore_communities_by_state'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'select_state_desc'.tr(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {
                      _searchQuery = val;
                      _maxCount = 8;
                    }),
                    style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: 'search_state_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 15.sp, fontWeight: FontWeight.w500),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22.sp),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 20.sp),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _maxCount = 8;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 54.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: _isGridView ? [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                          ] : null,
                        ),
                        child: Icon(Icons.grid_view_rounded, color: _isGridView ? AppColors.primaryBlue : AppColors.greyText, size: 20.sp),
                      ),
                    ),
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: !_isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: !_isGridView ? [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                          ] : null,
                        ),
                        child: Icon(Icons.view_list_rounded, color: !_isGridView ? AppColors.primaryBlue : AppColors.greyText, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }"""
content = content.replace(top_section_old, top_section_new)

# 4. Fix _buildStatesSection colors (Text white -> darkText)
content = content.replace("CircularProgressIndicator(color: Colors.white)", "CircularProgressIndicator(color: AppColors.primaryBlue)")
content = content.replace("GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16.sp)", "GoogleFonts.plusJakartaSans(color: AppColors.greyText, fontSize: 16.sp)")

# Update List View Container BoxShadow
list_box_old = """                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),"""
list_box_new = """                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),"""
content = content.replace(list_box_old, list_box_new)

# Update Grid View Container BoxShadow
grid_box_old = """                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),"""
grid_box_new = """                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),"""
content = content.replace(grid_box_old, grid_box_new)

# Update Bottom Content Background
bottom_content_old = """  Widget _buildBottomContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),"""
bottom_content_new = """  Widget _buildBottomContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),"""
content = content.replace(bottom_content_old, bottom_content_new)

with open('lib/features/communities/presentation/pages/explore_communities_page.dart', 'w') as f:
    f.write(content)

print("Done replacing.")
