import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../model/Note.dart';

class NoteAmplifyService {


  Future<bool> saveNote(String noteId, String content, bool shouldCreate) async {
    try {
      String graphQLDocument;
      Map<String, dynamic> variables;

      if (shouldCreate) {
        graphQLDocument = '''
          mutation CreateNote(\$id: ID!, \$content: AWSJSON!) {
            createNote(input: {id: \$id, content: \$content}) {
              id
              content
            }
          }
        ''';
        variables = {'id': noteId, 'content': content};
      } else {
        // GraphQL mutation for updating an existing note
        graphQLDocument = '''
          mutation UpdateNote(\$id: ID!, \$content: AWSJSON!) {
            updateNote(input: {id: \$id, content: \$content}) {
              id
              content
            }
          }
        ''';
        variables = {'id': noteId, 'content': content};
      }

      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: variables,
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      print(response);
      var data = response.data;

      // Handle response here
      return data != null;
    } catch (e) {
      print('Error saving note: $e');
      return false;
    }
  }


  Future<Note?> getNoteForGroup(String groupId) async {
    try {
      String graphQLDocument = '''
        query GetGroup(\$id: ID!) {
          getGruppe(id: \$id) {
            id
            notes {
              id
              content
            }
          }
        }
      ''';

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
            document: graphQLDocument,
            variables: {'id': groupId},
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      print(response);
      var data = response.data;

      if (data != null) {
        var groupData = jsonDecode(data)['getGruppe'];
        if (groupData != null && groupData['notes'] != null) {
          return Note.fromJson(groupData['notes']);
        }
      }
    } catch (e) {
      print('Error fetching note for group: $e');
    }
    return null;
  }

  Future<Note?> getNoteForHeld(String heldId) async {
    try {
      String graphQLDocument = '''
        query GetHeld(\$id: ID!) {
          getHeld(id: \$id) {
            id
            notes {
              id
              content
            }
          }
        }
      ''';

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
            document: graphQLDocument,
            variables: {'id': heldId},
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      print(response);
      var data = response.data;

      if (data != null) {
        var groupData = jsonDecode(data)['getHeld'];
        if (groupData != null && groupData['notes'] != null) {
          return Note.fromJson(groupData['notes']);
        }
      }
    } catch (e) {
      print('Error fetching note for held: $e');
    }
    return null;
  }

}
