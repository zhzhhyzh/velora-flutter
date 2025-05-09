

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../Services/global_dropdown.dart';
import '../Services/global_methods.dart';
import '../Widgets/the_app_bar.dart';

Future<File> _convertBase64ToFile(String base64Str, String fileName) async {
  final bytes = base64Decode(base64Str);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}

Future<DocumentSnapshot?> fetchDesignerDocByEmail(String email) async {
  final designersRef = FirebaseFirestore.instance.collection('designers');
  final query = await designersRef.where('email', isEqualTo: email).limit(1).get();
  if (query.docs.isNotEmpty) {
    return query.docs.first;
  }
  return null;
}

class RegisterOrEditDesigner extends StatefulWidget {
  final DocumentSnapshot? designerData;

  const RegisterOrEditDesigner({
    Key? key,
    this.designerData
  }) : super(key: key)
;
  @override
  State<RegisterOrEditDesigner> createState() => _RegisterDesignerState();
}


class _RegisterDesignerState extends State<RegisterOrEditDesigner> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _designerNameController = TextEditingController();
  final TextEditingController _minRateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _sloganController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? profileImage;
  List<File?> fetchedWorkImages = [];


  @override
  void iniState() {
    super.initState();
    _loadDesignerData();

  }

  Future<void> _loadDesignerData() async {
    if (widget.designerData != null) {
      final data = widget.designerData!.data() as Map<String, dynamic>;
      _designerNameController.text = data['name'] ?? '';
      _minRateController.text = data['rate'] ?? '';
      _categoryController.text = data['category'] ?? '';
      _stateController.text = data['state'] ?? '';
      _countryController.text = data['country'] ?? '';
      _descController.text = data['desc'] ?? '';
      _sloganController.text = data['slogan'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _emailController.text = data['email'] ?? '';

      if (data['profileImg'] != null) {
        _convertBase64ToFile(data['profileImg'], 'profileImg.png').then((file) {
          setState(() {
            profileImage = file;
          });
        });
      }

      if (data['workImgs'] != null) {
        for (var imageBase64 in data['workImgs']) {
          if (imageBase64 != null) {
            File workImg = await _convertBase64ToFile(imageBase64, 'workImg.png');
            fetchedWorkImages.add(workImg);
          }
          setState(() {
            fetchedWorkImages = fetchedWorkImages;
          });
        }
      }
      // Remove phone number prefix
      String fullContact = data['contact'] ?? '';
      if (_countryController.text == 'Malaysia' && fullContact.startsWith('+60')) {
        _contactController.text = fullContact.replaceFirst('+60', '');
      } else if (_countryController.text == 'United States' && fullContact.startsWith('+1')) {
        _contactController.text = fullContact.replaceFirst('+1', '');
      } else if (_countryController.text == 'India' && fullContact.startsWith('+91')) {
        _contactController.text = fullContact.replaceFirst('+91', '');
      } else {
        _contactController.text = fullContact;
      }
    } else {
      // Set current user's email if not editing existing designer
      _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _designerNameController.dispose();
    _minRateController.dispose();
    _categoryController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _descController.dispose();
    _sloganController.dispose();
    _contactController.dispose();
    _emailController.dispose();
  }

  String _formattedPhoneNumber() {
    String contact = _contactController.text.trim();
    if (_countryController.text == 'Malaysia') return '+60$contact';
    if (_countryController.text == 'United States') return '+1$contact';
    if (_countryController.text == 'India') return '+91$contact';
    return contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: TheAppBar(content: "Register Designer", style: 2),
        body:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child:
                    Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: GestureDetector(
                                    onTap: _showImageDialog,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: profileImage != null
                                          ? FileImage(profileImage!) : null,
                                      child: profileImage == null
                                          ? const Icon(
                                          Icons.camera_alt, size: 40, color: Colors.white)
                                          : null,
                                    ),
                                  )
                              ),
                              _textTitle(label: 'Designer Name:'),
                              _textFormField(
                                controller: _designerNameController,
                                keyboardType: TextInputType.text,
                                hintText: 'Enter Designer Name',
                                maxLength: 30,
                              ),

                              _textTitle(label: 'Contact No.:'),
                              _textFormField(
                                  controller: _contactController,
                                  keyboardType: TextInputType.number,
                                  hintText: 'Enter Phone No.',
                                  maxLength: 15,
                                  hideCounter: true
                              ),
                              _textTitle(label: 'Email:'),
                              _textFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.text,
                                  hintText: 'Enter Email',
                                  maxLength: 30,
                                  hideCounter: true,
                                  enabled: (_emailController.text != null || _emailController.text.isNotEmpty)
                                      ? false : true
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(thickness: 1),
                              ),
                              _textTitle(label: 'Category:'),
                              _dropdownButtonFormField(
                                  controller: _categoryController,
                                  hintText: 'Select Design Category',
                                  referenceList: GlobalDD.designCategoryList,
                                  alertMessage: 'Please select a category',
                                  onChanged: (newValue) {
                                    setState(() {
                                      _categoryController.text = newValue!;
                                    });
                                  },
                              ),
                              _textTitle(label: 'Minimum Rate:'),
                              _textFormField(
                                  controller: _minRateController,
                                  keyboardType: TextInputType.number,
                                  hintText: 'Enter Minimum Rate',
                                  maxLength: 10,
                                  hideCounter: true
                              ),

                              _textTitle(label: 'Location:'),
                              Row(
                                children: [
                                  Expanded(
                                      child: _dropdownButtonFormField(
                                        controller: _countryController,
                                        hintText: "Select Country",
                                        referenceList: GlobalDD.countries,
                                        alertMessage: 'Please select a country',
                                        onChanged: (String? value) {
                                          setState(() {
                                            _countryController.text = value!;
                                            _stateController.clear(); // Reset state selection
                                          });
                                        },
                                      )
                                  ),
                                  const SizedBox(width: 10),
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
                                    ) :
                                    _dropdownButtonFormField(
                                      controller: _stateController,
                                      hintText: "Select State",
                                      referenceList: (GlobalDD.states[_countryController.text] ?? []),
                                      alertMessage: 'Please select a state',
                                      onChanged: (String? value) {
                                        setState(() {
                                          _stateController.text = value!;
                                        });
                                      },
                                    )
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(thickness: 1),
                              ),
                              _textTitle(label: 'Slogan:'),
                              _textFormField(
                                controller: _sloganController,
                                keyboardType: TextInputType.text,
                                hintText: 'Enter Slogan',
                                maxLength: 40,
                              ),
                              _textTitle(label: 'Description:'),
                              _textFormField(
                                controller: _descController,
                                keyboardType: TextInputType.text,
                                hintText: 'Introduce Yourself',
                                maxLength: 1000,
                                multiline: true
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(thickness: 1),
                              ),
                              _textTitle(label: 'Work Images:'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: _showImageDialog,
                                    child: Container(
                                      width: 100 ,
                                      height: 100 ,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 2, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: (fetchedWorkImages.isEmpty)
                                            ? Icon(Icons.camera_enhance_outlined,color: Colors.grey)
                                            : Image.file(fetchedWorkImages[0]!)
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _showImageDialog,
                                    child: Container(
                                      width: 100 ,
                                      height: 100 ,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2, color: Colors.grey),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: (fetchedWorkImages.isEmpty)
                                              ? Icon(Icons.camera_enhance_outlined,color: Colors.grey)
                                              : Image.file(fetchedWorkImages[1]!)
                                      ),
                                    ),
                                  )

                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _resetScreen,
                          child: Text('Clear', style: TextStyle(color: Colors.red, fontSize: 15),)
                      ),
                      _isLoading ? CircularProgressIndicator()
                          : MaterialButton(
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            String formattedPhoneNumber = _formattedPhoneNumber();
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text('Confirmation'),
                                content: Text(widget.designerData != null
                                    ? 'Are you sure you want to update your designer profile?'
                                    : 'Are you sure you want to register as a designer?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel',style: TextStyle(color: Colors.red),),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff689f77)),
                                    child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _onSubmit(formattedPhoneNumber: formattedPhoneNumber);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        color: Color(0xff689f77) ,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
              )
            ],
          )
    );
  }

  void _resetScreen() {
    _designerNameController.clear();
    _minRateController.clear();
    _categoryController.clear();
    _stateController.clear();
    _countryController.clear();
    _descController.clear();
    _sloganController.clear();
    _contactController.clear();
    setState(() {
      profileImage = null;
      _emailController.text = currentUser?.email ?? '';
    });
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

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        profileImage = File(croppedImage.path);
      });
    }
  }

  Widget _textTitle({required String label}){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: 
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
    );
  }

  Widget _dropdownButtonFormField({
    required TextEditingController controller,
    required String hintText,
    required List<String> referenceList,
    required String alertMessage,
    required void Function(String?) onChanged
    }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty
          ? controller.text : null,
      hint: Text(hintText, style: TextStyle(color: Color(0xFFD9D9D9)),),
      decoration: _dropdownDecoration(),
      items: referenceList.map((String listItem) {
        return DropdownMenuItem<String>(
          value: listItem,
          child: Text(listItem),
        );
      }).toList(),
      dropdownColor: Colors.black87,
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      validator: (value) {
        (value == null || value.isEmpty)
            ? alertMessage : null;
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black54,
      hintStyle: const TextStyle(color: Color(0xFFb9b9b9)),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide.none,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
      ),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  String? _getPrefix(TextEditingController controller) {
    if (controller == _contactController) {
      if (_countryController.text == 'Malaysia') return '+60 ';
      if (_countryController.text == 'United States') return '+1 ';
      if (_countryController.text == 'India') return '+91 ';
    }
    if (controller == _minRateController) {
      if (_countryController.text == 'Malaysia') return 'MYR ';
      if (_countryController.text == 'United States') return 'USD ';
      if (_countryController.text == 'India') return 'INR ';
    }
    return null;
  }

  Widget _textFormField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required String hintText,
    required int maxLength,
    bool multiline = false,
    bool enabled = true,
    bool hideCounter = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child:
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: multiline ? 5 : 1 ,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefix: _getPrefix(controller) != null
                ? Text(
              _getPrefix(controller)!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )
                : null,
            counterText: hideCounter ? '' : null,
            enabled: enabled,
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide.none,
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

  void _onSubmit({required String formattedPhoneNumber}) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (profileImage == null) {
      Fluttertoast.showToast(msg: 'Please select a profile image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (currentUser == null) throw Exception('User not logged in');

      // Map designers Reference firestore 'designers' colloction
      final designersRef = FirebaseFirestore.instance.collection('designers');

      //  Check if current user already registered
      final existingDesignerQuery = await designersRef
          .where('email', isEqualTo: currentUser?.email ?? '')
          .limit(1)
          .get();

      final String designerId = existingDesignerQuery.docs.isNotEmpty
          ? existingDesignerQuery.docs.first.id
          : Uuid().v4();

      final DocumentReference designerDocRef = designersRef.doc(designerId);

      String? base64Image;
      if (profileImage != null) {
        base64Image = await _convertImageToBase64(profileImage);
      }

      List<String?> workImagesBase64 = await Future.wait(fetchedWorkImages.map((image) async {
        if (image != null) {
          return await _convertImageToBase64(image);
        }
      }));


      final designerData = {
        'designerId' : designerId,
        'name' : _designerNameController.text,
        'rate' : _minRateController.text,
        'contact' : formattedPhoneNumber,
        'email' : _emailController.text,
        'category' : _categoryController.text,
        'country' : _countryController.text,
        'state' : _stateController.text,
        'slogan' : _sloganController.text,
        'desc' : _descController.text,
        'profileImg' : base64Image,
        'workImgs' : workImagesBase64
      };

      if (existingDesignerQuery.docs.isNotEmpty) {
        //  Update existing designer
        await designerDocRef.update(designerData);
        Fluttertoast.showToast(msg: 'Designer profile updated successfully');
      } else {
        //  Create new designer
        await designerDocRef.set(designerData);
        Fluttertoast.showToast(msg: 'Designer registered successfully');
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

  Future<String?> _convertImageToBase64(File? imageFile) async {
    final bytes = await imageFile!.readAsBytes();
    return base64Encode(bytes);
  }
}
