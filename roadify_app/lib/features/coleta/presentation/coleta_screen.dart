import 'package:flutter/material.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/info_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/parameters_section_widget.dart';
import 'package:roadify_app/features/coleta/presentation/widgets/section_divider.dart';
import 'package:roadify_app/features/coleta/services/collection_permission_service.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../gravacao/gravacao_screen.dart';

class ColetaScreen extends StatefulWidget {
  final ColetaViewModel? viewModel;
  final CollectionPermissionService? permissionService;

  const ColetaScreen({super.key, this.viewModel, this.permissionService});

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ColetaViewModel _viewModel;
  late final CollectionPermissionService _permissionService;
  final Set<SensorColeta> _sensoresSelecionados = {
    SensorColeta.acelerometro,
    SensorColeta.gps,
  };
  late final TextEditingController _frequenciaGpsController;
  late final TextEditingController _intervaloMetrosController;
  OptionalSensorSettings _optionalSensorSettings =
      const OptionalSensorSettings();
  int _taxaAquisicaoHz = 100;
  String? _erroSelecaoSensores;
  bool _isStartingRecording = false;
  CollectionIdentification _identification = const CollectionIdentification(
    name: '',
    vehicle: null,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? MockColetaViewModel();
    _permissionService =
        widget.permissionService ?? CollectionPermissionService();
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
    if (_taxaAquisicaoHz <= 0) {
      setState(() {
        _erroSelecaoSensores =
            'Informe uma frequência válida para o acelerômetro.';
      });
      return;
    }

    final configuracao = ConfiguracaoColeta(
      sensoresSelecionados: _sensoresSelecionados,
      taxaInercialHz: _taxaAquisicaoHz,
      taxaGpsHz: taxaGps,
      intervaloMetros: intervaloMetros,
      sensoresOpcionais: _optionalSensorSettings,
      nomeColeta: _identification.name,
      vehicleId: _identification.vehicle?.id,
      odometroInicial: _identification.vehicle?.defaultOdometer ?? 0,
    );

    setState(() => _isStartingRecording = true);
    try {
      await _permissionService.requestForSensors(_sensoresSelecionados);
      if (!mounted) return;
      await _viewModel.prosseguirParaGravacao(configuracao: configuracao);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Coleta preparada com ${_sensoresSelecionados.length} sensores.',
          ),
        ),
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GravacaoScreen(configuracao: configuracao),
        ),
      );
    } on CollectionPermissionException catch (error) {
      if (!mounted) return;
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.lock_outline_rounded),
          title: const Text('Permissões necessárias'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Voltar'),
            ),
            if (error.canOpenSettings)
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Abrir configurações'),
              ),
          ],
        ),
      );
      if (openSettings == true) {
        await _permissionService.openSettings(
          locationService: error.opensLocationSettings,
        );
      }
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
      appBar: AppBar(
        toolbarHeight: 76,
        title: Text(
          'Nova coleta',
          style: context.typography.headlineSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                IdentificacaoSectionWidget(
                  onChanged: (identification) {
                    _identification = identification;
                  },
                ),
                const SizedBox(height: AppDimensions.space20),
                const SectionDivider(icon: Icons.tune_rounded),
                const SizedBox(height: AppDimensions.space20),
                ParametersSectionWidget(
                  sensoresSelecionados: _sensoresSelecionados,
                  onSensorChanged: _alternarSensor,
                  taxaAquisicaoHz: _taxaAquisicaoHz,
                  onTaxaAquisicaoChanged: (taxa) =>
                      setState(() => _taxaAquisicaoHz = taxa),
                  frequenciaGpsController: _frequenciaGpsController,
                  intervaloMetrosController: _intervaloMetrosController,
                  optionalSensorSettings: _optionalSensorSettings,
                  onOptionalSettingsChanged: (settings) {
                    setState(() => _optionalSensorSettings = settings);
                  },
                  erroSelecaoSensores: _erroSelecaoSensores,
                ),
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
