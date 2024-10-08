import 'package:dsagruppen/UserPreferences.dart';
import 'package:dsagruppen/login/EmailConfirmationPage.dart';
import 'package:dsagruppen/login/LoginResult.dart';
import 'package:dsagruppen/login/NewPasswordPage.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../GruppenOverviewScreen.dart';
import '../User/User.dart';
import '../User/UserAmplifyService.dart';
import '../globals.dart';
import 'AuthService.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isObscured = true;
  bool _rememberUsername = false;
  bool _rememberPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    String? savedEmail = await getIt<UserPreferences>().getUserEmail();
    String? savedPassword = await getIt<UserPreferences>().getUserPassword();

    setState(() {
      if (savedEmail != null) {
        _emailController.text = savedEmail;
        _rememberUsername = true;
      }
      if (savedPassword != null) {
        _passwordController.text = savedPassword;
        _rememberPassword = true;
      }
    });
  }


  Future<void> handleLogin(String email, String password) async {
    if(email.isEmpty || password.isEmpty){
      EasyLoading.showError('Email und Passwort dürfen nicht leer sein');
    }
    setState(() {
      _isLoading = true;
    });
    try {
      LoginResult loginStatus = await getIt<AuthService>().login(email, password);
      if (loginStatus == LoginResult.success || loginStatus.toString() == LoginResult.success.toString()) {
        var userResult = await getIt<AuthService>().getAuthUser();
        if(userResult == null){
          EasyLoading.showError("User nicht gefunden");
          return;
        }
        //TODO tmp, delete this later

        User? hasUser = await getIt<UserAmplifyService>().getUser(userResult.uuid);
        if(hasUser == null){
          EasyLoading.showError("gotuser");
          User? createdUser = await getIt<UserAmplifyService>().createUser(userResult.uuid, userResult.email, userResult.name);
          if(createdUser == null){
            EasyLoading.showError("something went wrong. please contact the administrator with this id: " + userResult.uuid);
            return;
          } else {
            EasyLoading.showSuccess("User in Table Users created");
          }
        }

        cu = userResult;
        //TODO
        //getIt<UserRepository>().addUser(cu);
        //probleme bei ios
        try {
          await getIt<UserPreferences>().saveUserEmail(
              _emailController.text.trim());
          await getIt<UserPreferences>().saveUserPassword(
              _passwordController.text.trim());
        } catch (_) {
        }
        navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GruppenOverviewScreen()), (route) => false);
        return;
      }
      if (loginStatus == LoginResult.confirmEmail) {
        navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => EmailConfirmationPage(email: email)));
      }
      if (loginStatus == LoginResult.newPasswordRequired) {
         navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const NewPasswordPage()));
      } else {
        print("unknown status $loginStatus");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;  // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text(appName,  style: TextStyle(
          fontFamily: 'Trajan Pro', fontSize: 46
        ))), // Replace with your app name
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView( // To avoid overflow when keyboard is visible
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: RepaintBoundary(
                          child: Animate(
                            child: SvgPicture.asset(
                              fit: BoxFit.contain,
                              'assets/images/Logo_L.svg',
                              height: 160,
                              colorFilter: ColorFilter.mode(themeNotifier.value == ThemeMode.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                            ).animate(autoPlay: true).rotate(duration: const Duration(seconds: 300)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Einloggen',
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                              )),
                      TextFormField(
                        enabled: !_isLoading,
                        controller: _emailController,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                            labelText: "Email",
                          ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 44,
                            child: Checkbox(
                              value: _rememberUsername,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberUsername = value ?? false;
                                });
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 8)),
                          const Text('Remember'),
                        ],
                      ),
                      TextField(
                        enabled: !_isLoading,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: 'Passwort',
                          suffixIcon: GestureDetector(
                            onTapDown: (_) {
                              setState(() {
                                _isObscured = false;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                _isObscured = true;
                              });
                            },
                            child: Icon(
                              _isObscured ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: _isObscured,
                        onSubmitted: (value) {
                          if (_isLoading) {
                            return;
                          }
                          setState(() => _isLoading = true);
                          handleLogin(_emailController.text, _passwordController.text);
                        },
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 44,
                            child: Checkbox(
                              value: _rememberPassword,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberPassword = value ?? false;
                                });
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 8)),
                          const Text('Remember'),
                        ],
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 160, // Set your desired width
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            onPressed: _isLoading ? null : () => handleLogin(_emailController.text, _passwordController.text),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Log In'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 120, // Ensure this width matches the above button
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: AsyncText(callback: () {
                return PackageInfo.fromPlatform().then((packageInfo) {
                  return 'v${packageInfo.version}';
                });
              },)),
        ],
      ),
    );
  }

}
