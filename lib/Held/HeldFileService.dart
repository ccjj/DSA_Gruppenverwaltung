import 'package:amplify_api/amplify_api.dart'; // For GraphQL requests
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

class HeldFileService {

  Future<void> createHeldFile(String heldId, String xmlContent) async {
    String mutation = '''mutation CreateHeldFile(\$heldID: ID!, \$fileContent: String!) {
      createHeldFile(input: {heldID: \$heldID, fileContent: \$fileContent}) {
        id
        heldID
        fileContent
      }
    }''';

    var variables = {'heldID': heldId, 'fileContent': xmlContent};

    try {
      var response = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: mutation,
          variables: variables,
            authorizationMode: APIAuthorizationType.userPools
        ),
      ).response;

      if (response.errors.isEmpty) {
        print('HeldFile created successfully.');
      } else {
        print('Errors: ${response.errors}');
      }
    } catch (e) {
      print('Failed to create HeldFile: $e');
    }
  }

  // Method to fetch HeldFile by heldID
  Future<String?> getHeldFileByHeldID(String heldID) async {
    String query = r'''query GetHeldFileByHeldID($heldID: ID!) {
    heldFilesByHeldID(heldID: $heldID) {
      items {
        id
        heldID
        fileContent
      }
    }
  }''';

    try {
      var response = await Amplify.API.query(
        request: GraphQLRequest<String>(
          document: query,
          variables: {'heldID': heldID},
          authorizationMode: APIAuthorizationType.userPools,
        ),
      ).response;

      var data = response.data;
      if(data == null) return null;
      var json = jsonDecode(data);
      return json?["heldFilesByHeldID"]?["items"]?[0]?["fileContent"];  // Here you can process the data as needed
    } catch (e) {
      print('Failed to fetch HeldFile by heldID: $e');
      return null;
    }
  }


  // Method to delete HeldFile by id
  Future<void> deleteHeldFile(String id) async {
    String mutation = '''mutation DeleteHeldFile(\$id: ID!) {
      deleteHeldFile(input: {id: \$id}) {
        id
      }
    }''';

    var variables = {'id': id};

    try {
      var response = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: mutation,
          variables: variables,
            authorizationMode: APIAuthorizationType.userPools
        ),
      ).response;

      if (response.errors.isEmpty) {
        print('HeldFile deleted successfully.');
      } else {
        print('Errors: ${response.errors}');
      }
    } catch (e) {
      print('Failed to delete HeldFile: $e');
    }
  }

  Future<void> updateHeldFileByHeldID(String heldID, String xmlContent) async {
    // Step 1: Fetch the HeldFile by heldID
    String query = r'''query GetHeldFileByHeldID($heldID: ID!) {
    getHeld(id: $heldID) {
      id
      file {
        id
        fileContent
      }
    }
  }''';

    try {
      var fetchResponse = await Amplify.API.query(
        request: GraphQLRequest<String>(
            document: query,
            variables: {'heldID': heldID},
            authorizationMode: APIAuthorizationType.userPools
        ),
      ).response;

      var data = fetchResponse.data;
      if(data == null) {
        print('data is null.');
        return;
      }

      // Extract the HeldFile id
      var heldFileId = extractHeldFileIdFromResponse(data); // You need to implement this function to extract the HeldFile ID.

      if (heldFileId == null) {
        print('No HeldFile found for the given HeldID.');
        return;
      }

      // Step 2: Update the HeldFile
      String mutation = '''mutation UpdateHeldFile(\$id: ID!, \$fileContent: String!) {
      updateHeldFile(input: {id: \$id, fileContent: \$fileContent}) {
        id
        fileContent
      }
    }''';

      var variables = {'id': heldFileId, 'fileContent': xmlContent};

      var updateResponse = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: mutation,
          variables: variables,
        ),
      ).response;

      if (updateResponse.errors.isEmpty) {
        print('HeldFile updated successfully.');
      } else {
        print('Errors while updating: ${updateResponse.errors}');
      }
    } catch (e) {
      print('Failed to update HeldFile: $e');
    }
  }

// Helper function to extract HeldFile ID from the response
  String? extractHeldFileIdFromResponse(String data) {
    final parsed = jsonDecode(data);
    return parsed['data']['getHeld']['file']['id'];
  }

  Future<void> updateOrCreateHeld(String heldID, String xmlContent) async {
    try {
      // First, attempt to get the HeldFile using the existing method
      var existingHeldFile = await getHeldFileByHeldID(heldID);

      // If a HeldFile exists, update it
      if (existingHeldFile != null) {
        await updateHeldFileByHeldID(heldID, xmlContent);
        print('HeldFile updated successfully.');
      } else {
        // If no HeldFile exists, create a new one
        await createHeldFile(heldID, xmlContent);
        print('HeldFile created successfully.');
      }
    } catch (e) {
      print('Failed to update or create HeldFile: $e');
    }
  }

}
