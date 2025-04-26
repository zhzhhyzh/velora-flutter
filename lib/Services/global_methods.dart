import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GlobalMethod {


  static Widget textTitle({
    required String label,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.black,
    EdgeInsetsGeometry padding = const EdgeInsets.all(5.0),
  }) {
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  static Widget textFormField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function() onTap,
    required int maxLength,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: onTap,
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(color: Colors.white),
          maxLines: valueKey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  static Widget dropdownFormField({
    required String valueKey,
    required String? selectedValue,
    required List<String> itemsList,
    required void Function(String?) onChanged,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      key: ValueKey(valueKey),
      decoration: dropdownDecoration(),
      dropdownColor: Colors.black87,
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      hint: Text(
        hint,
        style: const TextStyle(color: Color(0xFFD9D9D9)),
      ),
      items: itemsList.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
  static InputDecoration dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  static Widget dateTextFormField({
    required String valueKey,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    bool enabled = true,
    Color fillColor = Colors.black54,
    Color textColor = Colors.white,
    Color hintColor = const Color(0xFFb9b9b9),
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: onTap,
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            key: ValueKey(valueKey),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Value is missing';
              }
              return null;
            },
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_month, color: textColor),
              hintText: hint,
              hintStyle: TextStyle(color: hintColor),
              filled: true,
              fillColor: fillColor,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget numberTextField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    Color fillColor = Colors.black54,
    Color textColor = Colors.white,
    Color hintColor = const Color(0xFFb9b9b9),
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        key: ValueKey(valueKey),
        style: TextStyle(color: textColor),
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          filled: true,
          fillColor: fillColor,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
  static void showImagePickerDialog({
    required BuildContext context,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please choose an option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                onCameraTap();
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.camera, color: Colors.purple),
                  ),
                  Text('Camera', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                onGalleryTap();
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.image, color: Colors.purple),
                  ),
                  Text('Gallery', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  static Future<File> convertBase64ToFile(String base64Str, String fileName) async {
    final bytes = base64Decode(base64Str);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }
}
