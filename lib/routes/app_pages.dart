import 'package:get/get.dart';
import '../features/add_greenhouse/presentation/bindings/add_greenhouse_binding.dart';
import '../features/add_greenhouse/presentation/views/add_greenhouse_page.dart';
import '../features/shell/presentation/bindings/shell_binding.dart';
import '../features/shell/presentation/views/shell_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final pages = <GetPage>[
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
  ];
}
