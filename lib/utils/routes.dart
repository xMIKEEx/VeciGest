import 'package:flutter/material.dart';
import 'package:vecigest/utils/constants.dart';
import 'package:vecigest/presentation/auth/splash_page.dart';
import 'package:vecigest/presentation/auth/login_page.dart';
import 'package:vecigest/presentation/auth/register_page.dart';
import 'package:vecigest/presentation/home/home_page.dart';
import 'package:vecigest/presentation/chat/chat_page.dart'; // For individual chat messages
import 'package:vecigest/presentation/incidents/incident_list_page.dart';
import 'package:vecigest/presentation/documents/doc_list_page.dart';
import 'package:vecigest/presentation/polls/poll_list_page.dart';
import 'package:vecigest/presentation/auth/create_community_page.dart';
import 'package:vecigest/presentation/auth/invite_register_page.dart';
import 'package:vecigest/presentation/auth/admin_no_community_page.dart';

// Added imports for new pages (assuming these files and classes exist)
import 'package:vecigest/presentation/polls/poll_detail_page.dart';
import 'package:vecigest/presentation/polls/new_poll_page.dart'; // Assumed
import 'package:vecigest/presentation/polls/poll_results_page.dart'; // Assumed
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart'; // Assumed
import 'package:vecigest/presentation/documents/upload_doc_page.dart';
import 'package:vecigest/presentation/documents/document_detail_page.dart'; // Assumed
import 'package:vecigest/presentation/chat/new_thread_page.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart'; // Assumed
import 'package:vecigest/presentation/properties/property_list_page.dart';
import 'package:vecigest/presentation/properties/property_detail_page.dart';
import 'package:vecigest/presentation/properties/invitations_list_page.dart';

// Import models for argument casting
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/domain/models/document_model.dart';
import 'package:vecigest/domain/models/thread_model.dart';

class AppRoutes {
  static const String splash = splashRoute;
  static const String login = loginRoute;
  static const String register = '/register';
  static const String home = '/home';
  // static const String chat = '/chat'; // Original chat route, might be for individual chats now
  static const String threadList =
      '/thread-list'; // Route for the list of chat threads
  static const String chatMessages =
      '/chat-messages'; // Route for messages within a thread

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
  static const String pollResults = '/poll-results';
  static const String incidentDetail = '/incident-detail';
  static const String newIncident = '/new-incident';
  static const String uploadDocument = '/upload-document';
  static const String documentDetail = '/document-detail';
  static const String newThread = '/new-thread';

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
      // case chat: // Original chat route handler
      //   // This might need adjustment based on how ChatPage is used.
      //   // If it expects a ThreadModel, it should be handled like chatMessages.
      //   // For now, assuming it might be a general chat entry or needs specific args.
      //   // If ChatPage is always entered with a ThreadModel, this case might be redundant
      //   // or needs to handle settings.arguments as ThreadModel.
      //   // If it's for individual chats, it should be like chatMessages.
      //   // Let's make it point to ChatPage expecting a ThreadModel argument
      //   final args = settings.arguments;
      //   if (args is ThreadModel) {
      //     return MaterialPageRoute(builder: (_) => ChatPage(thread: args));
      //   }
      //   return _errorRoute(settings.name); // Fallback if args are not ThreadModel
      case chatMessages: // Renamed from 'chat' to be more specific if '/chat' is general
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
        return MaterialPageRoute(builder: (_) => const PollListPage());
      case reservations:
        return MaterialPageRoute(builder: (_) => const ReservationListPage());
      case createCommunity:
        return MaterialPageRoute(builder: (_) => const CreateCommunityPage());
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

      // Added cases for new routes
      case pollDetail:
        final args = settings.arguments;
        if (args is PollModel) {
          return MaterialPageRoute(builder: (_) => PollDetailPage(poll: args));
        }
        return _errorRoute(settings.name, "Expected PollModel argument");
      case newPoll:
        return MaterialPageRoute(
          builder: (_) => const NewPollPage(),
        ); // Assumed NewPollPage
      case pollResults:
        final args = settings.arguments;
        if (args is PollModel) {
          return MaterialPageRoute(
            builder: (_) => PollResultsPage(poll: args),
          ); // Assumed PollResultsPage
        }
        return _errorRoute(settings.name, "Expected PollModel argument");
      case incidentDetail:
        final args = settings.arguments;
        if (args is IncidentModel) {
          return MaterialPageRoute(
            builder: (_) => IncidentDetailPage(incident: args),
          ); // Assumed IncidentDetailPage
        }
        return _errorRoute(settings.name, "Expected IncidentModel argument");
      case newIncident:
        return MaterialPageRoute(builder: (_) => const NewIncidentPage());
      case uploadDocument:
        return MaterialPageRoute(builder: (_) => const UploadDocPage());
      case documentDetail:
        final args = settings.arguments;
        if (args is DocumentModel) {
          return MaterialPageRoute(
            builder: (_) => DocumentDetailPage(document: args),
          ); // Assumed DocumentDetailPage
        }
        return _errorRoute(settings.name, "Expected DocumentModel argument");
      case newThread:
        return MaterialPageRoute(builder: (_) => const NewThreadPage());
      case properties:
        return MaterialPageRoute(builder: (_) => const PropertyListPage());
      case propertyDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => const PropertyDetailPage(),
          settings: RouteSettings(arguments: args),
        );
      case invitations:
        return MaterialPageRoute(builder: (_) => const InvitationsListPage());
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? name, [String message = ""]) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text('No route defined for $name. $message')),
          ),
    );
  }
}
