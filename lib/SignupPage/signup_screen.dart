import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:velora2/Services/global_methods.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();

  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  bool _isloading = false;
  String? _selectedPosition;
  final List<String> _positions = [
    'Student',
    'UI Designer',
    'UX Designer',
    'Product Designer',
    'Graphic Designer',
    'Freelancer',
    'Frontend Developer',
    'Backend Developer',
    'Project Manager',
    'Other',
  ];

  @override
  void dispose() {
    _animationController.dispose();
    _phoneTextController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _fullNameController.dispose();
    _selectedPosition = '';
    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _passFocusNode.dispose();
    _positionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
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
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethod.showErrorDialog(
          error: 'Please pick an image',
          ctx: context,
        );
        return;
      }
      setState(() {
        _isloading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextController.text.trim(),
        );
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        List<int> imageBytes = await imageFile!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': base64Image,
          'phoneNumber': _phoneTextController.text,
          'position': _selectedPosition,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isloading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      // <- Ensure this is at the top level if not already
      home: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/images3.jpg',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
              alignment: FractionalOffset(_animation.value, 0),
            ),
            Container(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 80,
                ),
                child: ListView(
                  children: [
                    Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showImageDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.cyanAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child:
                                      imageFile == null
                                          ? const Icon(
                                            Icons.camera_enhance_sharp,
                                            color: Colors.cyan,
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
                          const SizedBox(height: 20),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete:
                                () => FocusScope.of(
                                  context,
                                ).requestFocus(_passFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _fullNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Full name / Company name',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete:
                                () => FocusScope.of(
                                  context,
                                ).requestFocus(_emailFocusNode),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete:
                                () => FocusScope.of(
                                  context,
                                ).requestFocus(_phoneNumberFocusNode),
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passTextController,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 7) {
                                return 'Please enter a valid password (min. 7 characters)';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                              ),
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                color: Color(0xFFD9D9D9),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete:
                                () => FocusScope.of(
                                  context,
                                ).requestFocus(_positionFocusNode),
                            keyboardType: TextInputType.phone,
                            controller: _phoneTextController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
                            value: _selectedPosition,
                            focusNode: _positionFocusNode,
                            dropdownColor: Colors.black12,
                            iconEnabledColor: Colors.white,
                            hint: Text(
                              'Position',
                              style: TextStyle(color: Color(0xFFD9D9D9)),
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Position',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items:
                                _positions.map((position) {
                                  return DropdownMenuItem<String>(
                                    value: position,
                                    child: Text(position),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPosition = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          _isloading
                              ? Center(
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  child: const CircularProgressIndicator(),
                                ),
                              )
                              : MaterialButton(
                                onPressed: () {
                                  _submitFormOnSignUp();
                                },
                                color: Colors.cyan,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'SignUp',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          SizedBox(height: 40),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(text: '      '),
                                  TextSpan(
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap =
                                              () =>
                                                  Navigator.canPop(context)
                                                      ? Navigator.pop(context)
                                                      : null,
                                    text: 'Login',
                                    style: const TextStyle(
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
