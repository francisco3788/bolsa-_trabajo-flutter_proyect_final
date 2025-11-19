import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/auth_texts.dart';

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

  Widget _buildFormCard(ColorScheme colorScheme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
            final requiresVerification = controller.requiresEmailVerification.value;
            final resendLoading = controller.resendLoading.value;
            final canResend = controller.canResendVerification;

            return Form(
              key: controller.formKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.auto_awesome, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(AuthTexts.signInTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Welcome back', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AuthTexts.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
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
                      labelText: AuthTexts.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    obscureText: isPasswordObscured,
                    validator: controller.validatePassword,
                    enabled: !isLoading,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: true,
                          onChanged: (_) {},
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Remember me', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () => Get.toNamed(AppRoutes.forgot),
                        child: const Text(AuthTexts.forgotPasswordLink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: error != null
                        ? Text(error, key: const ValueKey('err'), style: const TextStyle(color: Colors.red))
                        : const SizedBox.shrink(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: info != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(info!, key: const ValueKey('info'), style: const TextStyle(color: Colors.green)),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 14),
                  AnimatedScale(
                    scale: isLoading ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: PrimaryButton(
                      text: inCooldown
                          ? '${AuthTexts.signInWaitPrefix}$cooldown${AuthTexts.secondsSuffix})'
                          : AuthTexts.signInAction,
                      loading: isLoading,
                      enabled: !inCooldown,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: const Text("${AuthTexts.dontHaveAccount} ${AuthTexts.createAccountLink}"),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text('Powered by AI', style: TextStyle(fontSize: 12, color: colorScheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHero(ColorScheme colorScheme) {
    return SizedBox(
      height: 520,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 40,
            top: 60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary.withOpacity(0.12)),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.secondary.withOpacity(0.12)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.psychology, color: colorScheme.primary, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(AuthTexts.signInTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Smarter hiring starts here', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.08),
              colorScheme.secondary.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _buildHero(colorScheme)),
                        const SizedBox(width: 24),
                        _buildFormCard(colorScheme),
                      ],
                    )
                  : _buildFormCard(colorScheme),
            ),
          ),
        ),
      ),
    );
  }
}
