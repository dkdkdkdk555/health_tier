import 'package:flutter/material.dart';
import 'package:my_app/util/spinner_utils.dart' show AppLoadingIndicator;

class SuccessAfterLoadingDialog extends StatefulWidget {
  const SuccessAfterLoadingDialog({super.key});

  @override
  State<SuccessAfterLoadingDialog> createState() => _SuccessAfterLoadingDialogState();
}

class _SuccessAfterLoadingDialogState extends State<SuccessAfterLoadingDialog> {
  bool _showCheckIcon = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showCheckIcon = true;
        });
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showCheckIcon
            ? const Icon(Icons.check_circle, color: Color(0xFF0D86E7), size: 44)
            : const AppLoadingIndicator(),
      ),
    );
  }
}
