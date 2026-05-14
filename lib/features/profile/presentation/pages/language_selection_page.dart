import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> languages = [
      {'name': 'English', 'locale': const Locale('en')},
      {'name': 'हिन्दी', 'locale': const Locale('hi')},
      {'name': 'తెలుగు', 'locale': const Locale('te')},
      {'name': 'தமிழ்', 'locale': const Locale('ta')},
      {'name': 'ಕನ್ನಡ', 'locale': const Locale('kn')},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('change_language'.tr()),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: languages.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = context.locale == lang['locale'];

          return ListTile(
            title: Text(
              lang['name'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                : null,
            onTap: () async {
              if (isSelected) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  title: Text(
                    'change_language_confirm_title'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                    ),
                  ),
                  content: Text(
                    'change_language_confirm_msg'.tr(namedArgs: {
                      'language': lang['name'],
                    }),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: Text(
                        'cancel'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'confirm'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.setLocale(lang['locale']);
              }
            },
          );
        },
      ),
    );
  }
}
