import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/orders/domain/entities/payment_intent_entity.dart';

class PixPaymentView extends StatelessWidget {
  final PaymentIntentEntity paymentIntent;

  const PixPaymentView({super.key, required this.paymentIntent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento PIX'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2, size: 120, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Aguardando Pagamento',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Copie o código PIX abaixo e pague no app do seu banco. Assim que pago, o pedido será liberado automaticamente!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  paymentIntent.pixCopyPaste ?? 'Código não disponível',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (paymentIntent.pixCopyPaste != null) {
                    Clipboard.setData(ClipboardData(text: paymentIntent.pixCopyPaste!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado!')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('COPIAR CÓDIGO PIX'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/orders'),
                child: const Text('VER MEUS PEDIDOS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
