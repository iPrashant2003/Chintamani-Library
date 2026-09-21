import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routing/app_router.dart';
import 'theme/theme_provider.dart';
import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeConfig = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: themeConfig.toThemeData(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
