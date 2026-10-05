import 'package:flutter/material.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_footer_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/parameters_section_widget.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import '../../../core/theme/app_dimensions.dart';

class ColetaScreen extends StatefulWidget {
  final ColetaViewModel? viewModel;

  const ColetaScreen({super.key, this.viewModel});

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ColetaViewModel _viewModel;
  final Set<SensorColeta> _sensoresSelecionados = {
    SensorColeta.acelerometro,
    SensorColeta.gps,
  };
  late final TextEditingController _frequenciaGpsController;
  late final TextEditingController _intervaloMetrosController;
  int _taxaAquisicaoHz = 100;
  String? _erroSelecaoSensores;
  bool _isStartingRecording = false;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? MockColetaViewModel();
    _frequenciaGpsController = TextEditingController(text: '10');
    _intervaloMetrosController = TextEditingController(text: '20');
  }

  @override
  void dispose() {
    _frequenciaGpsController.dispose();
    _intervaloMetrosController.dispose();
    super.dispose();
  }

  void _alternarSensor(SensorColeta sensor, bool selecionado) {
    setState(() {
      if (selecionado) {
        _sensoresSelecionados.add(sensor);
      } else {
        _sensoresSelecionados.remove(sensor);
      }
      _erroSelecaoSensores = null;
    });
  }

  Future<void> _iniciarColeta() async {
    if (_isStartingRecording) {
      return;
    }

    final acelerometroSelecionado = _sensoresSelecionados.contains(
      SensorColeta.acelerometro,
    );
    final gpsSelecionado = _sensoresSelecionados.contains(SensorColeta.gps);
    if (!acelerometroSelecionado || !gpsSelecionado) {
      setState(() {
        _erroSelecaoSensores =
            'Acelerômetro e GPS são obrigatórios para iniciar a coleta.';
      });
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    final taxaGps = int.tryParse(_frequenciaGpsController.text.trim());
    final intervaloMetros = double.tryParse(
      _intervaloMetrosController.text.trim().replaceAll(',', '.'),
    );
    if (taxaGps == null || intervaloMetros == null) return;

    setState(() => _isStartingRecording = true);
    try {
      await _viewModel.prosseguirParaGravacao(
        configuracao: ConfiguracaoColeta(
          sensoresSelecionados: _sensoresSelecionados,
          taxaInercialHz: _taxaAquisicaoHz,
          taxaGpsHz: taxaGps,
          intervaloMetros: intervaloMetros,
        ),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Coleta simulada preparada com ${_sensoresSelecionados.length} sensores.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível iniciar a gravação: $error')),
      );
    } finally {
      if (mounted) setState(() => _isStartingRecording = false);
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
                ParametersSectionWidget(
                  sensoresSelecionados: _sensoresSelecionados,
                  onSensorChanged: _alternarSensor,
                  taxaAquisicaoHz: _taxaAquisicaoHz,
                  onTaxaAquisicaoChanged: (taxa) =>
                      setState(() => _taxaAquisicaoHz = taxa),
                  frequenciaGpsController: _frequenciaGpsController,
                  intervaloMetrosController: _intervaloMetrosController,
                  erroSelecaoSensores: _erroSelecaoSensores,
                ),
                const SizedBox(height: AppDimensions.space24),
                const InfoFooterWidget(), // Componente extraído
                const SizedBox(height: AppDimensions.space32),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: FilledButton.icon(
                    onPressed: _isStartingRecording ? null : _iniciarColeta,
                    icon: _isStartingRecording
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_circle_fill_rounded),
                    label: Text(
                      _isStartingRecording
                          ? 'Preparando gravação...'
                          : 'Prosseguir para gravação',
                    ),
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
