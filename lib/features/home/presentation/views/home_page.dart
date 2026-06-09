import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shajra/routes/app_routes.dart';
import '../widgets/greenhouse_map_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: const SingleChildScrollView(
          padding: EdgeInsets.only(top: 24, bottom: 24),
          child: GreenhouseMapWidget(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addGreenhouse),
        icon: const Icon(Icons.add),
        label: const Text('Add Greenhouse'),
      ),
    );
  }
}
