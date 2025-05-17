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
      //   // return MaterialPageRoute(builder: (_) => const ChatPage(thread: /* provide thread model */));
      //   // For now, let's assume the direct ChatPage navigation is handled by chatMessages
      //   // and the main "Chat" tab goes to ThreadListPage (handled in HomePage).
      //   // So, this specific '/chat' route might be unused or for a different purpose.
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
