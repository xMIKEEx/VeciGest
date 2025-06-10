import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecigest/presentation/chat/thread_list_page.dart';
import 'package:vecigest/presentation/incidents/incident_list_page.dart';
import 'package:vecigest/presentation/incidents/new_incident_page.dart';
import 'package:vecigest/presentation/incidents/incident_detail_page.dart';
import 'package:vecigest/presentation/polls/modern_poll_page.dart';
import 'package:vecigest/presentation/reservations/reservation_list_page.dart';
import 'package:vecigest/presentation/events/new_event_page.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/data/services/incident_service.dart';
import 'package:vecigest/data/services/chat_service.dart';

// Import new modular components
import 'widgets/card_wrapper.dart';
import 'widgets/context_info_card.dart';
import 'widgets/upcoming_events_card.dart';
import 'widgets/notifications_card.dart';
import 'widgets/settings_bottom_sheet.dart';
import 'widgets/navigation_badge.dart';
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

            // Upcoming Events Section (Only for Admins)
            if (_isAdmin)
              CardWrapper(
                child: UpcomingEventsCard(
                  isAdmin: _isAdmin,
                  onAddEvent:
                      () => _pushToCurrentTab(
                        NewEventPage(onClose: _popFromCurrentTab),
                      ),
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
    }

    // Default tab content
    switch (_currentIndex) {
      case 0:
        return IncidentListPage(onNavigate: _pushToCurrentTab);
      case 1:
        return ReservationListPage(
          onNavigate: _pushToCurrentTab,
          onPop: _popFromCurrentTab,
        );
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
    if (!hasSubPages) return false;

    final topPage = _navigationManager.getTopPageForTab(_currentIndex);
    if (topPage == null) return false;

    // Check if the current page is one that has its own SliverAppBar
    return topPage is NewIncidentPage || topPage is IncidentDetailPage;
  }

  @override
  Widget build(BuildContext context) {
    final hasSubPages = _navigationManager.hasSubPages(_currentIndex);
    final shouldHideAppBar = _shouldHideAppBar();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
        appBar:
            shouldHideAppBar
                ? null
                : AppBar(
                  title: const Text(
                    'VeciGest',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  automaticallyImplyLeading: hasSubPages,
                  leading:
                      hasSubPages
                          ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _popFromCurrentTab,
                          )
                          : null,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _openSettings,
                      tooltip: 'Ajustes',
                    ),
                  ],
                ),
        body: FadeTransition(opacity: _fadeAnimation, child: _buildBody()),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
            items: [
              BottomNavigationBarItem(
                icon: NavigationBadge(
                  iconData: Icons.report_problem,
                  stream: _incidentService.getIncidents(),
                  countExtractor:
                      (incidents) =>
                          incidents.where((i) => i.status == 'open').length,
                  badgeColor: Colors.red,
                ),
                label: 'Incidencias',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.event_available),
                label: 'Reservas',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: NavigationBadge(
                  iconData: Icons.chat_bubble,
                  stream: _chatService.getThreads(),
                  countExtractor: (threads) => threads.length,
                  badgeColor: Colors.blue,
                ),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.poll),
                label: 'Encuestas',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
