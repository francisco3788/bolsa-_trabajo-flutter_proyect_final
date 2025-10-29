import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/jobs_home_controller.dart';

class JobsHomePage extends GetView<JobsHomeController> {
  const JobsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs Home'),
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
              tooltip: 'Cerrar sesión',
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
        return const Center(child: Text('Listado de ofertas (próximamente)'));
      }),
    );
  }
}
