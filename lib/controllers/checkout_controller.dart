import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon.dart';
import '../features/cart/presentation/providers/cart_providers.dart';

class CheckoutState {
  final Coupon? appliedCoupon;
  final double deliveryFee;
  final bool isLoading;
  final String? error;

  CheckoutState({
    this.appliedCoupon,
    this.deliveryFee = 0,
    this.isLoading = false,
    this.error,
  });

  CheckoutState copyWith({
    Coupon? Function()? appliedCoupon,
    double? deliveryFee,
    bool? isLoading,
    String? Function()? error,
  }) {
    return CheckoutState(
      appliedCoupon: appliedCoupon != null
          ? appliedCoupon()
          : this.appliedCoupon,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  double calculateTotal(double subtotal) {
    final discount = appliedCoupon?.calculateDiscount(subtotal) ?? 0;
    return subtotal + deliveryFee - discount;
  }
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    // We can clear checkout state if cart becomes empty
    ref.listen(cartProvider, (previous, next) {
      if (next.isEmpty) {
        state = CheckoutState();
      }
    });
    return CheckoutState();
  }

  void setDeliveryFee(double fee) {
    state = state.copyWith(deliveryFee: fee);
  }

  void setCoupon(Coupon? coupon) {
    state = state.copyWith(appliedCoupon: () => coupon);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: () => error);
  }
}

final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);
