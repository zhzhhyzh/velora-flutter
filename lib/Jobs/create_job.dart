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
import 'package:velora2/Services/global_dropdown.dart';
import 'package:velora2/Widgets/the_app_bar.dart';

import '../Services/global_variables.dart';
import 'package:path_provider/path_provider.dart';

Future<File> _convertBase64ToFile(String base64Str, String fileName) async {
  final bytes = base64Decode(base64Str);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
class CreateJob extends StatefulWidget {
  final DocumentSnapshot? jobData;

  const CreateJob({Key? key, this.jobData}) : super(key: key);

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
  String buttonText = 'Post Now';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobCatController = TextEditingController(
    text: '',
  );
  final TextEditingController _jobTitleController = TextEditingController(
    text: '',
  );
  final TextEditingController _comNameController = TextEditingController(
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
  final TextEditingController _stateController = TextEditingController(
    text: '',
  );
  final TextEditingController _countryController = TextEditingController(
    text: '',
  );
  File? imageFile;
  File? imageFile2;
  DateTime? dDate;
  Timestamp? dDateTimestamp;
  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      final data = widget.jobData!.data() as Map<String, dynamic>;
      _jobTitleController.text = data['jobTitle'] ?? '';
      _comNameController.text = data['comName'] ?? '';
      _jobDescController.text = data['jobDesc'] ?? '';
      _jobCatController.text = data['jobCat'] ?? '';
      _jobTypeController.text = data['jobType'] ?? '';
      _minAcaController.text = data['minAca'] ?? '';
      _minWorkController.text = data['minWork'] ?? '';
      _salaryController.text = data['salary'] ?? '';
      _finAppController.text = data['finApp'] ?? '';
      _deadlineController.text = data['deadline'] ?? '';
      _stateController.text = data['state'] ?? '';
      _countryController.text = data['country'] ?? '';
      dDateTimestamp = data['deadlineTimestamp'];
      buttonText = widget.jobData != null ? "Save It" : "Post Now";
      if (data['jobImage'] != null) {
        _convertBase64ToFile(data['jobImage'], 'job_image.png').then((file) {
          setState(() {
            imageFile = file;
          });
        });
      }
      if (data['arImage'] != null) {
        _convertBase64ToFile(data['arImage'], 'ar_image.png').then((file) {
          setState(() {
            imageFile2 = file;
          });
        });
      }


    }
  }



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
    _comNameController.dispose();
    _stateController.dispose;
    _countryController.dispose;
  }

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
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      final jobId = widget.jobData != null ? widget.jobData!.id : Uuid().v4();
      final jobRef = FirebaseFirestore.instance.collection('jobs').doc(jobId);
      String? base64Image;
      String? base64Image2;

      if (imageFile != null) {
        final bytes = await imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }
      if (imageFile2 != null) {
        final bytes2 = await imageFile2!.readAsBytes();
        base64Image2 = base64Encode(bytes2);
      }
      final jobData = {
        'jobId': jobId,
        'uploadedBy': currentUser.uid,
        'email': currentUser.email,
        'jobImage': base64Image,
        'arImage': base64Image2,
        'jobTitle': _jobTitleController.text,
        'comName': _comNameController.text,
        'jobDesc': _jobDescController.text,
        'jobCat': _jobCatController.text,
        'jobType': _jobTypeController.text,
        'minAca': _minAcaController.text,
        'minWork': _minWorkController.text,
        'salary': _salaryController.text,
        'finApp': _finAppController.text,
        'deadline': _deadlineController.text,
        'deadlineTimestamp': dDateTimestamp,
        'state': _stateController.text,
        'country': _countryController.text,
        'updatedAt': Timestamp.now(),
      };

      if (widget.jobData != null) {
        await jobRef.update(jobData);
        Fluttertoast.showToast(msg: 'Job updated successfully');
      } else {
        jobData['createdAt'] = Timestamp.now();
        await jobRef.set(jobData);
        Fluttertoast.showToast(msg: 'Job created successfully');
      }

      Navigator.pop(context);
    } catch (e) {
      GlobalMethod.showErrorDialog(error: e.toString(), ctx: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                        _textTitles(label: 'Company Name:'),
                        _textFormField(
                          valueKey: "comName",
                          controller: _comNameController,
                          enabled: true,
                          fct: () {},
                          maxLength: 100,
                          hint: "Enter Company Name",
                        ),
                        Row(
                          children: [
                            // Country Dropdown
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value:
                                _countryController.text.isNotEmpty
                                    ? _countryController.text
                                    : null,
                                decoration: _dropdownDecoration(),
                                hint: Text(
                                  "Select Country",
                                  style: TextStyle(color: Color(0xFFD9D9D9)),
                                ),
                                items:
                                GlobalDD.countries.map((String country) {
                                  return DropdownMenuItem<String>(
                                    value: country,
                                    child: Text(country),
                                  );
                                }).toList(),
                                dropdownColor: Colors.black87,
                                iconEnabledColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                onChanged: (String? value) {
                                  setState(() {
                                    _countryController.text = value!;
                                    _stateController
                                        .clear(); // Reset state selection
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // State Dropdown
                            Expanded(
                              child:
                              _countryController.text.isEmpty
                                  ? GestureDetector(
                                onTap: () {
                                  GlobalMethod.showErrorDialog(
                                    error:
                                    "Please select country first",
                                    ctx: context,
                                  );
                                },
                                child: InputDecorator(
                                  decoration: _dropdownDecoration(),
                                  child: Text(
                                    "Select State",
                                    style: TextStyle(
                                      color: Color(0xFFD9D9D9),
                                    ),
                                  ),
                                ),
                              )
                                  : DropdownButtonFormField<String>(
                                value:
                                _stateController.text.isNotEmpty
                                    ? _stateController.text
                                    : null,
                                decoration: _dropdownDecoration(),
                                dropdownColor: Colors.black87,
                                iconEnabledColor: Colors.white,
                                hint: Text(
                                  "Select State",
                                  style: TextStyle(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                items:
                                (GlobalDD.states[_countryController
                                    .text] ??
                                    [])
                                    .map((String state) {
                                  return DropdownMenuItem<
                                      String
                                  >(
                                    value: state,
                                    child: Text(state),
                                  );
                                })
                                    .toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _stateController.text = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        _textTitles(label: "Job Category:"),
                        DropdownButtonFormField<String>(
                          value:
                          GlobalDD.jobCategoryList.contains(
                            _jobCatController.text,
                          )
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
                          GlobalDD.jobCategoryList.map((String category) {
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
                          GlobalDD.jobTypeList.contains(
                            _jobTypeController.text,
                          )
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
                          GlobalDD.jobTypeList.map((String type) {
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
                          maxLength: 1000,
                          hint: "Enter Job Description",
                        ),

                        _textTitles(label: 'Min. Academic Level:'),
                        DropdownButtonFormField<String>(
                          value:
                          GlobalDD.academicLists.contains(
                            _minAcaController.text,
                          )
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
                          GlobalDD.academicLists.map((String type) {
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

                          hint: "Enter No. of Applicants Finding",
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
                      color: Color(0xff689f77),
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
                              buttonText,
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