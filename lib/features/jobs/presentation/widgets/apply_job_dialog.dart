import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/jobs_texts.dart';

class ApplyJobDialog extends StatefulWidget {
  final Function(String?) onApply;

  const ApplyJobDialog({super.key, required this.onApply});

  @override
  State<ApplyJobDialog> createState() => _ApplyJobDialogState();
}

class _ApplyJobDialogState extends State<ApplyJobDialog> {
  final TextEditingController _coverLetterController = TextEditingController();
  bool _isApplying = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(JobsTexts.applyForJobTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              JobsTexts.coverLetterOptionalLabel,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _coverLetterController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: JobsTexts.coverLetterHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isApplying ? null : () => Get.back(),
          child: const Text(JobsTexts.cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: _isApplying ? null : _handleApply,
          child: _isApplying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(JobsTexts.applyButtonLabel),
        ),
      ],
    );
  }

  void _handleApply() async {
    setState(() {
      _isApplying = true;
    });

    try {
      final coverLetter = _coverLetterController.text.trim();
      await widget.onApply(coverLetter.isEmpty ? null : coverLetter);
      Get.back();
      Get.snackbar(
        JobsTexts.success,
        JobsTexts.appliedSuccessMessage,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        JobsTexts.appliedErrorTitle,
        JobsTexts.appliedErrorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }
}
