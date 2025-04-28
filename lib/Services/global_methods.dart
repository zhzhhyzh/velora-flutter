import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlobalMethod {


  static String formatDateWithSuperscript(dynamic input) {
    DateTime? date;

    // Handle Firestore Timestamp or DateTime directly
    if (input is Timestamp) {
      date = input.toDate();
    } else if (input is DateTime) {
      date = input;
    } else if (input is String) {
      try {
        date = DateFormat('d-M-yyyy').parseStrict(input);
      } catch (e) {
        return input; // Return the original string if parsing fails
      }
    } else {
      return input.toString();
    }

    final day = date.day;
    final month = DateFormat('MMM').format(date);
    final year = date.year;

    // Determine suffix
    String suffix;
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }

    // Superscript mapping
    final superscript = {
      'st': 'ˢᵗ',
      'nd': 'ⁿᵈ',
      'rd': 'ʳᵈ',
      'th': 'ᵗʰ',
    };

    return '$day${superscript[suffix]} $month $year';
  }


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