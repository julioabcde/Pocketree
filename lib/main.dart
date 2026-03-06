import 'package:flutter/material.dart';
import 'package:pocketree/app/app.dart';
import 'package:pocketree/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const PocketreeApp());
}
