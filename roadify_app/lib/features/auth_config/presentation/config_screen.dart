import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/theme/theme_extensions.dart';
import 'login_screen.dart';

/// Tela de Configurações e Perfil (Feature Auth/Config — Alocada para o Tiago).
class ConfigScreen extends StatelessWidget {
  final ThemeController themeController;

  const ConfigScreen({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.space20,
            AppDimensions.space12,
            AppDimensions.space20,
            AppDimensions.pillDockHeight + AppDimensions.pillDockMarginBottom + 40,
          ),
          children: [
            // --- Seção: Conta de Usuário ---
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusCard,
                side: BorderSide(color: colors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.primary,
                  child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                title: const Text('Conta de Usuário'),
                subtitle: const Text('Entrar ou criar conta para sincronizar'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: AppDimensions.space20),

            // --- Seção: Aparência e Temas Globais ---
            Text('Aparência e Tema', style: typography.titleMedium),
            const SizedBox(height: AppDimensions.space8),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppDimensions.borderRadiusCard,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o modo de exibição preferido. O Modo Claro é o mais recomendado para visibilidade em para-brisas.',
                    style: typography.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Claro'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Escuro'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistema'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                    ],
                    selected: {themeController.themeMode},
                    onSelectionChanged: (newSelection) {
                      themeController.setThemeMode(newSelection.first);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space24),

            // --- Seção: Preferências Padrão de Coleta ---
            Text('Padrões do Veículo', style: typography.titleMedium),
            const SizedBox(height: AppDimensions.space8),
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusCard,
                side: BorderSide(color: colors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.directions_car_rounded),
                    title: const Text('Veículo Padrão'),
                    subtitle: const Text('Toyota Hilux (ABC-1234)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.speed_rounded),
                    title: const Text('Taxa do Acelerômetro'),
                    subtitle: const Text('200 Hz (Recomendado)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: const Text('Idioma do Sistema'),
                    subtitle: const Text('Português (Brasil)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.space24),

            // --- Seção: Servidor e API RESTful ---
            Text('Conexão com o Servidor', style: typography.titleMedium),
            const SizedBox(height: AppDimensions.space8),
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusCard,
                side: BorderSide(color: colors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_queue_rounded),
                    title: const Text('Endpoint da API Roadify'),
                    subtitle: const Text('https://roadify.app.pb.utfpr.edu.br/api'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.wifi_rounded),
                    title: const Text('Sincronizar apenas no Wi-Fi'),
                    subtitle: const Text('Economiza franquia de dados móveis'),
                    value: true,
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
