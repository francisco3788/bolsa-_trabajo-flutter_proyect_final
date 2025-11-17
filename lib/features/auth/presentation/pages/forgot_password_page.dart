import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/auth_texts.dart';

import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/primary_input.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController controller;
  late final TextEditingController emailCtrl;
  late final TextEditingController codeCtrl;
  late final TextEditingController passwordCtrl;
  late final TextEditingController confirmCtrl;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ForgotPasswordController>();
    emailCtrl = TextEditingController();
    codeCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    confirmCtrl = TextEditingController();

    emailCtrl.addListener(() => controller.email.value = emailCtrl.text);
    codeCtrl.addListener(() => controller.code.value = codeCtrl.text);
    passwordCtrl.addListener(
      () => controller.newPassword.value = passwordCtrl.text,
    );
    confirmCtrl.addListener(
      () => controller.confirmPassword.value = confirmCtrl.text,
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    codeCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AuthTexts.resetPasswordTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => SingleChildScrollView(
            child: AbsorbPointer(
              absorbing: controller.loading.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.step.value == 0
                        ? AuthTexts.step0Text
                        : AuthTexts.step1Text,
                  ),
                  const SizedBox(height: 24),
                  if (controller.step.value == 0) ...[
                    PrimaryInput(
                      controller: emailCtrl,
                      label: AuthTexts.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: AuthTexts.sendCodeAction,
                      loading: controller.loading.value,
                      onPressed: controller.submitEmail,
                    ),
                  ] else ...[
                    PrimaryInput(
                      controller: emailCtrl,
                      label: AuthTexts.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    PrimaryInput(
                      controller: codeCtrl,
                      label: AuthTexts.verificationCodeLabel,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    PrimaryInput(
                      controller: passwordCtrl,
                      label: AuthTexts.newPasswordLabel,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    PrimaryInput(
                      controller: confirmCtrl,
                      label: AuthTexts.confirmPasswordLabel,
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
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: AuthTexts.updatePasswordAction,
                      loading: controller.loading.value,
                      onPressed: controller.submitNewPassword,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controller.loading.value
                          ? null
                          : () {
                              controller.resetFlow();
                              codeCtrl.clear();
                              passwordCtrl.clear();
                              confirmCtrl.clear();
                            },
                      child: const Text(AuthTexts.useAnotherEmail),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    child: const Text(AuthTexts.backToSignIn),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
