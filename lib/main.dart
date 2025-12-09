import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'services/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-cache Google Fonts for better performance
  GoogleFonts.config.allowRuntimeFetching = true;
  
  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: SoulGardenApp()));
}

class SoulGardenApp extends ConsumerWidget {
  const SoulGardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final calmMode = ref.watch(calmModeProvider);

    // Select theme based on calm mode
    final theme = CalmTheme.getTheme(calmMode);

    return MaterialApp.router(
      title: 'SoulGarden',
      theme: theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: calmMode == CalmMode.light ? ThemeMode.light : ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
