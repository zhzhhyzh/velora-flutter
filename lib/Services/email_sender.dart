import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailSender {

  final String apiKey = dotenv.env['BREVO_API_KEY']!;

  final String senderEmail = 'yeohzh-wp22@student.tarc.edu.my';
  final String senderName = 'VELORA';

  Future<void> sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String htmlContent,
    String? attachmentName,
    String? attachmentBase64,
  }) async {
    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

    final headers = {
      'api-key': apiKey,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'sender': {'email': senderEmail, 'name': senderName},
      'to': [
        {'email': toEmail, 'name': toName}
      ],
      'subject': subject,
      'htmlContent': htmlContent,
    };

    if (attachmentName != null && attachmentBase64 != null) {
      body['attachment'] = [
        {
          'content': attachmentBase64,
          'name': attachmentName,
        }
      ];
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 201 && response.statusCode != 202) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}