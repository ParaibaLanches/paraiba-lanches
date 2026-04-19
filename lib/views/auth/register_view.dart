import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(authControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.isAuthenticated) context.go('/home');
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authControllerProvider.notifier).clearError();
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('CADASTRE-SE', style: AppTypography.displayMedium),
                const SizedBox(height: 4),
                Text('Crie sua conta para fazer pedidos', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Nome Completo',
                  controller: _nameController,
                  hint: 'Seu nome',
                  validator: AppValidators.name,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'seu@email.com',
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Celular',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  hint: '(99) 99999-9999',
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Senha',
                  controller: _passwordController,
                  isPassword: true,
                  hint: 'Minimo 6 caracteres',
                  validator: AppValidators.password,
                ),
              if (authState.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.errorContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(authState.error!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Criar minha conta',
                isLoading: authState.isLoading,
                onPressed: _handleRegister,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
