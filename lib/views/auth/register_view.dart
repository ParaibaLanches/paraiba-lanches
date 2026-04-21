import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/viacep_service.dart';
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

  // Address Controllers
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _complementController = TextEditingController();

  bool _isFetchingCep = false;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  void _onCepChanged() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length == 8) {
      setState(() => _isFetchingCep = true);
      final data = await ViaCepService.fetchCep(cep);
      setState(() => _isFetchingCep = false);

      if (data != null && mounted) {
        _streetController.text = data['logradouro'] ?? '';
        _neighborhoodController.text = data['bairro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
        _stateController.text = data['uf'] ?? '';
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          cep: _cepController.text.trim(),
          street: _streetController.text.trim(),
          number: _numberController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          city: _cityController.text.trim(),
          stateAbbreviation: _stateController.text.trim(),
          complement: _complementController.text.trim(),
          address:
              '${_streetController.text}, ${_numberController.text} - ${_cityController.text}',
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
                Text(
                  'Crie sua conta para fazer pedidos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Seção 1: Dados Pessoais
                Text('Dados Pessoais', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nome Completo',
                  controller: _nameController,
                  hint: 'Seu nome',
                  validator: AppValidators.name,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'seu@email.com',
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Celular',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                  hint: '(99) 99999-9999',
                  validator: AppValidators.phone,
                ),

                const SizedBox(height: 32),

                // Seção 2: Endereço de Entrega
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Endereço de Entrega',
                      style: AppTypography.titleMedium,
                    ),
                    if (_isFetchingCep)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'CEP',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepFormatter],
                  hint: '00000-000',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Logradouro (Rua/Av)',
                  controller: _streetController,
                  hint: 'Nome da rua',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Número',
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        hint: 'S/N',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Complemento',
                        controller: _complementController,
                        hint: 'Apto, Bloco, etc.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Bairro',
                  controller: _neighborhoodController,
                  hint: 'Ex: Centro',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: AppTextField(
                        label: 'Cidade',
                        controller: _cityController,
                        hint: 'Sua cidade',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: AppTextField(
                        label: 'UF',
                        controller: _stateController,
                        hint: 'PB',
                        validator: (v) => v == null || v.isEmpty ? '!' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Seção 3: Segurança
                Text('Segurança', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Senha',
                  controller: _passwordController,
                  isPassword: true,
                  hint: 'Mínimo 6 caracteres',
                  validator: AppValidators.password,
                ),

                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authState.error!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: 'Criar minha conta',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
