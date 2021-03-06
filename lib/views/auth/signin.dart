import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../CONSTANTS.dart';
import '../../utils/url_launcher.dart';
import '../../utils/snackbar.dart';
import '../customizable/editing_page.dart';
import '../preview/ads_wrapper.dart';
import '../widgets/reuseable.dart';
import 'register.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _authInstance = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignInLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    GetStorage().erase(); //to make sure it sign in as a new user.
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'dpImage',
                  child: Image.asset(
                    'images/logo/applogo.png',
                    width: 100,
                  ),
                ),
                SizedBox(height: 20),
                EmailTextField(emailController: _emailController),
                SizedBox(height: 10),
                PasswordTextField(passwordController: _passwordController),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSignInLoading
                      ? null
                      : () {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context).unfocus();
                            setState(() => _isSignInLoading = true);
                            _authInstance
                                .signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim())
                                .then((value) {
                              print('Sign in email password done');
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPage(),
                                  ));
                            }).catchError((error) {
                              print('ERROR: $error');
                              setState(() {
                                _isSignInLoading = false;
                                CustomSnack.showErrorSnack(context,
                                    message: 'Error: $error');
                              });
                            });
                          }
                        },
                  child:
                      _isSignInLoading ? LoadingIndicator() : Text('Sign in'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              bool _isResetPasswordLoading = false;

                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    title: Text(
                                        'Enter email you used to register with Flutree'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        EmailTextField(
                                          emailController: _emailController,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'A reset password link will be sent to your email.',
                                        )
                                      ],
                                    ),
                                    actions: [
                                      _isResetPasswordLoading
                                          ? LoadingIndicator()
                                          : SizedBox.shrink(),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (_emailController
                                              .text.isNotEmpty) {
                                            setDialogState(() =>
                                                _isResetPasswordLoading = true);
                                            try {
                                              await _authInstance
                                                  .sendPasswordResetEmail(
                                                      email: _emailController
                                                          .text
                                                          .trim());
                                              setDialogState(() =>
                                                  _isResetPasswordLoading =
                                                      false);
                                              Navigator.pop(context);
                                              CustomSnack.showSnack(context,
                                                  message: 'Email sent');
                                            } on FirebaseAuthException catch (e) {
                                              print('Err: $e');

                                              setDialogState(() =>
                                                  _isResetPasswordLoading =
                                                      false);
                                              Navigator.pop(context);
                                              CustomSnack.showErrorSnack(
                                                  context,
                                                  message: e.message);
                                            } catch (e) {
                                              print('Unknown err: $e');
                                              setDialogState(() =>
                                                  _isResetPasswordLoading =
                                                      false);
                                              CustomSnack.showErrorSnack(
                                                  context,
                                                  message: 'Unknown err');
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                      },
                      child: Text(
                        'Forgot password?',
                        style: dottedUnderlinedStyle(color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      child: Text(
                        'Register',
                        style: dottedUnderlinedStyle(),
                      ),
                    ),
                  ],
                ),
                HorizontalOrLine(label: 'OR'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[350],
                          onPrimary: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewPage(),
                              ));
                        },
                        icon: FaIcon(FontAwesomeIcons.eye, size: 15),
                        label: Text('Preview only')),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      onPressed: _isGoogleLoading
                          ? null
                          : () async {
                              setState(() => _isGoogleLoading = true);
                              try {
                                // Trigger the authentication flow
                                final GoogleSignInAccount googleUser =
                                    await GoogleSignIn().signIn();

                                // Obtain the auth details from the request
                                final GoogleSignInAuthentication googleAuth =
                                    await googleUser.authentication;

                                // Create a new credential
                                final GoogleAuthCredential credential =
                                    GoogleAuthProvider.credential(
                                  accessToken: googleAuth.accessToken,
                                  idToken: googleAuth.idToken,
                                );

                                // Once signed in, return the UserCredential
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential)
                                    .then(
                                  (value) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(),
                                        ));
                                  },
                                );
                              } on FirebaseAuthException catch (e) {
                                print('Error: $e');
                                setState(() => _isGoogleLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('ERROR: ${e.message}'),
                                  ),
                                );
                              } catch (e) {
                                print(
                                    'UNKNOWN ERROR CAUGHT GOOGLE SIGN IN: $e');
                                setState(() => _isGoogleLoading = false);
                              }
                            },
                      icon: FaIcon(FontAwesomeIcons.google, size: 15),
                      label: _isGoogleLoading
                          ? LoadingIndicator()
                          : Text('Sign in with Google'),
                    )
                  ],
                ),
                SizedBox(height: 15),
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 600 && kIsWeb) {
                    return GestureDetector(
                      onTap: () => launchURL(context, kPlayStoreUrl),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Image.network(
                          'https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png',
                          width: 280,
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
