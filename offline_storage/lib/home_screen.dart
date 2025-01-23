import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';
import 'add_user_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData(fromServer: true);
  }

  Future<void> loadData({required bool fromServer}) async {
    setState(() {
      isLoading = true;
    });

    final db = DBHelper();

    if (fromServer) {
      try {
        final response = await http.get(Uri.parse('http://192.168.2.16:3000/users'));
        if (response.statusCode == 200) {
          final data = List<Map<String, dynamic>>.from(json.decode(response.body));

          // Replace local database with server data
          await db.database.then((db) => db.delete('users'));
          for (var user in data) {
            await db.insertUser({
              'name': user['name'],
              'email': user['email'],
              'location': user['location'],
              'synced': 1,
            });
          }

          setState(() {
            users = data;
          });
        } else {
          throw Exception('Failed to fetch data from server');
        }
      } catch (e) {
        debugPrint('Error fetching data: $e');
      }
    }

    final localData = await db.getUsers();
    setState(() {
      users = localData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final newUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddUserPage(),
                ),
              );
              if (newUser != null) {
                await loadData(fromServer: false);
              }
            },
            child: const Text('Add User'),
          ),
          const SizedBox(width: 20,),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No users found'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          title: Text(user['name']),
                          subtitle: Text('Email: ${user['email']}'),
                          trailing: Text(
                              'Synced: ${user['synced'] == 1 ? 'Yes' : 'No'}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
