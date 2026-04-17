import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/auth_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

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

    return MaterialApp.router(
      title: 'Paraiba Lanches',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
