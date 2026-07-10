import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(preferences);
  final apiClient = await ApiClient.persistent();

  runApp(SorakApp(localStorage: localStorage, apiClient: apiClient));
}
