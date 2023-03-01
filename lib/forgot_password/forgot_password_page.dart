import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final mainScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void resetPassword() {
    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
    showNotifSnackbar(
        'Link Reset Password dikirim melalui email.', Colors.green);
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
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                validator: (value) => value == '' ? 'Don\'t Empty' : null,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(
                    Icons.email,
                  ),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      resetPassword();
                    }
                  },
                  child: const Text(
                    'Reset Password',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
