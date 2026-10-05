import 'package:flutter/material.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_footer_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/parameters_section_widget.dart';
import '../../../core/theme/app_dimensions.dart';

class ColetaScreen extends StatefulWidget {
  const ColetaScreen({super.key});

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen> {
  final _formKey = GlobalKey<FormState>();

  void _iniciarColeta() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fluxo de coleta iniciado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Coleta'), centerTitle: false),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space20,
              AppDimensions.space12,
              AppDimensions.space20,
              AppDimensions.pillDockHeight +
                  AppDimensions.pillDockMarginBottom +
                  40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IdentificacaoSectionWidget(), // Componente extraído
                const SizedBox(height: AppDimensions.space24),
                const ParametersSectionWidget(), // Componente extraído
                const SizedBox(height: AppDimensions.space24),
                const InfoFooterWidget(), // Componente extraído
                const SizedBox(height: AppDimensions.space32),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: FilledButton.icon(
                    onPressed: _iniciarColeta,
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Continuar para Seleção de Sensores'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
