import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocketree/app/app.dart';
import 'package:pocketree/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await setupDependencies();
  runApp(const PocketreeApp());
}
