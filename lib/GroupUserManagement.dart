// group_user_management.dart
import 'dart:async';

import 'package:dsagruppen/Gruppe/GroupService.dart';
import 'package:dsagruppen/User/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'Gruppe/GroupAmplifyService.dart';
import 'MainScaffold.dart';
import 'User/UserAmplifyService.dart';
import 'globals.dart';

class GroupUserManagement extends StatefulWidget {
  final String groupId;
  final String name;

  const GroupUserManagement({super.key, required this.groupId, required this.name});

  @override
  GroupUserManagementState createState() => GroupUserManagementState();
}

class GroupUserManagementState extends State<GroupUserManagement> {
  List<User> users = []; // Aktuelle Benutzer der Gruppe
  List<User> searchResults = []; // Suchergebnisse
  String searchQuery = ''; // Suchbegriff
  var userAmplifyService = getIt<UserAmplifyService>();
  var groupAmplifyService = getIt<GroupAmplifyService>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadUsers() async {
    //TODO bundle into an own facette/function?
    var userIds = await groupAmplifyService.gruppeUsersByGruppeId(widget.groupId);
    if(userIds == null || userIds.isEmpty) return;
    var usersFound = await userAmplifyService.getUsersByIds(userIds);
    if(usersFound.isEmpty) return;
    setState(() {
      users = usersFound;
    });
  }

  void _searchUser(String query) async {
    //todo vorhandene ausblenden low prio
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
    searchQuery = query;
    List<User> users = await userAmplifyService.getUsersWithNameStartingWith(query);
    if(users.isEmpty) {
      setState(() {
        searchResults.clear();
      });
    } else {
      setState(() {
        //searchResults.clear();
        //searchResults.addAll(users);
        searchResults = users;
      });
    }
    });
  }


  // Benutzer zur Gruppe hinzufügen (Dummy-Funktion für das Beispiel)
  Future<void> _addUser(User user) async {
    if (!users.contains(user)) {
      var isAdded = await getIt<GroupService>().addUserToGroup(widget.groupId, user.uuid);
      if(!isAdded){
        print("error when adding user");
        return;
      }
      setState(() {
        users.add(user);
        //TODO
      });
      // Backend-Service aufrufen, um den Benutzer zur Gruppe hinzuzufügen
    }
  }

  // Benutzer aus der Gruppe entfernen (Dummy-Funktion für das Beispiel)
  Future<void> _removeUser(User user) async {
    var gruid = await groupAmplifyService.findGruppeUserId(user.uuid, widget.groupId);
    if(gruid == null){
      print("couldnt find the group to delete the rights");
      return;
    }
    var isDeleted = await groupAmplifyService.deleteGruppeUser(gruid);
    if(!isDeleted){
      EasyLoading.showError("Konnte Nutzerrechte nicht entfernen");
      return;
    }
    setState(() {
      users.remove(user);
    });
    // Backend-Service aufrufen, um den Benutzer aus der Gruppe zu entfernen
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Benutzerverwaltung für Gruppe ${widget.name}',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _searchUser,
              decoration: InputDecoration(
                labelText: 'Benutzer suchen',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(searchResults[index].name),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addUser(searchResults[index]),
                    ),
                  );
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Text("Hinzugefügte Benutzer", style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,)),
              ),
            ],
          ),
          Divider(),
          Flexible(
            flex: 3,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index].name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeUser(users[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
