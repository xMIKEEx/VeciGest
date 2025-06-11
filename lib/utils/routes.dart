import 'package:flutter/material.dart';
import 'package:vecigest/utils/constants.dart';
import 'package:vecigest/presentation/auth/splash_page.dart';
import 'package:vecigest/presentation/auth/login_page.dart';
import 'package:vecigest/presentation/auth/register_page.dart';
import 'package:vecigest/presentation/home/home_page.dart';
import 'package:vecigest/presentation/chat/chat_page.dart';
import 'package:vecigest/presentation/incidents/incident_list_page.dart';
import 'package:vecigest/presentation/documents/doc_list_page.dart';
import 'package:vecigest/presentation/polls/modern_poll_page.dart';
import 'package:vecigest/presentation/auth/create_community_page.dart';
import 'package:vecigest/presentation/auth/invite_register_page.dart';
import 'package:vecigest/presentation/auth/admin_no_community_page.dart';
import 'package:vecigest/presentation/polls/new_poll_page.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart';
import 'package:vecigest/presentation/documents/upload_doc_page.dart';
import 'package:vecigest/presentation/documents/document_detail_page.dart';
import 'package:vecigest/presentation/chat/new_chat_group_page.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart';
import 'package:vecigest/presentation/reservations/new_reservation_page.dart';
import 'package:vecigest/presentation/properties/property_list_page.dart';
import 'package:vecigest/presentation/properties/property_detail_page.dart';
import 'package:vecigest/presentation/properties/invitations_list_page.dart';

// Import models for argument casting
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/domain/models/document_model.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/domain/models/property_model.dart';

class AppRoutes {
  static const String splash = splashRoute;
  static const String login = loginRoute;
  static const String register = '/register';
  static const String home = '/home';
  static const String threadList = '/thread-list';
  static const String chatMessages = '/chat-messages';
  static const String newChatGroup = '/new-chat-group';

  static const String incidents = '/incidents';
  static const String documents = '/documents';
  static const String polls = '/polls';
  static const String reservations = '/reservations';
  static const String properties = '/properties';
  static const String propertyDetail = '/property-detail';
  static const String invitations = '/invitations';
  static const String createCommunity = '/create-community';
  static const String inviteRegister = '/invite-register';
  static const String adminNoCommunity = '/admin-no-community';

  // Added route constants
  static const String pollDetail = '/poll-detail';
  static const String newPoll = '/new-poll';
  static const String incidentDetail = '/incident-detail';
  static const String newIncident = '/new-incident';
  static const String uploadDocument = '/upload-document';
  static const String documentDetail = '/document-detail';
  static const String newReservation = '/new-reservation';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case chatMessages:
        final args = settings.arguments;
        if (args is ThreadModel) {
          return MaterialPageRoute(builder: (_) => ChatPage(thread: args));
        }
        return _errorRoute(settings.name, "Expected ThreadModel argument");
      case incidents:
        return MaterialPageRoute(builder: (_) => const IncidentListPage());
      case documents:
        return MaterialPageRoute(builder: (_) => const DocListPage());
      case polls:
        return MaterialPageRoute(builder: (_) => const ModernPollPage());
      case reservations:
        return MaterialPageRoute(builder: (_) => const ReservationListPage());
      case createCommunity:
        return MaterialPageRoute(
          builder: (_) => const CreateCommunityPage(),
          settings: settings, // Pasar los settings que incluyen los argumentos
        );
      case inviteRegister:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => InviteRegisterPage(token: args),
          );
        }
        return _errorRoute(settings.name, 'Token de invitación requerido');
      case adminNoCommunity:
        return MaterialPageRoute(builder: (_) => const AdminNoCommunityPage());
      case newPoll:
        return MaterialPageRoute(builder: (_) => const NewPollPage());
      case incidentDetail:
        final args = settings.arguments;
        // Debug: incidentDetail route called with args: $args (type: ${args.runtimeType})
        if (args is IncidentModel) {
          // Debug: Creating IncidentDetailPage with incident: ${args.title}
          return MaterialPageRoute(
            builder: (_) => IncidentDetailPage(incident: args),
          );
        }
        // Debug: ERROR - Expected IncidentModel but got ${args.runtimeType}
        return _errorRoute(
          settings.name,
          "Expected IncidentModel argument, got ${args.runtimeType}",
        );
      case newIncident:
        return MaterialPageRoute(builder: (_) => const NewIncidentPage());
      case uploadDocument:
        return MaterialPageRoute(builder: (_) => const UploadDocPage());
      case documentDetail:
        final args = settings.arguments;
        if (args is DocumentModel) {
          return MaterialPageRoute(
            builder: (_) => DocumentDetailPage(document: args),
          );
        }
        return _errorRoute(settings.name, "Expected DocumentModel argument");
      case newChatGroup:
        return MaterialPageRoute(builder: (_) => const NewChatGroupPage());
      case properties:
        return MaterialPageRoute(builder: (_) => const PropertyListPage());
      case propertyDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['communityId'] != null) {
          return MaterialPageRoute(
            builder:
                (_) => PropertyDetailPage(
                  communityId: args['communityId'] as String,
                  property: args['property'],
                ),
          );
        }
        return _errorRoute(
          settings.name,
          "Missing required communityId argument",
        );
      case invitations:
        return MaterialPageRoute(builder: (_) => const InvitationsListPage());
      case newReservation:
        return MaterialPageRoute(builder: (_) => const NewReservationPage());
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? name, [String message = ""]) {
    // Debug: Log the error for troubleshooting
    // print('NAVIGATION ERROR: Route "$name" not found. Message: $message');

    // Show a proper error page instead of redirecting to home
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Error de navegación')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error de navegación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se pudo navegar a: $name',
                      textAlign: TextAlign.center,
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Detalle: $message',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).pushReplacementNamed('/home'),
                      child: const Text('Volver al inicio'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
