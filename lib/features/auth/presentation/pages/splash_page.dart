import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 48, width: 48, child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Text('Preparando tu experiencia...'),
          ],
        ),
      ),
    );
  }
}
