import 'package:flutter/material.dart';
import 'package:velora2/Widgets/the_app_bar.dart';

class CreateJob extends StatefulWidget {
  @override
  State<CreateJob> createState() => _CreateJobState();
}

class _CreateJobState extends State<CreateJob> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobCatController = TextEditingController(
    text: 'Select Job Category',
  );
  final TextEditingController _jobTitleController = TextEditingController(
    text: '',
  );
  final TextEditingController _jobDescController = TextEditingController(
    text: '',
  );
  final TextEditingController _postController = TextEditingController(text: '');

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
    required String hint,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
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
          keyboardType: TextInputType.text,

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: "Create Job", style: 2),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.white10,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please fill up all fields',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Signatra',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(thickness: 1),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textTitles(label: "Job Category:"),
                        _textFormField(
                          valueKey: 'JobCategory',
                          controller: _jobCatController,
                          enabled: false,
                          fct: () {},
                          maxLength: 100,
                          hint: "Select Job Category",
                        ),
                        _textTitles(label: 'Job Title:'),
                        _textFormField(
                          valueKey: "JobTitle",
                          controller: _jobTitleController,
                          enabled: false,
                          fct: () {},
                          maxLength: 100,
                          hint: "Enter Job Title",
                        ),
                        _textTitles(label: 'Job Description:'),
                        _textFormField(
                          valueKey: "JobDescription",
                          controller: _jobDescController,
                          enabled: false,
                          fct: () {},
                          maxLength: 255,
                          hint: "Enter Job Description",
                        ),
                        _textTitles(label: 'Job Posted Date:'),
                        _textFormField(
                          valueKey: "Post",
                          controller: _postController,
                          enabled: false,
                          fct: () {},
                          maxLength: 255,
                          hint: "Enter Job Description",
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child:
                        _isLoading
                            ? CircularProgressIndicator()
                            : MaterialButton(
                              onPressed: () {},
                              color: Colors.black,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Text(
                                      'Post Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                    const SizedBox(width: 9,),
                                    Icon(Icons.upload_file, color: Color(0xffffffff),)
                                  ],
                                ),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
