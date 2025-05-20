import 'package:flutter/material.dart';
import 'package:vecigest/utils/constants.dart';
import 'package:vecigest/presentation/auth/splash_page.dart';
import 'package:vecigest/presentation/home/home_page.dart';
import 'package:vecigest/presentation/chat/chat_page.dart';
import 'package:vecigest/presentation/incidents/incident_list_page.dart';
import 'package:vecigest/presentation/documents/doc_list_page.dart';
import 'package:vecigest/presentation/polls/poll_list_page.dart';
import 'package:vecigest/presentation/polls/poll_detail_page.dart';
import 'package:vecigest/presentation/polls/new_poll_page.dart';
import 'package:vecigest/presentation/polls/poll_results_page.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart';
import 'package:vecigest/presentation/documents/upload_doc_page.dart';
import 'package:vecigest/presentation/documents/document_detail_page.dart';
import 'package:vecigest/presentation/chat/new_thread_page.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart';
import 'package:vecigest/presentation/auth/welcome_page.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/incident_model.dart';
import 'package:vecigest/domain/models/document_model.dart';
import 'package:vecigest/domain/models/thread_model.dart';
import 'package:vecigest/presentation/auth/login_admin_page.dart';
import 'package:vecigest/presentation/auth/login_user_page.dart';
import 'package:vecigest/presentation/auth/register_admin_page.dart';
import 'package:vecigest/presentation/auth/register_user_page.dart';
import 'package:vecigest/presentation/auth/complete_admin_data_page.dart';
import 'package:vecigest/presentation/auth/complete_user_data_page.dart';
import 'package:vecigest/presentation/empresa/create_community_page.dart';
import 'package:vecigest/presentation/admin/manage_units_page.dart';
import 'package:vecigest/presentation/admin/invite_resident_page.dart';
import 'package:vecigest/presentation/resident/register_from_invite_page.dart';
import 'package:vecigest/presentation/auth/register_neighbor_page.dart';

class AppRoutes {
  static const String splash = splashRoute;
  static const String home = '/home';
  static const String welcome = '/welcome';
  static const String loginAdmin = '/login-admin';
  static const String loginUser = '/login-user';
  static const String registerAdmin = '/register-admin';
  static const String registerUser = '/register-user';
  static const String completeAdminData = '/complete-admin-data';
  static const String completeUserData = '/complete-user-data';
  static const String registerNeighbor = '/register-neighbor';
  // static const String userRegister = '/user-register';
  // static const String adminRegisterForm = '/admin-register-form';
  // static const String chat = '/chat'; // Original chat route, might be for individual chats now
  static const String threadList =
      '/thread-list'; // Route for the list of chat threads
  static const String chatMessages =
      '/chat-messages'; // Route for messages within a thread

  static const String incidents = '/incidents';
  static const String documents = '/documents';
  static const String polls = '/polls';
  static const String reservations = '/reservations';
  static const String createCommunity = '/create-community';
  static const String manageUnits = '/manage-units';
  static const String inviteResident = '/invite-resident';
  static const String registerFromInvite = '/register-from-invite';
  static const String passwordReset = '/password-reset';

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
      case loginAdmin:
        return MaterialPageRoute(builder: (_) => const LoginAdminPage());
      case loginUser:
        return MaterialPageRoute(builder: (_) => const LoginUserPage());
      case registerAdmin:
        return MaterialPageRoute(builder: (_) => const RegisterAdminPage());
      case registerUser:
        return MaterialPageRoute(builder: (_) => const RegisterUserPage());
      case completeAdminData:
        return MaterialPageRoute(builder: (_) => const CompleteAdminDataPage());
      case completeUserData:
        return MaterialPageRoute(builder: (_) => const CompleteUserDataPage());
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
      case createCommunity:
        return MaterialPageRoute(builder: (_) => const CreateCommunityPage());
      case manageUnits:
        return MaterialPageRoute(builder: (_) => const ManageUnitsPage());
      case inviteResident:
        return MaterialPageRoute(builder: (_) => const InviteResidentPage());
      case registerFromInvite:
        final args = settings.arguments as Map<String, String>?;
        if (args != null &&
            args['communityId'] != null &&
            args['unitId'] != null &&
            args['token'] != null) {
          return MaterialPageRoute(
            builder:
                (_) => RegisterFromInvitePage(
                  communityId: args['communityId']!,
                  unitId: args['unitId']!,
                  token: args['token']!,
                ),
          );
        }
        return _errorRoute(settings.name, 'Faltan datos de invitación');

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
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      // Eliminar rutas obsoletas y duplicadas
      // case adminAuth:
      //   return MaterialPageRoute(builder: (_) => const AdminAuthPage());
      // case userAuth:
      //   return MaterialPageRoute(builder: (_) => const UserAuthPage());
      // case adminKey:
      //   return MaterialPageRoute(builder: (_) => const AdminKeyPage());
      // case adminRegisterForm:
      //   final args = settings.arguments as Map<String, String>?;
      //   return MaterialPageRoute(
      //     builder:
      //         (_) => AdminRegisterFormPage(
      //           email: args?['email'] ?? '',
      //           password: args?['password'] ?? '',
      //         ),
      //   );
      // case userRegister:
      //   return MaterialPageRoute(builder: (_) => const UserRegisterPage());
      case 'admin-login':
        return _errorRoute(settings.name, "Ruta obsoleta");
      case 'user-login':
        return _errorRoute(settings.name, "Ruta obsoleta");
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
