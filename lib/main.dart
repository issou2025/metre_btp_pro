import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'providers/app_state.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize French locale date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize Local Hive Database
  await StorageService.init();

  // Run the application wrapped in AppState
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState()..loadAllData(),
      child: const App(),
    ),
  );
}
