import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadify_app/features/coleta/services/collection_permission_service.dart';
import 'package:roadify_app/features/coleta/viewmodels/coleta_viewmodel.dart';

void main() {
  test('requests location and only selected media permissions', () async {
    final requested = <Permission>[];
    final service = CollectionPermissionService(
      isLocationEnabled: () async => true,
      request: (permission) async {
        requested.add(permission);
        return PermissionStatus.granted;
      },
    );

    await service.requestForSensors({
      SensorColeta.acelerometro,
      SensorColeta.gps,
      SensorColeta.camera,
    });

    expect(requested, [Permission.locationWhenInUse, Permission.camera]);
    expect(requested, isNot(contains(Permission.microphone)));
  });

  test('fails before requesting permissions if location is disabled', () async {
    var permissionRequested = false;
    final service = CollectionPermissionService(
      isLocationEnabled: () async => false,
      request: (permission) async {
        permissionRequested = true;
        return PermissionStatus.granted;
      },
    );

    await expectLater(
      service.requestForSensors({SensorColeta.acelerometro, SensorColeta.gps}),
      throwsA(
        isA<CollectionPermissionException>().having(
          (error) => error.canOpenSettings,
          'canOpenSettings',
          true,
        ),
      ),
    );
    expect(permissionRequested, isFalse);
  });

  test('reports permanently denied selected permission', () async {
    final service = CollectionPermissionService(
      isLocationEnabled: () async => true,
      request: (permission) async => permission == Permission.camera
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.granted,
    );

    await expectLater(
      service.requestForSensors({
        SensorColeta.acelerometro,
        SensorColeta.gps,
        SensorColeta.camera,
      }),
      throwsA(
        isA<CollectionPermissionException>()
            .having((error) => error.canOpenSettings, 'canOpenSettings', true)
            .having((error) => error.message, 'message', contains('câmera')),
      ),
    );
  });
}
