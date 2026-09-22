import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';

/// Tela de Cadastro de Usuário (Feature Auth/Config — Alocada para o Tiago).
///
/// Fiel à tela "Cadastro de usuário" de `prototipo telas.png`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppDimensions.space20),
              Text(
                'Crie sua conta',
                style: typography.displaySmall,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Comece agora e organize tudo em um só lugar.',
                style: typography.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.space32),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  hintText: 'Digite seu nome',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'voce@exemplo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo de 8 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (val) {
                      setState(() {
                        _acceptedTerms = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Li e aceito os Termos de Uso e a Política de Privacidade.',
                      style: typography.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: _acceptedTerms
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Criar conta'),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Center(
                child: Text('ou continue com', style: typography.bodySmall),
              ),
              const SizedBox(height: AppDimensions.space16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.apple_rounded, size: 20),
                      label: const Text('Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Já tem uma conta? Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
