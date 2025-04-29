import 'package:flutter/material.dart';

import '../Widgets/the_app_bar.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TheAppBar(content: "About Velora", style: 2),

    backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Velora Application',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _sectionTitle('Purpose'),
            _sectionContent(
                "Velora is an integrated mobile application aimed at providing a seamless platform for "
                    "users to manage job-related activities. It helps users easily browse, apply, and post job opportunities, "
                    "making recruitment and job searching effortless and efficient."
            ),
            const SizedBox(height: 16),
            _sectionTitle('Background'),
            _sectionContent(
                "Velora was developed to address the growing need for a user-friendly platform that bridges "
                    "the gap between job seekers and recruiters. The platform utilizes modern mobile technologies, "
                    "cloud databases, and local caching (SQLite) to ensure smooth and fast user experience even "
                    "in limited internet conditions."
            ),
            const SizedBox(height: 16),
            _sectionTitle('How to Use'),
            _sectionContent(
                "1. Sign up or log in to your Velora account.\n"
                    "2. Explore available job listings in the 'Explore' tab.\n"
                    "3. Apply to jobs directly or save them for later viewing.\n"
                    "4. Recruiters can create and manage job posts easily.\n"
                    "5. Update your profile and manage settings in the Profile tab.\n"
                    "6. Filters are available to narrow down job searches based on categories, types, and academic levels.\n"
                    "7. Your job applications and postings are managed in 'Applied' and 'Posted' tabs respectively."
            ),
            const SizedBox(height: 16),
            _sectionTitle('Contact Us'),
            _sectionContent(
                "For any enquiries or technical problems, feel free to reach out:\n\n"
                    "- Email: support@veloraapp.com\n"
                    "- Phone: +6012-3456789\n"
                    "- Address: Velora Tech Solutions, Kuala Lumpur, Malaysia\n\n"
                    "We are here to assist you and ensure you have the best experience using Velora!"
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Thank you for using Velora!',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
