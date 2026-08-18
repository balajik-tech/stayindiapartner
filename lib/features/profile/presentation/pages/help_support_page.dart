import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int _expandedIndex = 0;

  List<Map<String, String>> _getLocalizedFaqs(BuildContext context) {
    return [
      {
        'question': StringUtils.translate('faq_q1', context: context),
        'answer': StringUtils.translate('faq_a1', context: context),
      },
      {
        'question': StringUtils.translate('faq_q2', context: context),
        'answer': StringUtils.translate('faq_a2', context: context),
      },
      {
        'question': StringUtils.translate('faq_q3', context: context),
        'answer': StringUtils.translate('faq_a3', context: context),
      },
      {
        'question': StringUtils.translate('faq_q4', context: context),
        'answer': StringUtils.translate('faq_a4', context: context),
      },
      {
        'question': StringUtils.translate('faq_q5', context: context),
        'answer': StringUtils.translate('faq_a5', context: context),
      },
      {
        'question': StringUtils.translate('faq_q6', context: context),
        'answer': StringUtils.translate('faq_a6', context: context),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          StringUtils.translate('help_support_title', context: context),
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(
            height: 1,
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactActions(),
            SizedBox(height: 32.h),
            _buildSectionHeader(
              Icons.description_outlined,
              StringUtils.translate('faq_title', context: context),
            ),
            SizedBox(height: 16.h),
            _buildFaqList(context),
            SizedBox(height: 32.h),
            _buildQuickLinks(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildContactActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildContactCard(
            StringUtils.translate('call_us_option', context: context),
            Icons.phone_outlined,
            const Color(0xFF2C5EBD),
            () => _launchUrl('tel:+919888936836'),
            ''
          ),
          SizedBox(width: 12.w),
          _buildContactCard(
            StringUtils.translate('whatsapp_option', context: context),
            Icons.chat_bubble_outline,
            const Color(0xFF10B981),
            () => _launchUrl('https://wa.me/919888936836?text=Hello%20Stay%20India%20Support!'),
            'assets/images/whatsapp.png'
          ),
          SizedBox(width: 12.w),
          _buildContactCard(
            StringUtils.translate('email_option', context: context),
            Icons.mail_outline,
            const Color(0xFFF97316),
            () => _launchUrl(
              'mailto:contact@stayindia.in?subject=Support%20Request',
            ),
            ''
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, IconData icon, Color color, VoidCallback onTap, String imageUrl) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.roomCardBorder),
            ),
            child: Column(
              children: [
                if (imageUrl.isNotEmpty)...[
                  Image.asset(
                    imageUrl,
                    width: 24.w,
                    height: 24.h,
                  ),
                ]else...[
                  Icon(icon, color: color, size: 24.sp),
                ],
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.darkText),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList(BuildContext context) {
    final faqs = _getLocalizedFaqs(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: List.generate(faqs.length, (index) {
          final isExpanded = _expandedIndex == index;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isExpanded
                    ? AppColors.primaryBlue.withValues(alpha: 0.3)
                    : AppColors.roomCardBorder,
              ),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                onExpansionChanged: (expanded) {
                  if (expanded) setState(() => _expandedIndex = index);
                },
                title: Text(
                  faqs[index]['question']!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.darkText,
                  size: 20.sp,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: Text(
                      faqs[index]['answer']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF667085),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringUtils.translate('quick_links_title', context: context),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          _buildLinkItem(
            StringUtils.translate('video_tutorials_link', context: context),
          ),
          _buildLinkItem(
            StringUtils.translate('user_guide_link', context: context),
          ),
          _buildLinkItem(
            StringUtils.translate('privacy_policy', context: context),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          Icon(Icons.open_in_new, size: 18.sp, color: const Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}
