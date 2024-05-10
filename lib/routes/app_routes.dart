import 'package:get/get.dart';
import 'package:map_demo/views/map_view.dart';
import 'routes_name.dart';

class AppRoutes {
  static List<GetPage> allRoutes = [
    GetPage(
      name: RoutesNames.mapView,
      page: () => const MapViews(),
    )
  ];
}
