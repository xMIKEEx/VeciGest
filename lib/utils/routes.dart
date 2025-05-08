import 'package:flutter/material.dart';
import 'package:vecigest/utils/constants.dart';

// TODO: Replace with actual page imports
// import 'package:vecigest/presentation/splash/splash_page.dart';
// import 'package:vecigest/presentation/auth/login_page.dart';
// import 'package:vecigest/presentation/home/home_page.dart';
// import 'package:vecigest/presentation/chat/chat_page.dart';
// import 'package:vecigest/presentation/incidents/incidents_page.dart';
// import 'package:vecigest/presentation/documents/documents_page.dart';
// import 'package:vecigest/presentation/polls/polls_page.dart';

// Placeholder Widgets (Remove when actual pages are created)
class PlaceholderSplashPage extends StatelessWidget {
  const PlaceholderSplashPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Splash Page')));
}

class PlaceholderLoginPage extends StatelessWidget {
  const PlaceholderLoginPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login Page')));
}

class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home Page')));
}

class PlaceholderChatPage extends StatelessWidget {
  const PlaceholderChatPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chat Page')));
}

class PlaceholderIncidentsPage extends StatelessWidget {
  const PlaceholderIncidentsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Incidents Page')));
}

class PlaceholderDocumentsPage extends StatelessWidget {
  const PlaceholderDocumentsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Documents Page')));
}

class PlaceholderPollsPage extends StatelessWidget {
  const PlaceholderPollsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Polls Page')));
}
// End Placeholder Widgets

class AppRoutes {
  static const String splash = splashRoute;
  static const String login = loginRoute;
  static const String home = homeRoute;
  static const String chat = chatRoute;
  static const String incidents = incidentsRoute;
  static const String documents = documentsRoute;
  static const String polls = pollsRoute;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        // TODO: Replace with actual SplashPage
        return MaterialPageRoute(builder: (_) => const PlaceholderSplashPage());
      case loginRoute:
        // TODO: Replace with actual LoginPage
        return MaterialPageRoute(builder: (_) => const PlaceholderLoginPage());
      case homeRoute:
        // TODO: Replace with actual HomePage
        return MaterialPageRoute(builder: (_) => const PlaceholderHomePage());
      case chatRoute:
        // TODO: Replace with actual ChatPage
        return MaterialPageRoute(builder: (_) => const PlaceholderChatPage());
      case incidentsRoute:
        // TODO: Replace with actual IncidentsPage
        return MaterialPageRoute(
          builder: (_) => const PlaceholderIncidentsPage(),
        );
      case documentsRoute:
        // TODO: Replace with actual DocumentsPage
        return MaterialPageRoute(
          builder: (_) => const PlaceholderDocumentsPage(),
        );
      case pollsRoute:
        // TODO: Replace with actual PollsPage
        return MaterialPageRoute(builder: (_) => const PlaceholderPollsPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
