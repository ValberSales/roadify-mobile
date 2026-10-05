enum SensorColeta { acelerometro, giroscopio, gps, camera, audio }

class ConfiguracaoColeta {
  final Set<SensorColeta> sensoresSelecionados;
  final int taxaInercialHz;
  final int taxaGpsHz;
  final double intervaloMetros;

  ConfiguracaoColeta({
    required Set<SensorColeta> sensoresSelecionados,
    required this.taxaInercialHz,
    required this.taxaGpsHz,
    required this.intervaloMetros,
  }) : sensoresSelecionados = Set.unmodifiable(sensoresSelecionados);

  /// Frequência de amostragem do sensor acelerômetro em Hz.
  int get taxaAcelerometroHz => taxaInercialHz;
}

abstract interface class ColetaViewModel {
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  });
}

class MockColetaViewModel implements ColetaViewModel {
  ConfiguracaoColeta? ultimaConfiguracao;

  @override
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  }) async {
    ultimaConfiguracao = configuracao;
  }
}
