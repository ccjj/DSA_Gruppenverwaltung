// auth_service.dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../User/User.dart';
import 'LoginResult.dart';
import 'SignUpResultType.dart';

class AuthService {
  Future<LoginResult> login(String email, String password) async {
    try {
      final SignInResult result = await Amplify.Auth.signIn(
        username: email.trim(),
        password: password.trim(),
      );
      if (result.isSignedIn) {
        return LoginResult.success;
      }else if (result.nextStep.signInStep == AuthSignInStep.confirmSignUp) {
        return LoginResult.confirmEmail;
      }else if (result.nextStep != null) {
        print(result.nextStep.signInStep);
        //print(result.nextStep.signInStep == AuthSignInStep.confirmSignUp);
        EasyLoading.showError('New password required');
        return LoginResult.newPasswordRequired;
      } else {
        print(result);
        EasyLoading.showError('Login failed');
        return LoginResult.error;
      }
    } on InvalidStateException catch (e) {
      if (e.message == "A user is already signed in.") {
        return LoginResult.success;
      } else {
        EasyLoading.showError('Login error: ${e}');
        return LoginResult.error;
      }
    } catch (e) {
      print(e);
      EasyLoading.showError('Login error: ${e}');
      return LoginResult.error;
    }
  }

  Future<void> logout() async {
    try {
      await Amplify.Auth.signOut();
      EasyLoading.showSuccess('Logged out successfully');
      // Handle post-logout
    } catch (e) {
      EasyLoading.showError('Logout error: ${e}');
      // Handle exception
    }
  }

  Future<SignupResultType> signup(email, nickname, password) async {
    if(email.isEmpty || nickname.isEmpty || password.isEmpty){
      EasyLoading.showError('Alle Felder müssen ausgefüllt sein');
      return SignupResultType.error;
    }
    try {
      final result = await Amplify.Auth.signUp(
        username: email.trim(),
        password: password.trim(),
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email.trim(),
            AuthUserAttributeKey.nickname: nickname.trim(),
          },
        ),
      );

      if (result.isSignUpComplete) {
        EasyLoading.showSuccess('Signup OK');
        return SignupResultType.success;
      } else {
        print(result);
        EasyLoading.showError('Sign up not complete. Additional steps required');
        return SignupResultType.emailConfirmationRequired;
      }
    } on UsernameExistsException catch (e) {
      EasyLoading.showError('Benutzername oder Email existiert bereits');
      print(nickname);
      print(e);
    } catch (e) {
      EasyLoading.showError('$e');
    }
    return SignupResultType.error;
  }

  Future<bool> confirmSignUp(String email, String code) async {
    try {
      final SignUpResult result = await Amplify.Auth.confirmSignUp(
        username: email.trim(),
        confirmationCode: code.trim(),
      );

      if (result.isSignUpComplete) {
        EasyLoading.showSuccess('Email confirmed successfully');
        return true;
      } else {
        EasyLoading.showError('Sign up not complete. Additional steps required');
        print(result);
        print(result.toString().contains("email_verified"));
      }
    } on AuthException catch (e) {
      EasyLoading.showError('Failed to confirm email: ${e.message}');
    }
    return false;
  }


  Future<bool> resendConfirmationCode(String email) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
      EasyLoading.showInfo('Confirmation code resent');
      return true;
    } on AuthException catch (e) {
      EasyLoading.showError('Could not resend code - ${e.message}');
      return false;
    }
  }

  Future<User?> getAuthUser() async {
    //AuthUser authUser = await Amplify.Auth.getCurrentUser();
    List<AuthUserAttribute> attributes = await Amplify.Auth.fetchUserAttributes();
    print(attributes);
    String? uuid = attributes.firstWhereOrNull((attr) => attr.userAttributeKey.key == 'sub')?.value;
    String? name = attributes.firstWhereOrNull((attr) => attr.userAttributeKey.key == 'nickname')?.value;
    String? email = attributes.firstWhereOrNull((attr) => attr.userAttributeKey.key == 'email')?.value;
    if(name == null || email == null || uuid == null){
      return null;
    }
    return User(email: email, name: name, uuid: uuid);
  }

}
