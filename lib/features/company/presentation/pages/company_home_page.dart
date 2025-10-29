import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/company_home_controller.dart';

class CompanyHomePage extends GetView<CompanyHomeController> {
  const CompanyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de empresa'),
        actions: [
          Obx(
            () => IconButton(
              icon: controller.loading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              onPressed: controller.loading.value ? null : controller.doLogout,
              tooltip: 'Cerrar sesion',
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.error.value != null) {
          return Center(
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const Center(
          child: Text('Gestion de vacantes y talento (muy pronto).'),
        );
      }),
    );
  }
}
