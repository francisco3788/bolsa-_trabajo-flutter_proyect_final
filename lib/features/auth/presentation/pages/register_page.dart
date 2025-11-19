import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/auth_texts.dart';

import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/primary_input.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    nameCtrl.addListener(() => controller.name.value = nameCtrl.text);
    emailCtrl.addListener(() => controller.email.value = emailCtrl.text);
    passCtrl.addListener(() => controller.password.value = passCtrl.text);

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withOpacity(0.08),
              scheme.secondary.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: scheme.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person_add, color: scheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(AuthTexts.createAccountTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 2),
                                  Text('Join the platform', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PrimaryInput(controller: nameCtrl, label: AuthTexts.nameLabel),
                          const SizedBox(height: 12),
                          PrimaryInput(
                            controller: emailCtrl,
                            label: AuthTexts.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          PrimaryInput(
                            controller: passCtrl,
                            label: AuthTexts.passwordLabel,
                            obscure: true,
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: controller.error.value != null
                                ? Text(controller.error.value!, key: const ValueKey('err'), style: const TextStyle(color: Colors.red))
                                : const SizedBox.shrink(),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: controller.info.value != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(controller.info.value!, key: const ValueKey('info'), style: const TextStyle(color: Colors.green)),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 14),
                          AnimatedScale(
                            scale: controller.loading.value ? 0.98 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: PrimaryButton(
                              text: AuthTexts.createAccountAction,
                              loading: controller.loading.value,
                              onPressed: controller.loading.value ? () {} : controller.doRegister,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.login),
                            child: const Text('${AuthTexts.alreadyHaveAccount} ${AuthTexts.signInLink}'),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
