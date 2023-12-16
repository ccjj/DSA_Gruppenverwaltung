import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/Gruppe/UpdateGruppeInput.dart';

import '../model/Note.dart';
import 'Gruppe.dart';

class GroupAmplifyService {

  Future<Gruppe?> createGruppe(String name) async {
    String now = DateTime.now().toIso8601String();
    const String graphQLDocument = '''
    mutation CreateGruppe(\$name: String!, \$datum: String) {
      createGruppe(input: {name: \$name, datum: \$datum}) {
        id
        name
        datum
        owner
      }
    }
  ''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {
        'name': name,
        'datum': now,
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final GraphQLResponse<String> response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        //print(response);
        print('Gruppe created successfully: ${response.data}');
        final responseData = jsonDecode(response.data!);
        final gruppeData = responseData['createGruppe'];

        return Gruppe.fromJson(gruppeData);
      } else {
        print('Gruppe creation completed, but no data returned');
      }
    } on ApiException catch (apiException) {
      print('Failed to create Gruppe: ${apiException.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
    return null;
  }

  Future<List<Gruppe>?> getGruppen() async {
    String graphQLDocument = '''query MyQuery {
  listGruppes {
    items {
      createdAt
      datum
      erstelltAm
      id
      name
      owner
      treffenAm
      updatedAt
      helden {
        items {
          id
        }
      }
      users {
        items {
          id
          name
        }
      }
    }
  }
}
''';

    try {
      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
        ),
      );

      var response = await operation.response;
      var data = jsonDecode(response.data!);

      List<Gruppe> gruppen = (data['listGruppes']['items'] as List)
          .map((item) => Gruppe.fromJson(item))
          .toList();
      //print('Query result: $data');
      //print(gruppen);
      return gruppen;

    } catch (e) {
      print('Query failed: $e');
    }
  return null;
  }


  Future<List<Gruppe>?> getGruppenByIds(List<String> ids) async {
    String orConditions = ids.map((id) => '{id: {eq: "$id"}}').join(',');

    String graphQLDocument = '''
    query GetGruppen {
      listGruppes(filter: {or: [$orConditions]}) {
        items {
          createdAt
          datum
          erstelltAm
          treffenAm
          id
          name
          owner
          updatedAt
          helden {
            items {
              id
            }
          }
          users {
            items {
              id
            }
          }
        }
      }
    }
  ''';


    try {
      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      //print("response");
      print(response);
      var data = jsonDecode(response.data!);

      List<Gruppe> gruppen = (data['listGruppes']['items'] as List)
          .map((item) => Gruppe.fromJson(item))
          .toList();
      print('Query result: $data');
      print(gruppen);
      return gruppen;

    } catch (e) {
      print('Query failed: $e');
    }
    return null;
  }

  Future<bool> deleteGruppe(String gruppeId) async {
    const String graphQLDocument = '''mutation DeleteGruppe(\$id: ID!) {
    deleteGruppe(input: {id: \$id}) {
      id
    }
  }''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {'id': gruppeId},
      authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      print(response);
      if(response.errors.isEmpty && !response.hasErrors) {
        return true;
      }
    } on ApiException catch (apiException) {
      print('Failed to delete Gruppe: ${apiException.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
    return false;
  }

  Future<Gruppe?> updateGruppe(Gruppe gruppe) async {
    const String graphQLDocument = '''
    mutation UpdateGruppe(\$input: UpdateGruppeInput!) {
      updateGruppe(input: \$input) {
        id
        name
        datum
        erstelltAm
        treffenAm
        owner
        helden {
          items {
            id
          }
        }
      }
    }
  ''';

    final gruppeJson = gruppe.toJson();
    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {'input': gruppeJson},
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final GraphQLResponse<String> response = await Amplify.API.mutate(request: request).response;
      safePrint(response);
      if (response.data != null) { //TODO and not containign error
        final responseData = jsonDecode(response.data!);
        final updatedGruppeData = responseData['updateGruppe'];

        return Gruppe.fromJson(updatedGruppeData);
      } else {
        print('Gruppe update completed, but no data returned');
      }
    } on ApiException catch (apiException) {
      print('Failed to update Gruppe: ${apiException.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
    return null;
  }

  Future<void> updateGruppeFromInput(UpdateGruppeInput gruppeInput) async {
    const String graphQLDocument = '''
    mutation UpdateGruppe(\$input: UpdateGruppeInput!) {
      updateGruppe(input: \$input) {
        id
        name
        datum
        treffenAm
      }
    }
  ''';

    final gruppeJson = gruppeInput.toJson();
    final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'input': gruppeJson},
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final GraphQLResponse<String> response = await Amplify.API.mutate(request: request).response;
      safePrint(response);
      if (response.data != null) { //TODO and not containign error
        final responseData = jsonDecode(response.data!);
        final updatedGruppeData = responseData['updateGruppe'];
        return;
        //return Gruppe.fromJson(updatedGruppeData);
      } else {
        print('Gruppe update completed, but no data returned');
      }
    } on ApiException catch (apiException) {
      print('Failed to update Gruppe: ${apiException.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
    return null;
  }

  Future<bool> createGruppeUser(String gruppeId, String userId) async {
    const String graphQLDocument = ''' 
    mutation CreateGruppeUser(\$gruppeId: ID!, \$userId: ID!) {
      createGruppeUser(input: {gruppeId: \$gruppeId, userId: \$userId}) {
        id
        gruppeId
        userId
      }
    }
  ''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {"gruppeId": gruppeId, "userId": userId},
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      if(!response.hasErrors){
        //final data = jsonDecode(response.data!);
        //return data;
        return true;
      }
      //print(response);
      //return GruppeUser.fromJson(data['createGruppeUser']);
    } catch (e) {
      // Handle exceptions
      print(e);
    }
    return false;
  }

  Future<List<Gruppe>?> getGruppenByUser(String userId) async {
    List<String>? groupIds = await gruppeUsersGruppeIdByUserId(userId);
    if(groupIds != null && groupIds.isNotEmpty){
      return await getGruppenByIds(groupIds);
    }
    return null;
  }

  Future<String?> findGruppeUserId(String userId, String gruppeId) async {
    try {
      String graphQLDocument = '''query ListGruppeUsers(\$filter: ModelGruppeUserFilterInput) {
      listGruppeUsers(filter: \$filter) {
        items {
          id
          gruppeId
          userId
        }
      }
    }''';

      var variables = {
        'filter': {
          'userId': {'eq': userId},
          'gruppeId': {'eq': gruppeId}
        }
      };

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: variables,
        ),
      );

      var response = await operation.response;
      if(response.hasErrors || response.data == null || response.data!.isEmpty){
        print("error getting groupusers");
        return null;
      }
      var data = jsonDecode(response.data!);

      return data['listGruppeUsers']['items'][0]['id'].toString();
    } catch (e) {
      print('Error fetching GruppeUser ID: ' + e.toString());
      return null;
    }
  }

  Future<List<String>?> gruppeUsersByGruppeId(String gruppeId) async {
    var query = '''
    query GruppeUsersByGruppeId(\$gruppeId: ID!) {
      gruppeUsersByGruppeId(gruppeId: \$gruppeId) {
        items {
          id
          userId
          gruppeId
        }
      }
    }
  ''';

    var operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: query,
        variables: {
          'gruppeId': gruppeId,
        },
          authorizationMode: APIAuthorizationType.userPools
      ),
    );

    var response = await operation.response;
    var data = jsonDecode(response.data!);
    if(response.hasErrors || response.data == null || response.data!.isEmpty){
      print("error getting gp users");
      return [];
    }
    //print("data");
    //print(data['gruppeUsersByGruppeId']['items']);
    List<String> userIds = (data['gruppeUsersByGruppeId']['items'] as List)
        .map((item) => item['userId'] as String)
        .toList();

    return userIds;
    //print(data);
    //return [];
    //return data['gruppeUsersByGruppeId']['items'][0]['id'];
  }

  Future<List<String>?> gruppeUsersGruppeIdByUserId(String userId) async {
    var query = '''
    query GruppeUsersByUserId(\$userId: ID!) {
      gruppeUsersByUserId(userId: \$userId) {
        items {
          gruppeId
        }
      }
    }
  ''';

    var operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: query,
        variables: {
          'userId': userId,
        },
      ),
    );

    var response = await operation.response;
    //TODO err handling
    if(!response.hasErrors) {
      var data = jsonDecode(response.data!);
      //print("data");
      //print(data);
      var items = data['gruppeUsersByUserId']['items'] as List;

      List<String> gruppeIds = items.map((item) => item['gruppeId'] as String).toList();
      //print("gruppeIds");
      //print(gruppeIds);
      return gruppeIds;
    }
    return null;
  }

  Future<bool> deleteGruppeUser(String gruppeUserId) async {
    const String graphQLDocument = ''' 
    mutation DeleteGruppeUser(\$id: ID!) {
      deleteGruppeUser(input: {id: \$id}) {
        id
      }
    }
  ''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {"id": gruppeUserId},
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      var result = await Amplify.API.mutate(request: request).response;
      print(result);
      if(result.hasErrors){
        return false;
      }
      return true;
    } catch (e) {
      // Handle exceptions
      print(e);
    }
    return false;
  }

  Future<void> deleteGruppeUserByGroup(String groupId) async {

    //TODO
    /*
    var guId = await gruppeUsersByGruppeId(groupId);
    if(guId != null){
      print("guid: " + guId);
      await deleteGruppeUser(guId);
    } else {
      print("ERR, null");
    }
    //find ID by groupId
    //delete by found ID
     */
  }

  Future<void> updateGruppeDatum(String gruppeId, String newDatum) async {
    const String graphQLDocument = '''
      mutation UpdateGruppeDatum(\$id: ID!, \$datum: String!) {
        updateGruppe(input: {id: \$id, datum: \$datum}) {
          id
          datum
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {
        'id': gruppeId,
        'datum': newDatum,
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      print(response);
      // Handle the response as needed
    } catch (e) {
      // Handle errors
      print('An error occurred while updating Gruppe datum: $e');
    }
  }

  Future<bool> updateGroupWithNote(String groupId, String noteId) async {
    try {
      String updateGroupMutation = '''
        mutation UpdateGroup(\$noteId: ID!, \$groupId: ID!) {
          updateGruppe(input: {gruppeNotesId: \$noteId, id: \$groupId}) {
            id
          }
        }
      ''';

      var response = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: updateGroupMutation,
          variables: {'noteId': noteId, 'groupId': groupId},
            authorizationMode: APIAuthorizationType.userPools
        ),
      ).response;
      print(response);
      var data = response.data;

      return data != null;
    } catch (e) {
      print('Error updating group with note: $e');
      return false;
    }
  }

  Future<bool> deleteNoteAndUpdateGroup(String groupId, String noteId) async {
    try {
      // GraphQL mutation for deleting a note and updating the group
      String graphQLDocument = '''
      mutation DeleteNoteAndUpdateGroup(\$groupId: ID!, \$noteId: ID!) {
        deleteNote(input: {id: \$noteId}) {
          id
        }
        updateGruppe(input: {id: \$groupId, noteId: null}) {
          id
          notes {
            id
          }
        }
      }
    ''';

      var variables = {'groupId': groupId, 'noteId': noteId};

      var operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
          variables: variables,
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      var data = response.data;

      return data != null;
    } catch (e) {
      print('Error deleting note and updating group: $e');
      return false;
    }
  }



}
