import 'package:dsagruppen/login/LoginPage.dart';
import 'package:flutter/material.dart';

import '../globals.dart';
import 'AuthService.dart';
import 'EmailConfirmationPage.dart';
import 'SignUpResultType.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signup(email, nickname, password) async {
    SignupResultType signUpResult = await getIt<AuthService>().signup(email, nickname, password);
    if(signUpResult == SignupResultType.success){
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => LoginPage()));
      return;
    }
    if(signUpResult == SignupResultType.emailConfirmationRequired){
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => EmailConfirmationPage(email: _emailController.text)));
      return;
    }
    if(signUpResult == SignupResultType.error){
      //TODO was zu tun?
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anmelden'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Allows for scrolling when keyboard is open
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40), // Spacing
              Text(
                'Account erstellen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40), // Spacing
              _buildTextField(
                _nickNameController,
                labelText: 'Benutzername',
                icon: Icons.person,
              ),
              _buildTextField(
                _emailController,
                labelText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _passwordController,
                labelText: 'Passwort',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 30), // Spacing
              ElevatedButton(
                onPressed: () => _signup(_emailController.text, _nickNameController.text, _passwordController.text),
                child: Text('Anmelden'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String labelText, required IconData icon, bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
