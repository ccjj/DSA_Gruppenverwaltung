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


  Future<String?> getHeldFileIdByHeldId(String heldID) async {
    String query = '''query GetHeldFileByHeldID(\$heldID: ID!) {
    heldFilesByHeldID(heldID: \$heldID) {
      items {
        id
        heldID
      }
    }
  }''';

    var variables = {
      'heldID': heldID,
    };

    try {
      var response = await Amplify.API.query(
        request: GraphQLRequest<String>(
          document: query,
          variables: variables,
        ),
      ).response;

      if(response.data == null) return null;

      var data = jsonDecode(response.data!);

      if (response.errors.isEmpty && data['heldFilesByHeldID']['items'].isNotEmpty) {
        // Return the file ID
        return data['heldFilesByHeldID']['items'][0]['id'];
      } else {
        print('No HeldFile found for this HeldID or errors occurred.');
        return null;
      }
    } catch (e) {
      print('Failed to fetch HeldFile: $e');
      return null;
    }
  }


  Future<void> updateHeldFile(String id, String xmlContent) async {
    String mutation = '''mutation UpdateHeldFile(\$input: UpdateHeldFileInput!) {
    updateHeldFile(input: \$input) {
      id
      fileContent
      heldID
      updatedAt
    }
  }''';

    var variables = {
      'input': {
        'id': id,
        'fileContent': xmlContent,
      },
    };

    try {
      var response = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: mutation,
          variables: variables,
        ),
      ).response;

      if (response.errors.isEmpty) {
        print('HeldFile updated successfully.');
      } else {
        print('Errors while updating: ${response.errors}');
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
      var existingHeldFileId = await getHeldFileByHeldID(heldID);

      // If a HeldFile exists, update it
      if (existingHeldFileId != null) {
        var fileId = await getHeldFileByHeldID(heldID);
        await updateHeldFile(existingHeldFileId, xmlContent);
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
