import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/primary_input.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    nameCtrl.addListener(() => controller.name.value = nameCtrl.text);
    emailCtrl.addListener(() => controller.email.value = emailCtrl.text);
    passCtrl.addListener(() => controller.password.value = passCtrl.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            children: [
              PrimaryInput(controller: nameCtrl, label: 'Nombre'),
              const SizedBox(height: 12),
              PrimaryInput(
                controller: emailCtrl,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              PrimaryInput(
                controller: passCtrl,
                label: 'Contraseña',
                obscure: true,
              ),
              const SizedBox(height: 16),
              if (controller.error.value != null)
                Text(
                  controller.error.value!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (controller.info.value != null)
                Text(
                  controller.info.value!,
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Registrarme',
                loading: controller.loading.value,
                onPressed: controller.loading.value
                    ? () {}
                    : controller.doRegister,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
