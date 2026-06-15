import 'package:get/get.dart';
import '../features/add_greenhouse/presentation/bindings/add_greenhouse_binding.dart';
import '../features/add_greenhouse/presentation/views/add_greenhouse_page.dart';
import '../features/greenhouse_details/presentation/bindings/greenhouse_details_binding.dart';
import '../features/greenhouse_details/presentation/views/greenhouse_details_page.dart';
import '../features/shell/presentation/bindings/shell_binding.dart';
import '../features/shell/presentation/views/shell_page.dart';
import '../features/splash/presentation/views/splash_page.dart';
import '../features/tree_details/presentation/bindings/tree_details_binding.dart';
import '../features/tree_details/presentation/views/tree_details_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const ShellPage(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.addGreenhouse,
      page: () => const AddGreenhousePage(),
      binding: AddGreenhouseBinding(),
    ),
    GetPage(
      name: AppRoutes.greenhouseDetails,
      page: () => const GreenhouseDetailsPage(),
      binding: GreenhouseDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.treeDetails,
      page: () => const TreeDetailsPage(),
      binding: TreeDetailsBinding(),
    ),
  ];
}
