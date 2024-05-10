import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_demo/routes/app_routes.dart';
import 'package:map_demo/routes/routes_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesNames.mapView,
      getPages: AppRoutes.allRoutes,
    );
  }
}
