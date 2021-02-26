import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linktree_iqfareez_flutter/CONSTANTS.dart';
import 'package:linktree_iqfareez_flutter/utils/urlLauncher.dart';
import 'package:linktree_iqfareez_flutter/views/auth/signin.dart';
import 'package:linktree_iqfareez_flutter/views/view/user_card.dart';
import 'package:linktree_iqfareez_flutter/views/widgets/reuseable.dart';
import 'package:lottie/lottie.dart';

class EnterCode extends StatefulWidget {
  @override
  _EnterCodeState createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/logo/applogo.png', width: 100),
                  Text('Enter Flutree code', style: TextStyle(fontSize: 28)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 60.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        validator: (value) =>
                            value.length != 5 ? 'Code must be 5 digit' : null,
                        controller: _codeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        setState(() => isLoading = true);
                        String code = _codeController.text.trim();
                        print('pressed');
                        _usersCollection.doc(code).get().then((value) {
                          print('snapshot is ${value.data()}');
                          setState(() => isLoading = false);
                          if (value.exists) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserCard(value)));
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: NotFoundDialog(),
                                );
                              },
                            );
                          }
                        }).catchError((Object error) {
                          print('Error: $error');
                          setState(() => isLoading = false);
                        });
                      }
                    },
                    child: !isLoading ? Text('Go') : LoadingIndicator(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 170,
                            child: Column(
                              children: [
                                Expanded(
                                  child: SizedBox.expand(
                                    child: TextButton.icon(
                                        icon:
                                            FaIcon(FontAwesomeIcons.googlePlay),
                                        onPressed: () {
                                          launchURL(context, kPlayStoreUrl);
                                        },
                                        label: Text(
                                          'Get app from Google Play Store\n(Recommended)',
                                          maxLines: 3,
                                        )),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox.expand(
                                    child: TextButton.icon(
                                        icon: FaIcon(FontAwesomeIcons.chrome),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignIn()));
                                        },
                                        label: Text(
                                          'Continue on browser\n(Beta)',
                                          maxLines: 3,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Want to make your own?',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.orange.shade700,
                            decorationStyle: TextDecorationStyle.dotted,
                            decoration: TextDecoration.underline)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class NotFoundDialog extends StatelessWidget {
  const NotFoundDialog({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'images/4958-404-not-found.json',
          ),
          Text(
              'User not found. Please try again or check the code if entered correctly.')
        ],
      ),
    );
  }
}
