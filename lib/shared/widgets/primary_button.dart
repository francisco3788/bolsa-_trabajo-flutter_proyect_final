import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        child: loading
            ? const CircularProgressIndicator.adaptive()
            : Text(text),
      ),
    );
  }
}
