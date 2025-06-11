import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecigest/presentation/chat/thread_list_page.dart';
import 'package:vecigest/presentation/chat/new_chat_group_page.dart';
import 'package:vecigest/presentation/chat/chat_page.dart';
import 'package:vecigest/presentation/incidents/incident_list_page.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart';
import 'package:vecigest/presentation/polls/modern_poll_page.dart';
import 'package:vecigest/presentation/polls/new_poll_page.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart';
import 'package:vecigest/presentation/events/new_event_page.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/data/services/chat_service.dart';

// Import modular components
import 'widgets/card_wrapper.dart';
import 'widgets/context_info_card.dart';
import 'widgets/upcoming_events_card.dart';
import 'widgets/notifications_card.dart';
import 'widgets/settings_bottom_sheet.dart';
import 'widgets/floating_top_bar.dart';
import 'widgets/floating_bottom_navigation.dart';
import 'managers/navigation_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Services
  final _userRoleService = UserRoleService();
  final _incidentService = IncidentService();
  final _chatService = ChatService();

  // Navigation manager
  final _navigationManager = NavigationManager();

  // User data
  Map<String, dynamic>? _userRole;
  bool _isAdmin = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await _userRoleService.getUserRoleAndCommunity(user.uid);
      if (mounted) {
        setState(() {
          _userRole = role;
          _isAdmin = role?['role'] == 'admin';
        });
      }
    }
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Context Information Section
            CardWrapper(
              child: ContextInfoCard(userRole: _userRole, isAdmin: _isAdmin),
            ),

            // Upcoming Events Section (Visible for all users)
            CardWrapper(
              child: UpcomingEventsCard(
                isAdmin: _isAdmin,
                onAddEvent:
                    _isAdmin
                        ? () => _pushToCurrentTab(
                          NewEventPage(onClose: _popFromCurrentTab),
                        )
                        : () {}, // Empty function for non-admin users
              ),
            ),

            // Notifications Section
            CardWrapper(
              child: NotificationsCard(
                onNavigateToTab:
                    (index) => setState(() => _currentIndex = index),
                onOpenSettings: _openSettings,
              ),
            ),

            const SizedBox(height: 80), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SettingsBottomSheet(isAdmin: _isAdmin),
    );
  }

  Widget _buildBody() {
    // Check if there are sub-pages in the current tab's navigation stack
    final currentStack = _navigationManager.getStackForTab(_currentIndex);

    if (currentStack.isNotEmpty) {
      return currentStack.last;
    } // Default tab content
    switch (_currentIndex) {
      case 0:
        return IncidentListPage(onNavigate: _pushToCurrentTab);
      case 1:
        return const ReservationListPage();
      case 2:
        return _buildHomePage();
      case 3:
        return ThreadListPage(onNavigate: _pushToCurrentTab);
      case 4:
        return const ModernPollPage();
      default:
        return _buildHomePage();
    }
  }

  // Navigation methods using NavigationManager
  void _pushToCurrentTab(Widget page) {
    print(
      'DEBUG: _pushToCurrentTab called with ${page.runtimeType} for tab $_currentIndex',
    );
    setState(() {
      _navigationManager.pushToTab(_currentIndex, page);
    });
  }

  bool _popFromCurrentTab() {
    final popped = _navigationManager.popFromTab(_currentIndex);
    if (popped) {
      setState(() {});
      return true;
    }
    return false;
  } // Helper method to check if current page has custom header

  bool _shouldHideAppBar() {
    final hasSubPages = _navigationManager.hasSubPages(_currentIndex);

    // Hide floating app bar for sub-pages that have their own AppBar
    if (hasSubPages) {
      final topPage = _navigationManager.getTopPageForTab(_currentIndex);
      if (topPage == null) {
        return false; // Check if the current page is one that has its own SliverAppBar or floating header
      }
      return topPage is NewIncidentPage ||
          topPage is IncidentDetailPage ||
          topPage is NewChatGroupPage ||
          topPage is ChatPage ||
          topPage is NewPollPage;
    }

    // Hide floating app bar for all tabs except Home (index 2)
    return _currentIndex != 2;
  }

  @override
  Widget build(BuildContext context) {
    final hasSubPages = _navigationManager.hasSubPages(_currentIndex);
    final shouldHideAppBar = _shouldHideAppBar();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (hasSubPages) {
            _popFromCurrentTab();
          } else {
            if (_currentIndex != 2) {
              setState(() {
                _currentIndex = 2;
              });
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            // Main content with conditional padding for floating bars
            Padding(
              padding: EdgeInsets.only(
                top: shouldHideAppBar ? 0 : 140,
                bottom: 85, // Always leave space for bottom navigation
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBody(),
              ),
            ),

            // Floating top bar - only visible in Home tab
            if (!shouldHideAppBar)
              FloatingTopBar(
                hasSubPages: hasSubPages,
                onBackPressed: _popFromCurrentTab,
                onSettingsPressed: _openSettings,
              ),

            // Floating bottom navigation - always visible
            FloatingBottomNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              incidentService: _incidentService,
              chatService: _chatService,
            ),
          ],
        ),
      ),
    );
  }
}
