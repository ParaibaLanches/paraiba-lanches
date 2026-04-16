import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _documentController;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _documentController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      // Capitalize if first word OR length > 3
      if (word.length > 3) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }

  void _loadUserData(dynamic user) {
    _nameController.text = _formatName(user.name);
    // Apply defaults if empty
    _phoneController.text = user.phone.isEmpty ? '(00) 00000-0000' : user.phone;
    _documentController.text = user.document.isEmpty ? '000.000.000-00' : user.document;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isEditing) {
      _loadUserData(user);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MEU PERFIL'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _ProfileField(
              label: 'Nome Completo',
              controller: _nameController,
              isEditing: _isEditing,
              hint: 'Seu nome completo',
              validator: AppValidators.name,
            ),
            const SizedBox(height: 16),
            _ProfileField(
              label: 'E-mail',
              value: user.email,
              isEditing: false, // E-mail costuma ser imutável
            ),
            const SizedBox(height: 16),
            _ProfileField(
              label: 'Telefone',
              controller: _phoneController,
              isEditing: _isEditing,
              hint: '(00) 00000-0000',
              inputFormatters: [_phoneFormatter],
              keyboardType: TextInputType.phone,
              validator: AppValidators.phone,
            ),
            const SizedBox(height: 16),
            _ProfileField(
              label: 'CPF',
              controller: _documentController,
              isEditing: _isEditing,
              hint: '000.000.000-00',
              inputFormatters: [_cpfCnpjFormatter],
              keyboardType: TextInputType.number,
              validator: AppValidators.cpf,
            ),
            const SizedBox(height: 32),

            // Buttons
            if (!_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('EDITAR PERFIL'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final formattedName = _formatName(_nameController.text);
                    await ref.read(authControllerProvider.notifier).updateProfile(
                      name: formattedName,
                      phone: _phoneController.text,
                      document: _documentController.text,
                    );
                    if (!mounted) return;
                    final error = ref.read(authControllerProvider).error;
                    if (error == null) {
                      setState(() => _isEditing = false);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                      );
                    }
                  },
                  child: authState.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('SALVAR ALTERAÇÕES'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: (_isEditing || authState.isLoading) 
                  ? null 
                  : () => ref.read(authControllerProvider.notifier).logout(),
                child: Text(
                  'SAIR DA CONTA',
                  style: AppTypography.labelLarge.copyWith(
                    color: (_isEditing || authState.isLoading) ? AppColors.outline : AppColors.error,
                  ),
                ),
              ),
            ),
            if (authState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                authState.error!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final bool isEditing;
  final String? hint;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    this.value,
    this.controller,
    required this.isEditing,
    this.hint,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEditing && controller != null,
          initialValue: controller == null ? value : null,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: isEditing ? validator : null,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isEditing ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.7),
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isEditing ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
