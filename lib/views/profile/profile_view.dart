import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      await ref.read(authControllerProvider.notifier).updateAvatar(image.path);
    }
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

    final avatarUrl = ApiConstants.getImageUrl(user.avatarUrl);

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
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: avatarUrl != null 
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: avatarUrl == null 
                        ? const Icon(
                            Icons.person,
                            size: 64,
                            color: AppColors.primary,
                          )
                        : null,
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
            ),
            const SizedBox(height: 32),

            AppTextField(
              label: 'Nome Completo',
              controller: _nameController,
              enabled: _isEditing,
              hint: 'Seu nome completo',
              validator: AppValidators.name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'E-mail',
              hint: user.email,
              enabled: false,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Telefone',
              controller: _phoneController,
              enabled: _isEditing,
              hint: '(00) 00000-0000',
              inputFormatters: [_phoneFormatter],
              keyboardType: TextInputType.phone,
              validator: AppValidators.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'CPF',
              controller: _documentController,
              enabled: _isEditing,
              hint: '000.000.000-00',
              inputFormatters: [_cpfCnpjFormatter],
              keyboardType: TextInputType.number,
              validator: AppValidators.cpf,
            ),
            const SizedBox(height: 32),

            if (!_isEditing) ...[
              AppButton(
                label: 'Editar perfil',
                onPressed: () => setState(() => _isEditing = true),
              ),
            ] else ...[
              AppButton(
                label: 'Salvar alterações',
                isLoading: authState.isLoading,
                onPressed: () async {
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
              ),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: 'Sair da conta',
              isSecondary: true,
              onPressed: (_isEditing || authState.isLoading) 
                ? null 
                : () => ref.read(authControllerProvider.notifier).logout(),
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
