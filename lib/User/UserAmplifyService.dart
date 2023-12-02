import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import 'User.dart';

//TODO remove gruppeID from schema
class UserAmplifyService {
  static const String _createUserMutation = '''
   mutation CreateUser(\$email: AWSEmail!, \$name: String!, \$id: ID!) {
        createUser(input: {email: \$email, name: \$name, id: \$id}) {
        id
        email
        name
      }
    }
  ''';

  static const String _getUserQuery = '''
    query GetUser(\$id: ID!) {
      getUser(id: \$id) {
        id
        email
        name
      }
    }
  ''';

  static const _updateUserMutation = '''
    mutation UpdateUser(\$id: ID!, \$email: String, \$name: String) {
      updateUser(input: {id: \$id, email: \$email, name: \$name}) {
        id
        email
        name
      }
    }
  ''';

  static const _deleteUserMutation = '''
    mutation DeleteUser(\$id: ID!) {
      deleteUser(input: {id: \$id}) {
        id
      }
    }
  ''';

  static const _findUsersQuery = '''query ListUsers(\$filter: ModelUserFilterInput) {
      listUsers(filter: \$filter) {
        items {
          id
          name
          email
          gruppeID
          createdAt
          updatedAt
          owner
        }
      }
    }''';

  Future<User?> createUser(String id, String email, String name) async {
    final request = GraphQLRequest<String>(
      document: _createUserMutation,
      variables: {
        'email': email,
        'name': name,
        'id': id
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      if(response.hasErrors){
        print(response);
        return null;
      }
      final responseData = jsonDecode(response.data!);
      //if(responseData.toString().contains("success")){
        return User(uuid: id, email: email, name: name);
      //}
    } on ApiException catch (e) {
      print('Failed to create user: ${e.message}');
      return null;
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  Future<User?> getUser(String id) async {
    final request = GraphQLRequest<String>(
      document: _getUserQuery,
      variables: {'id': id},
        authorizationMode: APIAuthorizationType.userPools
    );
print("ID " + id);
    try {
      final response = await Amplify.API.query(request: request).response;
      if(response.hasErrors){
        print(response);
        throw Exception();
        return null;
      }
      if(response.data == null || response.data!.isEmpty || response.data!.toString().contains("null") && !response.toString().contains("success")
      || jsonDecode(response.data!)['getUser'] == null
      ){
        print("RETURN NULL");
        return null;
      }

      String userId = "";
      String name = "";
      String email = "";
      print(response);
      var data = jsonDecode(response.data!);
print("data");
print(data);
      userId = data["getUser"]['id'];
      name = data["getUser"]['name'];
      email = data["getUser"]['email'];

      if(name.isEmpty || email.isEmpty || userId.isEmpty){
        return null;
      }
      return User(email: email, name: name, uuid: userId);
    } catch (e) {
      print('Failed to get user: $e');
      throw Exception();
      return null;
    }
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    // Construct the filter with multiple OR conditions
    var orConditions = ids.map((id) => {"id": {"eq": id}}).toList();
    var filter = {"or": orConditions};

    final request = GraphQLRequest<String>(
      document: '''
      query ListUsers(\$filter: ModelUserFilterInput) {
        listUsers(filter: \$filter) {
          items {
            email
            name
            id
          }
        }
      }
    ''',
      variables: {
        'filter': filter,
      },
    );

    try {
      final response = await Amplify.API.query(request: request).response;
      if(response.hasErrors || response.data == null || response.data!.isEmpty){
        print("error getting users or empty $response");
        return [];
      }
      final responseData = jsonDecode(response.data!);
      final List usersData = responseData['listUsers']['items'];
      return usersData.map((userJson) => User.fromJson(userJson)).toList();
    } on ApiException catch (e) {
      print('Failed to query users: ${e.message}');
      return [];
    } catch (e) {
      print('An unexpected error occurred: $e');
      return [];
    }
  }

  Future<bool> updateUser(String id, String email, String name) async {
    final request = GraphQLRequest<String>(
      document: _updateUserMutation,
      variables: {
        'id': id,
        'email': email,
        'name': name,
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      await Amplify.API.mutate(request: request).response;
      return true;
    } catch (e) {
      print('Failed to update user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    final request = GraphQLRequest<String>(
      document: _deleteUserMutation,
      variables: {'id': id},
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      var response = await Amplify.API.mutate(request: request).response;
      //TODO delete held, gruppenentries etc
      if(response.hasErrors){
        print(response);
        return false;
      }
      return true;
    } catch (e) {
      print('Failed to delete user: $e');
      return false;
    }
  }

  Future<List<User>> getUsersWithNameStartingWith(String nameStart) async {
    try {

      var variables = {
        'filter': {
          'name': {'beginsWith': nameStart}
        }
      };

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: _findUsersQuery,
          variables: variables,
        ),
      );

      var response = await operation.response;
      if(response.hasErrors || response.data == null || response.data!.isEmpty){
        print('Failed to query users, or empty result: $response');
        return [];
      }
      final responseData = jsonDecode(response.data!);
      final List usersData = responseData['listUsers']['items'];
      return usersData.map((userJson) => User.fromJson(userJson)).toList();

    } catch (e) {
      print('Error fetching users: ' + e.toString());
      return [];
    }
  }
}
