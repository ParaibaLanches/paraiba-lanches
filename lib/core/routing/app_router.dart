import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/home/home_view.dart';
import '../../views/cart/cart_view.dart';
import '../../views/checkout/checkout_view.dart';
import '../../views/orders/orders_view.dart';
import '../../views/orders/order_detail_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/checkout/pix_payment_view.dart';
import '../../views/product/product_detail_view.dart';
import '../../models/product.dart';
import '../../models/order.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;

      // Do nothing if not initialized to avoid flickering or incorrect redirects
      if (!isInitialized) return null;

      final isAuthRoute =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (state.uri.path == '/') return '/home';
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginView()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterView()),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeView()),
          GoRoute(path: '/orders', builder: (_, _) => const OrdersView()),
          GoRoute(path: '/cart', builder: (_, _) => const CartView()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileView()),
          GoRoute(path: '/checkout', builder: (_, _) => const CheckoutView()),
          GoRoute(
            path: '/product',
            builder: (context, state) {
              if (state.extra is Map<String, dynamic>) {
                final map = state.extra as Map<String, dynamic>;
                return ProductDetailView(
                  product: map['product'] as Product,
                  heroTag: map['heroTag'] as String?,
                );
              }
              final product = state.extra as Product;
              return ProductDetailView(product: product);
            },
          ),
          GoRoute(
            path: '/order-detail',
            builder: (context, state) {
              final order = state.extra as Order;
              return OrderDetailView(order: order);
            },
          ),
          GoRoute(
            path: '/order/:id/pix',
            builder: (context, state) {
              final paymentIntent = state.extra as PaymentIntent;
              return PixPaymentView(paymentIntent: paymentIntent);
            },
          ),
        ],
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

class _AppShell extends StatelessWidget {
  final Widget child;

  const _AppShell({required this.child});

  static const _routes = ['/home', '/orders', '/cart', '/profile'];

  int _indexFromPath(String path) {
    for (int i = 0; i < _routes.length; i++) {
      if (path.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFromPath(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
