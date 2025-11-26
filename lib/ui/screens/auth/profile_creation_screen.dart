import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../data/database_helper.dart';
import '../../../data/models/user_profile_model.dart';
import '../../widgets/widgets.dart';

/// Écran de création de profil utilisateur avec configuration de la biométrie
class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _selectedLevel = 'A1';
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isLoading = false;
  List<BiometricType> _availableBiometrics = [];

  final List<String> _frenchLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable = canCheckBiometrics && isDeviceSupported;
        _availableBiometrics = availableBiometrics;
      });
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Vérifiez votre identité pour activer la biométrie',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      debugPrint('Error authenticating: $e');
      return false;
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Si biométrie activée, vérifier l'authentification
      if (_biometricEnabled) {
        final authenticated = await _authenticateWithBiometrics();
        if (!authenticated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Authentification biométrique échouée. Le profil sera créé sans biométrie.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _biometricEnabled = false;
          });
        }
      }

      // Créer le profil
      final profile = UserProfileModel(
        id: 0, // Will be auto-incremented
        name: _nameController.text.trim(),
        frenchLevel: _selectedLevel,
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
        biometricEnabled: _biometricEnabled,
        appleUserId: null, // To be implemented
        passkeyId: null, // To be implemented
      );

      final db = DatabaseHelper.instance;
      await db.createUserProfile(profile.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getBiometricTypeText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (_availableBiometrics.contains(BiometricType.strong)) {
      return 'Authentification forte';
    } else if (_availableBiometrics.contains(BiometricType.weak)) {
      return 'Authentification biométrique';
    }
    return 'Biométrie';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer votre profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Informations de base',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Name field
              CustomTextField(
                label: 'Votre prénom',
                hint: 'Ex: Marie',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  if (value.trim().length < 2) {
                    return 'Le prénom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // French level dropdown
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Niveau de français',
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _frenchLevels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // Biometric section
              Text(
                'Sécurité',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Authentification biométrique',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _biometricAvailable
                                      ? 'Protégez vos données avec ${_getBiometricTypeText()}'
                                      : 'Non disponible sur cet appareil',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: _biometricAvailable
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _biometricEnabled,
                            onChanged: _biometricAvailable
                                ? (value) {
                                    setState(() {
                                      _biometricEnabled = value;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      if (_biometricAvailable && _biometricEnabled) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vous devrez confirmer votre identité lors de la création du profil',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vos données restent 100% privées et stockées uniquement sur votre appareil.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create button
              PrimaryButton(
                label: 'Créer mon profil',
                onPressed: _createProfile,
                isLoading: _isLoading,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
