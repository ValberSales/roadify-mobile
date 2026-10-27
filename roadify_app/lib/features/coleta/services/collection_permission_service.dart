import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../viewmodels/coleta_viewmodel.dart';

class CollectionPermissionException implements Exception {
  final String message;
  final bool canOpenSettings;
  final bool opensLocationSettings;

  const CollectionPermissionException(
    this.message, {
    this.canOpenSettings = false,
    this.opensLocationSettings = false,
  });

  @override
  String toString() => message;
}

class CollectionPermissionService {
  final Future<bool> Function() _isLocationEnabled;
  final Future<PermissionStatus> Function(Permission) _request;
  final Future<bool> Function() _openSettings;

  CollectionPermissionService({
    Future<bool> Function()? isLocationEnabled,
    Future<PermissionStatus> Function(Permission)? request,
    Future<bool> Function()? openSettings,
  }) : _isLocationEnabled =
           isLocationEnabled ?? Geolocator.isLocationServiceEnabled,
       _request = request ?? ((permission) => permission.request()),
       _openSettings = openSettings ?? openAppSettings;

  Future<void> requestForSensors(Set<SensorColeta> sensors) async {
    if (!await _isLocationEnabled()) {
      throw const CollectionPermissionException(
        'Ative a localização do dispositivo para registrar os pontos GPS.',
        canOpenSettings: true,
        opensLocationSettings: true,
      );
    }

    final permissions = <Permission, String>{
      Permission.locationWhenInUse: 'localização',
      if (sensors.contains(SensorColeta.camera)) Permission.camera: 'câmera',
      if (sensors.contains(SensorColeta.audio))
        Permission.microphone: 'microfone',
    };

    for (final entry in permissions.entries) {
      final status = await _request(entry.key);
      if (status.isGranted || status.isLimited) continue;

      final message = status.isPermanentlyDenied || status.isRestricted
          ? 'A permissão de ${entry.value} está bloqueada. Habilite-a nas configurações do aplicativo.'
          : 'A permissão de ${entry.value} foi negada. Ela é necessária para os recursos selecionados.';
      throw CollectionPermissionException(
        message,
        canOpenSettings: status.isPermanentlyDenied || status.isRestricted,
      );
    }
  }

  Future<bool> openSettings({bool locationService = false}) {
    if (locationService) return Geolocator.openLocationSettings();
    return _openSettings();
  }
}
