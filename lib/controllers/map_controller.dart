import 'package:get/get.dart';

class MapController extends GetxController {
  final isFirstRun = Rx<bool>(true);
  final latitude = Rx<double?>(0.0);
  final longitude = Rx<double?>(0.0);
  final showCurrentLatd = true.obs;

  final stateLatitude = Rx<double?>(0.0);
  final stateLongitude = Rx<double?>(0.0);

  final hybridView = false.obs;

  final latitude2 = Rx<double>(0.0);
  final longitude2 = Rx<double>(0.0);
}
