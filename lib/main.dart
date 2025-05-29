import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/utils/theme.dart';
import 'package:vecigest/presentation/home/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asegúrate de tener configurado Firebase y, si usas flutterfire_cli,
  // que firebase_options.dart esté generado y la siguiente línea descomentada.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Si no usas flutterfire_cli o firebase_options.dart, usa:
  // await Firebase.initializeApp();
  print('Firebase apps: ${Firebase.apps}');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'VeciGest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      initialRoute:
          AppRoutes.splash, // Cambiado para que inicie en splash/login
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: (settings) {
        // Si la ruta no es conocida, redirigir al home
        return MaterialPageRoute(builder: (_) => const HomePage());
      },
    );
  }
}

// La clase MyHomePage y _MyHomePageState ya no son necesarias aquí
// y han sido eliminadas ya que la navegación se maneja a través de AppRoutes.
