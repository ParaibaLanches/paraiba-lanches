import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'controllers/providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Criamos o container antes para carregar a sessão
  final container = ProviderContainer();

  try {
    // Aguardamos a sessão ser carregada antes de iniciar o app
    await container.read(authControllerProvider.notifier).loadSession();
  } catch (e) {
    debugPrint('Erro ao carregar sessão inicial: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ParaibaLanchesApp(),
    ),
  );
}

class ParaibaLanchesApp extends ConsumerStatefulWidget {
  const ParaibaLanchesApp({super.key});

  @override
  ConsumerState<ParaibaLanchesApp> createState() => _ParaibaLanchesAppState();
}

class _ParaibaLanchesAppState extends ConsumerState<ParaibaLanchesApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appInfo = ref.watch(appInfoProvider);

    // Update static typography classes when app info is available
    appInfo.whenData((info) => AppTypography.init(info));

    return MaterialApp.router(
      title: 'Paraiba Lanches',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.createTheme(appInfo.value),
      routerConfig: router,
    );
  }
}
