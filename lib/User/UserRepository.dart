import 'package:collection/collection.dart';

import '../User/User.dart';

class UserRepository {
  final List<User> _users = [];

  void addUser(User user) {
    _users.add(user);
  }

  List<User> getAllUsers() {
    return _users;
  }

  User? getUserByEmail(String email) {
    return _users.firstWhereOrNull((user) => user.email == email);
  }

  User? getUserById(String id) {
    return _users.firstWhereOrNull((user) => user.uuid == id);
  }

  void updateUser(User user) {
    final index = _users.indexWhere((u) => u.email == user.email);
    if (index != -1) {
      _users[index] = user;
    }
  }

  void deleteUser(String email) {
    _users.removeWhere((user) => user.email == email);
  }
}

