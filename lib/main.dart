import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InvoxApp()));
}

bool _isMobileScreen() {
  try {
    return ScreenUtil().screenWidth < 600;
  } catch (_) {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    if (view != null && view.devicePixelRatio > 0) {
      return (view.physicalSize.width / view.devicePixelRatio) < 600;
    }
    return true;
  }
}

class InvoxApp extends ConsumerWidget {
  const InvoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      enableScaleWH: () => _isMobileScreen(),
      enableScaleText: () => _isMobileScreen(),
      fontSizeResolver: (fontSize, instance) {
        if (instance.screenWidth >= 600) {
          return fontSize.toDouble();
        }
        return FontSizeResolvers.width(fontSize, instance);
      },
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Invox',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              color: AppColors.card,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
