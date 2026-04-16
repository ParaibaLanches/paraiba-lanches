import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/auth_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: ParaibaLanchesApp()));
}

class ParaibaLanchesApp extends ConsumerStatefulWidget {
  const ParaibaLanchesApp({super.key});

  @override
  ConsumerState<ParaibaLanchesApp> createState() => _ParaibaLanchesAppState();
}

class _ParaibaLanchesAppState extends ConsumerState<ParaibaLanchesApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).loadSession());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Paraiba Lanches',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
