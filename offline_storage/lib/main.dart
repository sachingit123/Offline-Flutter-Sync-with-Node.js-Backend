import 'dart:async';
import 'dart:convert';
import 'db_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offline_storage/home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  runApp(const MyApp());
}

void initializeService() {
  final service = FlutterBackgroundService();

  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Data Sync",
      content: "Listening for internet connectivity",
    );

    // Listen for internet connectivity changes
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        // Perform sync when connected to the internet
        await performSync();
      }
    });
  }
}

Future<void> performSync() async {
  try {
    final db = DBHelper();
    final unsyncedUsers = await db.getUnsyncedUsers();

    for (var user in unsyncedUsers) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.2.16:3000/users'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': user['name'],
            'email': user['email'],
            'location': user['location'],
          }),
        );

        if (response.statusCode == 201) {
          await db.updateSyncedUser(user['id']);
          debugPrint('User synced: ${user['name']}');
        }
      } catch (e) {
        debugPrint('Error syncing user: ${user['name']} - $e');
      }
    }
  } catch (e) {
    debugPrint('Unexpected error in performSync: $e');
  }
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Sync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}


//---------

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   initializeService();
//   runApp(const MyApp());
// }

// void initializeService() {
//   final service = FlutterBackgroundService();

//   service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );

//   service.startService();
// }
// void onStart(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     service.setForegroundNotificationInfo(
//       title: "Data Sync",
//       content: "Background sync in progress",
//     );
//     Timer.periodic(const Duration(seconds: 30), (timer) async {
//       await performSync();
//     });
//   }
// }

// Future<void> performSync() async {
//   final db = DBHelper();
//   final unsyncedUsers = await db.getUnsyncedUsers();

//   for (var user in unsyncedUsers) {
//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.2.16:3000/users'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'name': user['name'],
//           'email': user['email'],
//           'location': user['location'],
//         }),
//       );

//       if (response.statusCode == 201) {
//         await db.updateSyncedUser(user['id']);
//         debugPrint('User synced: ${user['name']}');
//       }
//     } catch (e) {
//       debugPrint('Failed to sync user: ${user['name']}, Error: $e');
//     }
//   }
// }

// bool onIosBackground(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Background Sync',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
