import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:velora2/Services/global_methods.dart';
import 'package:velora2/Services/global_variables.dart';
import 'package:velora2/Widgets/the_app_bar.dart';

class CreateJob extends StatefulWidget {
  @override
  State<CreateJob> createState() => _CreateJobState();
}

class MaxValueInputFormatter extends TextInputFormatter {
  final int max;

  MaxValueInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final intValue = int.tryParse(newValue.text);
    if (intValue == null || intValue > max) {
      return oldValue;
    }
    return newValue;
  }
}

class _CreateJobState extends State<CreateJob> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobCatController = TextEditingController(
    text: '',
  );
  final TextEditingController _jobTitleController = TextEditingController(
    text: '',
  );
  final TextEditingController _jobDescController = TextEditingController(
    text: '',
  );
  final TextEditingController _jobTypeController = TextEditingController(
    text: '',
  );
  final TextEditingController _minAcaController = TextEditingController(
    text: '',
  );
  final TextEditingController _minWorkController = TextEditingController(
    text: '',
  );
  final TextEditingController _salaryController = TextEditingController(
    text: '',
  );
  final TextEditingController _finAppController = TextEditingController(
    text: '',
  );
  final TextEditingController _deadlineController = TextEditingController(
    text: '',
  );

  DateTime? dDate;
  Timestamp? dDateTimestamp;

  @override
  void dispose() {
    super.dispose();
    _jobCatController.dispose();
    _jobTypeController.dispose();
    _jobDescController.dispose();
    _jobTitleController.dispose();
    _minAcaController.dispose();
    _minWorkController.dispose();
    _deadlineController.dispose();
    _salaryController.dispose();
    _finAppController.dispose();
  }

  final List<String> jobCategoryList = [
    'Architecture & Construction',
    'Education & Training',
    'Development - Programming',
    'Business',
    'Information Technology',
    'Marketing Advertisement',
    'Art Producer',
  ];
  final List<String> academicLists = [
    'Primary School',
    'Secondary School',
    'College',
    'Diploma',
    'Bachelor',
    'Master',
    'Phd.',
    'Not Required',
  ];
  final List<String> jobTypeList = [
    'Permanent Role',
    'Internship',
    'Part Time',
    'Freelance',
  ];

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

  Widget _textField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          FilteringTextInputFormatter.digitsOnly,
          MaxValueInputFormatter(maxLength),
        ],
        controller: controller,
        enabled: enabled,
        key: ValueKey(valueKey),
        style: const TextStyle(color: Colors.white),
        maxLines: valueKey == 'JobDescription' ? 3 : 1,

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
    );
  }

  Widget _textFormField({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
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

  Widget _textFormFieldDate({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: IgnorePointer(
          // prevents keyboard from appearing on tap
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
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_month, color: Colors.white),
              // right-aligned icon
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
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
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

  File? imageFile;
  File? imageFile2;

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Please choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera();
                },
                child: Row(
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
                  _getFromGallery();
                },
                child: Row(
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
        );
      },
    );
  }

  void _showImageDialog2() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Please choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFromCamera2();
                },
                child: Row(
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
                  _getFromGallery2();
                },
                child: Row(
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
        );
      },
    );
  }

  void _pickDateDialog() async {
    dDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (dDate != null) {
      setState(() {
        _deadlineController.text =
            '${dDate!.day} - ${dDate!.month} - ${dDate!.year}';
        dDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(
          dDate!.microsecondsSinceEpoch,
        );
      });
    }
  }

  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromCamera2() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    _cropImage2(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery2() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    _cropImage2(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _cropImage2(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        imageFile2 = File(croppedImage.path);
      });
    }
  }

  void _onSubmit() async {
    final jobId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;

    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (_jobCatController == '') {
        GlobalMethod.showErrorDialog(
          error: "Please Select Job Category",
          ctx: context,
        );
        return;
      }
      if (_jobTypeController == '') {
        GlobalMethod.showErrorDialog(
          error: "Please Select Job Type",
          ctx: context,
        );
        return;
      }
      if (_minAcaController == '') {
        GlobalMethod.showErrorDialog(
          error: "Please Select Min. Academic Level",
          ctx: context,
        );
        return;
      }
      if (_deadlineController == '') {
        GlobalMethod.showErrorDialog(
          error: "Please Select Application Deadline",
          ctx: context,
        );
        return;
      }
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(
          error: "Please Select Logo File",
          ctx: context,
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      List<int> imageBytes = await imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      List<int> imageBytes2 = await imageFile2!.readAsBytes();
      String base64Image2 = base64Encode(imageBytes2);
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobImage': base64Image,
          'arImage': base64Image2,
          'jobTitle': _jobTitleController.text,
          'jobCat': _jobCatController.text,
          'jobType': _jobTypeController.text,
          'jobDesc': _jobDescController.text,
          'minAca': _minAcaController.text,
          'minWork': _minWorkController.text,
          'finApp': _finAppController.text,
          'deadline': _deadlineController.text,
          'deadlineTimestamp': dDateTimestamp,
          'salary': _salaryController.text,
          'jobComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _jobTitleController.clear();
        _jobCatController.clear();
        _jobDescController.clear();
        _jobTypeController.clear();
        _minWorkController.clear();
        _minAcaController.clear();
        _finAppController.clear();
        _deadlineController.clear();
        _salaryController.clear();
        imageFile = null;
        imageFile2 = null;
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: e.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Its not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TheAppBar(content: "Create Job", style: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 100),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _showImageDialog();
                                  },
                                  child: Container(
                                    width: size.width * 0.24,
                                    height: size.width * 0.24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: Color(0xFF689F77),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child:
                                          imageFile == null
                                              ? const Icon(
                                                Icons.camera_enhance_sharp,
                                                color: Color(0xFF689F77),
                                                size: 30,
                                              )
                                              : Image.file(
                                                imageFile!,
                                                fit: BoxFit.fill,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Second GestureDetector - Right aligned
                          GestureDetector(
                            onTap: () {
                              _showImageDialog2();
                            },
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Color(0xFF689F77),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    imageFile2 == null
                                        ? const Icon(
                                          Icons.view_in_ar,
                                          color: Color(0xFF689F77),
                                          size: 30,
                                        )
                                        : Image.file(
                                          imageFile2!,
                                          fit: BoxFit.fill,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Divider(thickness: 1),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textTitles(label: 'Job Title:'),
                        _textFormField(
                          valueKey: "JobTitle",
                          controller: _jobTitleController,
                          enabled: true,
                          fct: () {},
                          maxLength: 100,
                          hint: "Enter Job Title",
                        ),

                        _textTitles(label: "Job Category:"),
                        DropdownButtonFormField<String>(
                          value:
                              jobCategoryList.contains(_jobCatController.text)
                                  ? _jobCatController.text
                                  : null,
                          hint: Text(
                            "Select Job Category",
                            style: TextStyle(color: Color(0xFFD9D9D9)),
                          ),
                          decoration: _dropdownDecoration(),
                          dropdownColor: Colors.black87,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          items:
                              jobCategoryList.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _jobCatController.text = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a job category';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        _textTitles(label: "Job Type:"),
                        DropdownButtonFormField<String>(
                          value:
                              jobTypeList.contains(_jobTypeController.text)
                                  ? _jobTypeController.text
                                  : null,
                          hint: Text(
                            "Select Job Type",
                            style: TextStyle(color: Color(0xFFD9D9D9)),
                          ),
                          decoration: _dropdownDecoration(),
                          dropdownColor: Colors.black87,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          items:
                              jobTypeList.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _jobTypeController.text = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a job type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _textTitles(label: 'Job Description:'),
                        _textFormField(
                          valueKey: "JobDescription",
                          controller: _jobDescController,
                          enabled: true,
                          fct: () {},
                          maxLength: 255,
                          hint: "Enter Job Description",
                        ),

                        _textTitles(label: 'Min. Academic Level:'),
                        DropdownButtonFormField<String>(
                          value:
                              academicLists.contains(_minAcaController.text)
                                  ? _minAcaController.text
                                  : null,
                          hint: Text(
                            "Select Min. Academic Level",
                            style: TextStyle(color: Color(0xFFD9D9D9)),
                          ),
                          decoration: _dropdownDecoration(),
                          dropdownColor: Colors.black87,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          items:
                              academicLists.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _minAcaController.text = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a academic level';
                            }
                            return null;
                          },
                        ),

                        _textTitles(label: 'Min. Work Experience (year):'),
                        _textField(
                          valueKey: "minWork",
                          controller: _minWorkController,
                          enabled: true,
                          fct: () {},
                          maxLength: 50,

                          hint: "Enter Min. Work Experience (0 for no)",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        _textTitles(label: 'Finding Applicant:'),
                        _textField(
                          valueKey: "finApp",
                          controller: _finAppController,
                          enabled: true,
                          fct: () {},
                          maxLength: 9999,

                          hint: "Enter Min. Work Experience (0 for no)",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        _textTitles(label: 'Salary (month):'),
                        _textField(
                          valueKey: "salary",
                          controller: _salaryController,
                          enabled: true,
                          fct: () {},
                          maxLength: 1000000,
                          hint: "Enter Salary (month)",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        _textTitles(label: 'Job Deadline Date (dd/mm/yyyy):'),
                        _textFormFieldDate(
                          valueKey: "Post",
                          controller: _deadlineController,
                          enabled: false,
                          fct: () {
                            _pickDateDialog();
                          },

                          hint: "Select Deadline Date",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child:
                        _isLoading
                            ? CircularProgressIndicator()
                            : MaterialButton(
                              onPressed: () {
                                _onSubmit();
                              },
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
                                    const SizedBox(width: 9),
                                    Icon(
                                      Icons.upload_file,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
