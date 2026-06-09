import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/viacep_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
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

  // Address Controllers
  late TextEditingController _cepController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _complementController;

  bool _isFetchingCep = false;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _documentController = TextEditingController();
    _cepController = TextEditingController();
    _streetController = TextEditingController();
    _numberController = TextEditingController();
    _neighborhoodController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _complementController = TextEditingController();

    _cepController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
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
    if (!_isEditing) return;
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length == 8) {
      // Evitar requisições duplicadas
      if (_isFetchingCep) return;

      setState(() => _isFetchingCep = true);
      final data = await ViaCepService.fetchCep(cep);
      setState(() => _isFetchingCep = false);

      if (!mounted) return;

      if (data != null) {
        _streetController.text = data['logradouro'] ?? '';
        _neighborhoodController.text = data['bairro'] ?? '';
        _cityController.text = data['localidade'] ?? '';
        _stateController.text = data['uf'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado ou inválido.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          // Capitalize if first word OR length > 3
          if (word.length > 3) {
            return word[0].toUpperCase() + word.substring(1);
          }
          return word;
        })
        .join(' ');
  }

  void _loadUserData(dynamic user) {
    _nameController.text = _formatName(user.name);
    _phoneController.text = user.phone.isEmpty
        ? ''
        : _phoneFormatter.maskText(user.phone);
    _documentController.text = user.document.isEmpty
        ? ''
        : _cpfCnpjFormatter.maskText(user.document);

    // Load Address Fields
    _cepController.text = user.cep;
    _streetController.text = user.street;
    _numberController.text = user.number;
    _neighborhoodController.text = user.neighborhood;
    _cityController.text = user.city;
    _stateController.text = user.state;
    _complementController.text = user.complement;
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
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
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text('Dados Pessoais', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nome Completo',
                controller: _nameController,
                enabled: _isEditing,
                hint: 'Seu nome completo',
                validator: AppValidators.name,
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'E-mail', hint: user.email, enabled: false),
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

              // Endereço Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Endereço de Entrega', style: AppTypography.titleMedium),
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
                enabled: _isEditing,
                inputFormatters: [_cepFormatter],
                keyboardType: TextInputType.number,
                hint: '00000-000',
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Logradouro',
                controller: _streetController,
                enabled: _isEditing,
                hint: 'Rua, Avenida, etc.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      label: 'Número',
                      controller: _numberController,
                      enabled: _isEditing,
                      hint: '123',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'Complemento',
                      controller: _complementController,
                      enabled: _isEditing,
                      hint: 'Apto, Bloco, etc.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bairro',
                controller: _neighborhoodController,
                enabled: _isEditing,
                hint: 'Seu bairro',
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Cidade',
                controller: _cityController,
                enabled: _isEditing,
                hint: 'Sua cidade',
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
                    await ref
                        .read(authControllerProvider.notifier)
                        .updateProfile(
                          name: formattedName,
                          phone: _phoneController.text,
                          document: _documentController.text,
                          cep: _cepController.text,
                          street: _streetController.text,
                          number: _numberController.text,
                          neighborhood: _neighborhoodController.text,
                          city: _cityController.text,
                          stateAbbreviation: _stateController.text,
                          complement: _complementController.text,
                          address:
                              '${_streetController.text}, ${_numberController.text} - ${_cityController.text}',
                        );
                    if (!mounted) return;
                    final error = ref.read(authControllerProvider).error;
                    if (error == null) {
                      setState(() => _isEditing = false);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Perfil atualizado com sucesso!'),
                        ),
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
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
