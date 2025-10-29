import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller = Get.find<LoginController>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    controller.doLogin(
      email: emailController.text,
      password: passwordController.text,
    );
  }

  void _resendVerification() {
    controller.resendVerificationEmail(email: emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(() {
                final autovalidateMode = controller.showValidation.value
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled;
                final isLoading = controller.loading.value;
                final error = controller.error.value;
                final info = controller.info.value;
                final cooldown = controller.cooldownSeconds.value;
                final resendCooldown = controller.resendCooldownSeconds.value;
                final inCooldown = cooldown > 0;
                final isPasswordObscured = controller.isPasswordObscured.value;
                final requiresVerification =
                    controller.requiresEmailVerification.value;
                final resendLoading = controller.resendLoading.value;
                final canResend = controller.canResendVerification;

                return Form(
                  key: controller.formKey,
                  autovalidateMode: autovalidateMode,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: controller.togglePasswordVisibility,
                            icon: Icon(
                              isPasswordObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        obscureText: isPasswordObscured,
                        validator: controller.validatePassword,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      if (error != null)
                        Text(error, style: const TextStyle(color: Colors.red)),
                      if (info != null) ...[
                        const SizedBox(height: 8),
                        Text(info, style: const TextStyle(color: Colors.green)),
                      ],
                      if (requiresVerification) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: canResend ? _resendVerification : null,
                          icon: resendLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.mark_email_unread_outlined),
                          label: Text(
                            canResend
                                ? 'Reenviar verificación'
                                : resendCooldown > 0
                                ? 'Espera ${resendCooldown}s para reenviar'
                                : 'Reenviar verificación',
                          ),
                        ),
                      ],
                      if (inCooldown) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Espera ${cooldown}s antes de reintentar.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                        ),
                      ],
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: inCooldown
                            ? 'Entrar (espera ${cooldown}s)'
                            : 'Entrar',
                        loading: isLoading,
                        enabled: !inCooldown,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
                        child: const Text('¿No tienes cuenta? Crear cuenta'),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Get.toNamed(AppRoutes.forgot),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
