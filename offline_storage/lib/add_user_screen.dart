import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'db_helper.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool isFetchingLocation = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLocationPermission();
  }

  Future<void> fetchLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = 'Location services are disabled.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage = 'Location permissions are permanently denied.';
      });
    } else {
      fetchCurrentLocation();
    }
  }

  Future<void> fetchCurrentLocation() async {
    setState(() {
      isFetchingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Simulate internet availability check
      final isConnected = await _isInternetConnected();
      if (isConnected) {
        _locationController.text =
            '${position.latitude}, ${position.longitude}';
      } else {
        _locationController.text = '';
      }
    } catch (e) {
      _locationController.text = '';
      debugPrint('Error fetching location: $e');
    } finally {
      setState(() {
        isFetchingLocation = false;
      });
    }
  }

  Future<bool> _isInternetConnected() async {
    try {
      final result = await http.get(Uri.parse('http://clients3.google.com'));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> addUser() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final email = _emailController.text;
    final location = _locationController.text;

    final db = DBHelper();
    final isConnected = await _isInternetConnected();

    if (isConnected) {
      try {
        await http.post(
          Uri.parse('http://192.168.2.16:3000/users'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': name, 'email': email, 'location': location}),
        );
        await db.insertUser({
          'name': name,
          'email': email,
          'location': location,
          'synced': 1,
        });
      } catch (_) {
        await db.insertUser({
          'name': name,
          'email': email,
          'location': location,
          'synced': 0,
        });
      }
    } else {
      await db.insertUser({
        'name': name,
        'email': email,
        'location': location,
        'synced': 0,
      });
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                readOnly: true,
              ),
              if (isFetchingLocation)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ElevatedButton(
                onPressed: addUser,
                child: const Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
