import 'package:face_recognition/CameraPage.dart';
import 'package:face_recognition/logs/logs.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../HomePage.dart';

appRoutes() => [
      GetPage(
        name: "/home",
        page: () => const HomePage(),
        middlewares: [RouteMiddleware()],
        transitionDuration: const Duration(milliseconds: 500),
      ),
  GetPage(
    name: "/camera",
    page: () => const CameraScreen(),
    middlewares: [RouteMiddleware()],
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: "/logs",
    page: () => const LogsPage(),
    middlewares: [RouteMiddleware()],
    transitionDuration: const Duration(milliseconds: 500),
  ),
    ];

class RouteMiddleware extends GetMiddleware {
  @override
  GetPage? onPageCalled(GetPage? page) {
    print(page?.name);
    return super.onPageCalled(page);
  }
}
