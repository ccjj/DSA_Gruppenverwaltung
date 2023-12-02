import 'package:dsagruppen/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../globals.dart';
import 'AuthService.dart';

class EmailConfirmationPage extends StatefulWidget {
  final String email;

  const EmailConfirmationPage({super.key, required this.email});

  @override
  EmailConfirmationPageState createState() => EmailConfirmationPageState();
}

class EmailConfirmationPageState extends State<EmailConfirmationPage> {
  final _confirmationCodeController = TextEditingController();
  bool hasSendCode = false;
  //TODO resend code button, sichtbar nach 1x code senden, timer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter the confirmation code sent to ${widget.email}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmationCodeController,
              decoration: const InputDecoration(labelText: 'Confirmation Code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var isSignedIn = await getIt<AuthService>().confirmSignUp(widget.email, _confirmationCodeController.text);
                if(isSignedIn){
                  navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => LoginPage()));
                }
                else {
                  EasyLoading.showToast("something went wrong");
                }

                setState(() {
                  hasSendCode = true;
                });
                },
              child: const Text('Confirm Email'),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: hasSendCode = true,
              child: ElevatedButton(
                onPressed: () async {
                  await getIt<AuthService>().resendConfirmationCode(widget.email);
                },
                child: const Text('Resend Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
