import 'package:flutter/material.dart';

class GlobalMethod {


  static void showErrorDialog({
    required String error,
    required BuildContext ctx,
    String title = 'An Error Occurred',
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.redAccent,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: ctx,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            error,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.onBackground,
              fontStyle: FontStyle.italic,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                if (onOk != null) onOk();
              },
              child: Text(
                'OK',
                style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
