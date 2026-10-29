import '../services/collection_preferences.dart';
import 'coleta_viewmodel.dart';

class PersistedColetaViewModel implements ColetaViewModel {
  final CollectionPreferences _preferences;

  PersistedColetaViewModel(this._preferences);

  @override
  Future<void> prosseguirParaGravacao({
    required ConfiguracaoColeta configuracao,
  }) async {
    configuracao.validarParaGravacao();
    await _preferences.save(configuracao);
  }
}
