// ignore_for_file: avoid_print

import 'package:fcm_apps/event/event_person.dart';
import 'package:fcm_apps/models/Person/person.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordControlloer = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final mainScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void registerAccount() async {
    if (await EventPerson.checkEmail(emailController.text) == '') {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordControlloer.text,
        );
        if (userCredential.user.uid != null) {
          print('Register Success');
          Person person = Person(
            email: emailController.text,
            name: namaController.text,
            photo: '',
            token: '',
            uid: userCredential.user.uid,
          );
          EventPerson.addPerson(person);
          await userCredential.user.sendEmailVerification();
          showNotifSnackbar('Register Success', Colors.green);
        } else {
          print('Register Failed');
          showNotifSnackbar('Register Failed', Colors.red);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The Password provided is too weak.');
          showNotifSnackbar('The Password provided is too weak.', Colors.red);
        } else if (e.code == 'email-already-in-use') {
          print('The account already exits for that email');
          showNotifSnackbar(
              'The account already exits for that email', Colors.red);
        }
      }
    }
    namaController.clear();
    emailController.clear();
    passwordControlloer.clear();
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
                    const Text('Already have account ?'),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
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
                            controller: namaController,
                            validator: (value) =>
                                value == '' ? 'Don\'t Empty' : null,
                            decoration: const InputDecoration(
                              hintText: 'Nama',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                          const SizedBox(
                            height: 8,
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
                            onTap: () {},
                            child: const Text(
                              'Forget Password ?',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  registerAccount();
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
