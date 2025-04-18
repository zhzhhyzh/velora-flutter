import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:velora2/ForgotPassword/forget_password_screen.dart';
import 'package:velora2/Services/global_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velora2/SignupPage/signup_screen.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _emailTextController = TextEditingController(
    text: '',
  );
  final TextEditingController _passTextController = TextEditingController(
    text: '',
  );

  bool _isLoading = false;
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _passFocusNode = FocusNode();
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
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

  String? errorMessage;

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextController.text.trim(),
        );
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        if (error.toString().contains('firebase_auth/channel-error')) {
          errorMessage = "Please enter username and email.";
        } else if (error.toString().contains('invalid-credential')) {
          errorMessage = "Incorrect password.";
        } else {
          errorMessage = "Something went wrong. Please try again.";
        }
        GlobalMethod.showErrorDialog(error: errorMessage!, ctx: context);
        print('error occurred $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/images3.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset('assets/images/logo2.png'),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(

                          children: [
                            TextSpan(
                              text: "WELCOME TO ",
                              style: TextStyle(color: Colors.black, fontSize: 30),

                            ),
                            TextSpan(
                              text: "VELORA",
                              style: TextStyle(color: Color(0xFF689F77),  fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete:
                              () => {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_passFocusNode),
                              },

                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid Email Address';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
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
                        SizedBox(height: 5),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Please enter a valid password';
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(color: Colors.white),
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
                            hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
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
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPassword(),
                                ),
                              );
                            },
                            child: Text(
                              'Forget password? ',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        MaterialButton(
                          onPressed: _submitFormOnLogin,

                          color: Color(0xFF689f77),
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
                                  'Login',
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
                                const TextSpan(
                                  text: 'Do not have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(text: '        '),
                                TextSpan(
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap =
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SignUp(),
                                              ),
                                            ),
                                  text: 'Signup',
                                  style: const TextStyle(
                                    color: Color(0xFF0000FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'By signing in, you agree to our terms and conditions.',
                        style: TextStyle(color: Color(0xffF9F9F9)),
                      ),
                    )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
