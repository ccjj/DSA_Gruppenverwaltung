import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../globals.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  NewPasswordPageState createState() => NewPasswordPageState();
}

class NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  void _submitNewPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final res = await Amplify.Auth.confirmSignIn(
          confirmationValue: _newPassword,
        );
        print(res);
        EasyLoading.showSuccess('Password changed successfully');
        navigatorKey.currentState?.pop(context);
      } on AuthException catch (e) {
        EasyLoading.showError('Error: ${e.message}');
        print(e.message);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set New Password'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                onChanged: (value) => _newPassword = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                onChanged: (value) => _confirmPassword = value,
                validator: (value) {
                  if (value != _newPassword) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitNewPassword,
                child: Text('Set New Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
