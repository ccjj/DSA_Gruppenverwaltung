import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';

import '../globals.dart';

class MessageAmplifyService {
  StreamSubscription? subCreateMessage(String gruppeID) {
    StreamSubscription? subscription;
    const graphQLDocument = '''
          subscription OnCreateMessage(\$gruppeID: ID) {
              onCreateMessage(filter: {gruppeID: {eq: \$gruppeID}}) {
                  id
                  content
                  userId
              }
          }
      ''';

    var variables = <String, dynamic>{
      'gruppeID': gruppeID,
    };

    subscription = Amplify.API.subscribe(
      GraphQLRequest<String>(
        document: graphQLDocument,
        variables: variables,
      ),
      onEstablished: () => print('Subscription established'),
    ).listen((event) {
      print('New data: ${event.data}');
      if (event.data != null) {
        print(event.data);
        var newMessage = jsonDecode(event.data!);
        String? content = newMessage['onCreateMessage']?['content'];
        String? userId = newMessage['onCreateMessage']?['userId'];
        if(content != null && content.isNotEmpty){
          messageController.add(ChatMessage(messageContent: jsonDecode(content), groupId: gruppeID, timestamp: DateTime.now(), ownerId: userId!));
        }
        print('New message content: $content');
      }
    });

    // To handle errors and completion
    subscription.onError((error) => print('Error in subscription: $error'));
    subscription.onDone(() => print('Subscription completed'));

    return subscription;
  }

  Future<void> createMessage(String content, String gruppeID, String userId) async {
    const graphQLDocument = '''
      mutation CreateMessage(\$content: AWSJSON!, \$gruppeID: ID!, \$userId: String) {
        createMessage(input: {content: \$content, gruppeID: \$gruppeID, userId: \$userId}) {
          id
          content
          gruppeID
          userId
        }
      }
    ''';

    var variables = <String, dynamic>{
      'content': jsonEncode(content),
      'gruppeID': gruppeID,
      'userId': userId,
    };

    var request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: variables,
        authorizationMode: APIAuthorizationType.userPools
    );

    try {
      var response = await Amplify.API.mutate(request: request).response;
      print(response);
      print('Mutation result: ${response.data}');
    } catch (e) {
      print('Error creating message: $e');
    }
  }
}
