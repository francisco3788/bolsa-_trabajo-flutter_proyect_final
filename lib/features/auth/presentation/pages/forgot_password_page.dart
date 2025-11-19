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
    final scheme = Theme.of(context).colorScheme;
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
                      return AbsorbPointer(
                        absorbing: controller.loading.value,
                        child: Column(
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
                                  child: Icon(Icons.key, color: scheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(AuthTexts.resetPasswordTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                    SizedBox(height: 2),
                                    Text('Secure your account', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.step.value == 0 ? AuthTexts.step0Text : AuthTexts.step1Text,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            if (controller.step.value == 0) ...[
                              PrimaryInput(
                                controller: emailCtrl,
                                label: AuthTexts.emailLabel,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 16),
                              AnimatedScale(
                                scale: controller.loading.value ? 0.98 : 1.0,
                                duration: const Duration(milliseconds: 180),
                                child: PrimaryButton(
                                  text: AuthTexts.sendCodeAction,
                                  loading: controller.loading.value,
                                  onPressed: controller.submitEmail,
                                ),
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
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: controller.error.value != null
                                    ? Text(controller.error.value!, key: const ValueKey('err2'), style: const TextStyle(color: Colors.red))
                                    : const SizedBox.shrink(),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: controller.info.value != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(controller.info.value!, key: const ValueKey('info2'), style: const TextStyle(color: Colors.green)),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 16),
                              AnimatedScale(
                                scale: controller.loading.value ? 0.98 : 1.0,
                                duration: const Duration(milliseconds: 180),
                                child: PrimaryButton(
                                  text: AuthTexts.updatePasswordAction,
                                  loading: controller.loading.value,
                                  onPressed: controller.submitNewPassword,
                                ),
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
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Get.offAllNamed(AppRoutes.login),
                              child: const Text(AuthTexts.backToSignIn),
                            ),
                          ],
                        ),
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
