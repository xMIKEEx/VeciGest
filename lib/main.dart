import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/utils/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asegúrate de tener configurado Firebase y, si usas flutterfire_cli,
  // que firebase_options.dart esté generado y la siguiente línea descomentada.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Si no usas flutterfire_cli o firebase_options.dart, usa:
  // await Firebase.initializeApp();
  print('Firebase apps: ${Firebase.apps}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeciGest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // themeMode: ThemeMode.system, // Opcional: para seguir el tema del sistema
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

// La clase MyHomePage y _MyHomePageState ya no son necesarias aquí
// y han sido eliminadas ya que la navegación se maneja a través de AppRoutes.
