import 'package:flutter/material.dart';

class UploadProjectScreen extends StatefulWidget {
  const UploadProjectScreen({super.key});

  @override
  State<UploadProjectScreen> createState() => _UploadProjectScreenState();
}

class _UploadProjectScreenState extends State<UploadProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isUploading = false;
  String? _selectedCategory;
  bool _hasImage = false;
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _titleError = _titleController.text.isEmpty ? 'Project title is required' : null;
    });
    return _titleController.text.isNotEmpty && _hasImage && _selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload Project',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasImage ? const Color(0xFF689f77) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _hasImage
                  ? Stack(
                      children: [
                        // TODO: Replace with actual image preview
                        Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _hasImage = false);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload project image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement file picker
                            setState(() => _hasImage = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF689f77),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Browse Files',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (!_hasImage) ...[
              const SizedBox(height: 8),
              const Text(
                '* Required',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Project Title *',
                labelStyle: const TextStyle(color: Colors.grey),
                errorText: _titleError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF689f77)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF689f77)),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Category *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'UI/UX',
                'Illustration',
                'Branding',
                'Animation',
                'Typography',
                'Web Design',
                'Mobile'
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: const Color(0xFF689f77),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            if (_selectedCategory == null) ...[
              const SizedBox(height: 8),
              const Text(
                '* Please select a category',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : () {
                  if (_validateForm()) {
                    setState(() => _isUploading = true);
                    // TODO: Implement upload
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() => _isUploading = false);
                      Navigator.pop(context);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689f77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Upload Project',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 