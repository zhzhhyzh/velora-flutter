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
        GlobalMethod.convertBase64ToFile(data['jobImage'], 'job_image.png').then((file) {
          setState(() {
            imageFile = file;
          });
        });
      }
      if (data['arImage'] != null) {
        GlobalMethod.convertBase64ToFile(data['arImage'], 'ar_image.png').then((file) {
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
                                    GlobalMethod.showImagePickerDialog(
                                      context:context,
                                      onCameraTap: _getFromCamera,
                                      onGalleryTap: _getFromGallery,
                                    );
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
                              GlobalMethod.showImagePickerDialog(
                                context: context,
                                onCameraTap: _getFromCamera2,
                                onGalleryTap: _getFromGallery2,
                              );
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
                        GlobalMethod.textTitle(label: 'Job Title:'),
                        GlobalMethod.textFormField(
                          valueKey: "JobTitle",
                          controller: _jobTitleController,
                          enabled: true,
                          onTap: () {},
                          maxLength: 100,
                          hint: "Enter Job Title",
                        ),
                        GlobalMethod.textTitle(label: 'Company Name:'),
                        GlobalMethod.textFormField(
                          valueKey: "comName",
                          controller: _comNameController,
                          enabled: true,
                          onTap: () {},
                          maxLength: 100,
                          hint: "Enter Company Name",
                        ),
                        Row(
                          children: [
                            // Country Dropdown
                            Expanded(
                              child: GlobalMethod.dropdownFormField(
                                valueKey: "JobCategory",
                                selectedValue: _jobCatController.text.isNotEmpty ? _jobCatController.text : null,
                                itemsList: GlobalDD.jobCategoryList,
                                hint: "Select Job Category",
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

                            ),
                            const SizedBox(width: 10),
                            // State Dropdown
                            Row(
                              children: [
                                // Country Dropdown
                                Expanded(
                                  child: GlobalMethod.dropdownFormField(
                                    valueKey: "Country",
                                    selectedValue: _countryController.text.isNotEmpty ? _countryController.text : null,
                                    itemsList: GlobalDD.countries,
                                    hint: "Select Country",
                                    onChanged: (newValue) {
                                      setState(() {
                                        _countryController.text = newValue!;
                                        _stateController.clear();
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a country';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // State Dropdown
                                Expanded(
                                  child: _countryController.text.isEmpty
                                      ? GestureDetector(
                                    onTap: () {
                                      GlobalMethod.showErrorDialog(
                                        error: "Please select country first",
                                        ctx: context,
                                      );
                                    },
                                    child: InputDecorator(
                                      decoration: GlobalMethod.dropdownDecoration(),
                                      child: Text(
                                        "Select State",
                                        style: TextStyle(
                                          color: Color(0xFFD9D9D9),
                                        ),
                                      ),
                                    ),
                                  )
                                      : GlobalMethod.dropdownFormField(
                                    valueKey: "State",
                                    selectedValue: _stateController.text.isNotEmpty ? _stateController.text : null,
                                    itemsList: GlobalDD.states[_countryController.text] ?? [],
                                    hint: "Select State",
                                    onChanged: (newValue) {
                                      setState(() {
                                        _stateController.text = newValue!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a state';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),

                        GlobalMethod.textTitle(label: "Job Category:"),
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
                          decoration: GlobalMethod.dropdownDecoration(),
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
                        GlobalMethod.textTitle(label: "Job Type:"),
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
                          decoration: GlobalMethod.dropdownDecoration(),
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

                        GlobalMethod.textTitle(label: 'Job Description:'),
                        GlobalMethod.textFormField(
                          valueKey: "JobDescription",
                          controller: _jobDescController,
                          enabled: true,
                          onTap: () {},
                          maxLength: 1000,
                          hint: "Enter Job Description",
                        ),

                        GlobalMethod.textTitle(label: 'Min. Academic Level:'),
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
                          decoration: GlobalMethod.dropdownDecoration(),
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

                        GlobalMethod.textTitle(label: 'Min. Work Experience (year):'),
                        GlobalMethod.numberTextField(
                          valueKey: "minWork",
                          controller: _minWorkController,
                          enabled: true,

                          maxLength: 50,

                          hint: "Enter Min. Work Experience (0 for no)",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        GlobalMethod.textTitle(label: 'Finding Applicant:'),
                        GlobalMethod.numberTextField(
                          valueKey: "finApp",
                          controller: _finAppController,
                          enabled: true,

                          maxLength: 9999,

                          hint: "Enter No. of Applicants Finding",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        GlobalMethod.textTitle(label: 'Salary (month):'),
                        GlobalMethod.numberTextField(
                          valueKey: "salary",
                          controller: _salaryController,
                          enabled: true,

                          maxLength: 1000000,
                          hint: "Enter Salary (month)",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        GlobalMethod.textTitle(label: 'Job Deadline Date (dd/mm/yyyy):'),
                        GlobalMethod.dateTextFormField(
                          valueKey: "Post",
                          controller: _deadlineController,
                          enabled: false,
                          onTap: _pickDateDialog,
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
