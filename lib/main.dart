import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/auth/presentation/pages/registration_personal_page.dart';
import 'features/profile/presentation/cubit/hostel_cubit.dart';
import 'features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'features/notices/presentation/cubit/notice_cubit.dart';
import 'features/staff/presentation/cubit/staff_cubit.dart';
import 'features/payments/presentation/cubit/payment_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/settings_cubit.dart';
import 'injection_container.dart' as di;
import 'core/services/app_bootstrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const AppBootstrapper(
      child: StayIndiaOwnerApp(),
    ),
  );
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StayIndiaOwnerApp extends StatelessWidget {
  const StayIndiaOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..restoreSession(),
        ),
        BlocProvider(create: (context) => di.sl<ThemeCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    navigatorKey.currentState
                        ?.popUntil((route) => route.isFirst);
                  }
                },
                child: BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (prev, curr) {
                    
                    if (curr is AuthLoading || curr is AuthError || curr is AuthOtpSent) {
                      return false;
                    }
                    final prevKey = prev is AuthAuthenticated
                        ? prev.owner.id
                        : 'unauthenticated';
                    final currKey = curr is AuthAuthenticated
                        ? curr.owner.id
                        : 'unauthenticated';
                    return prevKey != currKey;
                  },
                  builder: (context, authState) {
                    final sessionKey = authState is AuthAuthenticated
                        ? authState.owner.id
                        : 'unauthenticated';



                    return MultiBlocProvider(
                      key: ValueKey(sessionKey),
                      providers: [
                        BlocProvider(
                          create: (context) =>
                              di.sl<HostelCubit>()..getHostels(),
                        ),
                        BlocProvider(
                          create: (context) => di.sl<BookingsCubit>(),
                        ),
                        BlocProvider(
                          create: (context) => di.sl<DashboardCubit>(),
                        ),
                        BlocProvider(
                          create: (context) => di.sl<TenantCubit>(),
                        ),
                        BlocProvider(
                            create: (context) => di.sl<MaintenanceCubit>()),
                        BlocProvider(create: (context) => di.sl<NoticeCubit>()),
                        BlocProvider(create: (context) => di.sl<StaffCubit>()),
                        BlocProvider(create: (context) => di.sl<PaymentCubit>()),
                        BlocProvider(create: (context) => di.sl<ProfileCubit>()),
                        BlocProvider(create: (context) => di.sl<SettingsCubit>()),
                        BlocProvider(
                            create: (context) => di.sl<CommunityCubit>()),
                        BlocProvider(
                            create: (context) => di.sl<OwnerCommunityCubit>()),
                        BlocProvider(
                            create: (context) => di.sl<AssociationCubit>()),
                      ],
                      child: MaterialApp(
                        navigatorKey: navigatorKey,
                        title: 'Stay India Owner',
                        debugShowCheckedModeBanner: false,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        themeMode: themeMode,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        builder: (context, child) {
                          Intl.defaultLocale = context.locale.toString();
                          return child!;
                        },
                        home: const AuthGate(
                          dashboard: MainNavigationPage(),
                          registration: RegistrationPersonalPage(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


