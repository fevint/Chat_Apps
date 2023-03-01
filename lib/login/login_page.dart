// ignore_for_file: avoid_print

import 'package:fcm_apps/dashboard/dashboard_page.dart';
import 'package:fcm_apps/forgot_password/forgot_password_page.dart';
import 'package:fcm_apps/register/register_page.dart';
import 'package:fcm_apps/utils/notif_controller.dart';
import 'package:fcm_apps/utils/prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../event/event_person.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordControlloer = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final mainScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void loginWithEmail() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordControlloer.text,
      );
      if (userCredential != null) {
        if (userCredential.user.emailVerified) {
          String token = await NotifController.getTokenFromDevice();
          print('success');
          showNotifSnackbar('Login ....', Colors.green);
          EventPerson.updatePersonToken(userCredential.user.uid, token);
          EventPerson.getPerson(userCredential.user.uid).then((person) {
            Prefs.setPerson(person);
          });
          Future.delayed(const Duration(milliseconds: 1700), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (route) => false);
          });

          emailController.clear();
          passwordControlloer.clear();
        } else {
          print('Not verified');
          showNotifSnackbar('Email not verified', Colors.red);
          mainScaffoldMessengerKey.currentState.showSnackBar(
            SnackBar(
              content: const Text('Email not Verified'),
              action: SnackBarAction(
                label: 'Send Verif',
                onPressed: () async {
                  await userCredential.user.sendEmailVerification();
                },
              ),
            ),
          );
        }
      } else {
        showNotifSnackbar('Failed', Colors.red);
        print('Failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Not user found for that email');
        showNotifSnackbar('Not user found for that email', Colors.red);
      } else if (e.code == 'wrong-password') {
        print('Wrong Password provided for that user.');
        showNotifSnackbar('Wrong Password provided for that user.', Colors.red);
      }
    }
  }

  void showNotifSnackbar(String message, Color color) {
    var snackBar = SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
      backgroundColor: color,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: mainScaffoldMessengerKey,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                bottom: 16,
                right: 0,
                left: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not have account?'),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                key: formKey,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/appstore.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: emailController,
                            validator: (value) =>
                                value == '' ? 'Don\'t Empty' : null,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(
                                Icons.email,
                              ),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: passwordControlloer,
                            validator: (value) =>
                                value == '' ? 'Don\'t Empty' : null,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                              ),
                            ),
                            obscureText: true,
                            textAlignVertical: TextAlignVertical.center,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword(),
                                  ));
                            },
                            child: const Text(
                              'Forgot Password ?',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  loginWithEmail();
                                }
                              },
                              child: const Text(
                                'Login',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
