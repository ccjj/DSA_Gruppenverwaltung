import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/actions/ActionStack.dart';

import '../actions/ActionSource.dart';
import '../globals.dart';
import 'Held.dart';
import 'HeldRepository.dart';
import 'UpdateHeldInput.dart';
class HeldAmplifyService {
  final HeldRepository heldRepository;

  HeldAmplifyService(this.heldRepository);

  Future<Held?> createHeld(Held held) async {
//TODO amplify codegen models
    const String createMutation = '''
  mutation CreateHeld(\$input: CreateHeldInput!) {
    createHeld(input: \$input) {
      id
      name
      heldNummer
      rasse
      kultur
      ausbildung
      lp
      maxLp
      ap
      asp
      maxAsp
      at
      pa
      ini
      baseIni
      mr
      au
      maxAu
      gs
      ko
      kk
      mu
      kl
      ge
      intu
      ch
      ff
      so
      ke
      maxKe
      fk
      vorteile
      sf
      zauber
      ws
      kreuzer
      wunden
      geburtstag
      talents
      items
      gruppeID
    }
  }
''';
    final request = GraphQLRequest<String>(
      document: createMutation,
      variables: {
        'input': held.toJson(),
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      print(response);
      if (response.data != null) {
        return Held.fromJson(jsonDecode(response.data!));
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Held?> getHeldById(String heldId) async {
    try {
      const String getHeldQuery = r'''
      query GetHeld($id: ID!) {
        getHeld(id: $id) {
                ap
      ws
      updatedAt
      talents
      rasse
      pa
      owner
      mu
      name
      mr
      maxLp
      maxAu
      maxAsp
      lp
      kultur
      ko
      kl
      kk
      items
      intu
      ini
      id
      heldNummer
      gs
      gruppeID
      ge
      ff
      so
      ke
      maxKe
      fk
      vorteile
      sf
      zauber
      createdAt
      ch
      baseIni
      ausbildung
      au
      at
      asp
      kreuzer
      wunden
      geburtstag
        }
      }
      ''';

      var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: getHeldQuery,
          variables: {'id': heldId},
            authorizationMode: APIAuthorizationType.userPools
        ),
      );

      var response = await operation.response;
      //print(response);
      var data = response.data;

      if (data == null) {
        print("ITS NULL");
        return null;
      }

      var heldData = jsonDecode(data)['getHeld'];
      return Held.fromJson(heldData);
    } catch (e) {
      // Handle exceptions
      print('An error occurred while querying: $e');
      return null;
    }
  }

  Future<void> updateHeld(UpdateHeldInput input) async {
    try {
      const String graphQLDocument = '''
        mutation UpdateHeld(\$input: UpdateHeldInput!) {
          updateHeld(input: \$input) {
            id
            lp
            asp
            au
            kreuzer
            wunden
            items
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'input': input.toJson()},
          authorizationMode: APIAuthorizationType.userPools
      );

      final response = await Amplify.API.mutate(request: request).response;
      print(response);
    } catch (e) {
      // Handle errors
      print('An error occurred while updating Held: $e');
    }
  }

  Future<void> updateTODOHeld(String heldNummer, Held updatedHeld) async {
    const String updateMutation = '''
      mutation UpdateHeld(\$input: UpdateHeldInput!) {
        updateHeld(input: \$input) {
          // Fields of Held
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: updateMutation,
      variables: {
        'input': updatedHeld.toJson(),
      },
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      if (response.data != null) {
        // Parse response and update repository
        Held updatedHeld = Held.fromJson(jsonDecode(response.data!));
        heldRepository.updateHeld(heldNummer, updatedHeld);
      }
    } catch (e) {
      // Handle exceptions
      throw e;
    }
  }

  Future<void> deleteHeld(String uuid) async {
    // GraphQL mutation for deleting a Held
    const String deleteMutation = '''
      mutation DeleteHeld(\$input: DeleteHeldInput!) {
        deleteHeld(input: \$input) {
          id
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: deleteMutation,
      variables: {
        'input': {'id': uuid},
      },
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      final response = await Amplify.API.mutate(request: request).response;
      //print(response);
      if (response.data != null) {
        heldRepository.removeHeld(uuid);
      }
    } catch (e) {
      // Handle exceptions
      throw e;
    }
  }

  Future<List<Held>> getAllHelden() async {
    const String listHeldenQuery = '''
      query ListHelds {
        listHelds {
          items {
      ap
      ws
      updatedAt
      talents
      rasse
      pa
      owner
      mu
      name
      mr
      maxLp
      maxAu
      maxAsp
      lp
      kultur
      ko
      kl
      kk
      items
      intu
      ini
      id
      heldNummer
      gs
      
      gruppeID
      ge
      ff
      so
      ke
      maxKe
      fk
      vorteile
      sf
      zauber
      createdAt
      ch
      baseIni
      ausbildung
      au
      at
      asp
          }
        }
      }
    ''';

    final request = GraphQLRequest<String>(
      document: listHeldenQuery,
    );


      final response = await Amplify.API.query(request: request).response;
      //print(response);
      if (response.data != null) {
        final Map<String, dynamic> data = jsonDecode(response.data!);
        final heldenList = (data['listHelds']['items'] as List)
            .map((heldData) => Held.fromJson(heldData))
            .toList();
        return heldenList;
      } else {
        return [];
      }

  }


  Future<List<String>?> getHeldenIdsByGruppeId(String gruppeId) async {
    const query = r'''
    query listHelds2($groupId: ID!) {
      listHelds(filter: {gruppeID: {eq: $groupId}}) {
        items {
          id
        }
      }
    }
    ''';

    var operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: query,
        variables: <String, dynamic>{
          'groupId': gruppeId,
        },
        authorizationMode: APIAuthorizationType.userPools
      ),
    );

    //print("gruppeId");
    //print(gruppeId);
    var response = await operation.response;
    //print(response);
    //TODO err handling
    if(!response.hasErrors) {
      var data = jsonDecode(response.data!);
      //print("data");
      //print(data);
      var items = data['listHelds']['items'] as List;

      List<String> gruppeIds = items.map((item) => item['id'] as String).toList();
      //print("gruppeIds");
      //print(gruppeIds);
      return gruppeIds;
    }
    return null;
  }

  StreamSubscription? subHero(Held held) {
    StreamSubscription? subscription;
    const graphQLDocument = '''
          subscription MySubscription(\$heroId: ID!) {
              onUpdateHeld(filter: {id: {eq: \$heroId}}) {
                  id
                  lp
                  asp
                  au
                  kreuzer
                  wunden
              }
          }
      ''';

    var variables = <String, dynamic>{
      'heroId': held.uuid,
    };

    var actionService = getIt<ActionStack>();
    subscription = Amplify.API.subscribe(
      GraphQLRequest<String>(
        document: graphQLDocument,
        variables: variables,
      ),
      onEstablished: () => print('Subscription established'),
    ).listen((event) {
      print('New data: ${event.data}');
      if(event.data != null){
        var newStats = jsonDecode(event.data!);
        int? lp = newStats['onUpdateHeld']?['lp'] as int?;
        int? asp = newStats['onUpdateHeld']?['asp'] as int?;
        int? au = newStats['onUpdateHeld']?['au'] as int?;
        int? kreuzer = newStats['onUpdateHeld']?['kreuzer'] as int?;
        if(lp != null){
          actionService.handleUserAction(lp, "lp", ActionSource.server, ()=> held.lp.value = lp);
        }
        if(asp != null){
          actionService.handleUserAction(asp, "asp", ActionSource.server, ()=> held.asp.value = asp);
        }
        if(au != null){
          actionService.handleUserAction(au, "au", ActionSource.server, ()=> held.au.value = au);
        }
        if(kreuzer != null){
          actionService.handleUserAction(au, "kreuzer", ActionSource.server, ()=> held.kreuzer.value = kreuzer);
        }
        //TODO wunden, kreuzer
        //print('New data: $newStats)');
        //print('New data: ${newStats['onUpdateHeld']['id']}');
        //print('New data: ${newStats['onUpdateHeld']['lp']}');
      }
      // Parse event.data and handle the HP update
    });

    // To handle errors and completion
    subscription.onError((error) => print('Error in subscription: $error'));
    subscription.onDone(() => print('Subscription completed'));

    return subscription;
  }

//TODO refactor, same in group
  Future<bool> updateHeldWithNote(String heldId, String noteId) async {
    try {
      String updateGroupMutation = '''
        mutation UpdateHeld(\$noteId: ID!, \$heldId: ID!) {
          updateHeld(input: {heldNotesId: \$noteId, id: \$heldId}) {
            id
          }
        }
      ''';

      var response = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
            document: updateGroupMutation,
            variables: {'noteId': noteId, 'heldId': heldId},
            authorizationMode: APIAuthorizationType.userPools
        ),
      ).response;
      print(response);
      var data = response.data;

      return data != null;
    } catch (e) {
      print('Error updating held with note: $e');
      return false;
    }
  }


}
