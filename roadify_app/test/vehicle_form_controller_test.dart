import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/features/veiculos/presentation/widgets/form/vehicle_form_controller.dart';

void main() {
  late VehicleFormController controller;

  setUp(() {
    controller = VehicleFormController();
  });

  tearDown(() {
    controller.dispose();
  });

  test('validates legacy and Mercosul plates', () {
    expect(controller.validatePlate('ABC-1234'), isNull);
    expect(controller.validatePlate('ABC1D23'), isNull);
    expect(controller.validatePlate('AB-1234'), isNotNull);
  });

  test('validates year bounds', () {
    expect(controller.validateYear('1949'), isNotNull);
    expect(controller.validateYear('1950'), isNull);
    expect(controller.validateYear('${DateTime.now().year + 2}'), isNotNull);
  });

  test('accepts decimal comma but rejects non-finite odometers', () {
    expect(controller.validateOdometer('123,5'), isNull);
    expect(controller.validateOdometer('-1'), isNotNull);
    expect(controller.validateOdometer('NaN'), isNotNull);
    expect(controller.validateOdometer('Infinity'), isNotNull);
  });

  test('limits optional description length', () {
    expect(controller.validateDescription(''), isNull);
    expect(controller.validateDescription('x' * 250), isNull);
    expect(controller.validateDescription('x' * 251), isNotNull);
  });
}
