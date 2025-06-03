import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/poll_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:vecigest/domain/models/poll_model.dart';
import 'package:vecigest/domain/models/poll_option_model.dart';
import 'package:vecigest/utils/routes.dart';
import 'package:vecigest/presentation/polls/widgets/poll_card.dart';
import 'package:vecigest/presentation/polls/widgets/poll_states.dart';
import 'package:vecigest/presentation/polls/widgets/voting_modal.dart';
import 'package:vecigest/presentation/polls/business_logic/poll_business_logic.dart';

class ModernPollPage extends StatefulWidget {
  const ModernPollPage({super.key});

  @override
  State<ModernPollPage> createState() => _ModernPollPageState();
}

class _ModernPollPageState extends State<ModernPollPage>
    with TickerProviderStateMixin {
  final PollService _pollService = PollService();
  final UserRoleService _userRoleService = UserRoleService();
  final PollBusinessLogic _pollBusinessLogic = PollBusinessLogic();

  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _fabAnimationController.forward();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRole = await _userRoleService.getUserRoleAndCommunity(user.uid);
      setState(() {
        _isAdmin = userRole?['role'] == 'admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [_buildSliverAppBar(theme)],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPollList('all'),
            _buildPollList('unvoted'),
            _buildPollList('voted'),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Encuestas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: -20,
                child: Icon(
                  Icons.poll,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participa en las decisiones',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'de tu comunidad',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.primary,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Todas'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Votadas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(ThemeData theme) {
    if (!_isAdmin) return null;

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _createNewPoll,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Nueva Encuesta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }

  Widget _buildPollList(String filter) {
    return StreamBuilder<List<PollModel>>(
      stream: _pollService.getPolls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PollStates.buildLoadingState();
        }

        if (snapshot.hasError) {
          return PollStates.buildErrorState(context);
        }

        final allPolls = snapshot.data ?? [];

        return FutureBuilder<List<PollModel>>(
          future: _pollBusinessLogic.filterPolls(allPolls, filter),
          builder: (context, filteredSnapshot) {
            if (filteredSnapshot.connectionState == ConnectionState.waiting) {
              return PollStates.buildLoadingState();
            }

            final polls = filteredSnapshot.data ?? [];

            if (polls.isEmpty) {
              return PollStates.buildEmptyState(
                context,
                filter,
                _isAdmin,
                _createNewPoll,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: polls.length,
                itemBuilder:
                    (context, index) =>
                        _buildPollCardWrapper(polls[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPollCardWrapper(PollModel poll, int index) {
    return StreamBuilder<List<PollOptionModel>>(
      stream: _pollService.getOptions(poll.id),
      builder: (context, optionsSnapshot) {
        final options = optionsSnapshot.data ?? [];
        final totalVotes = options.fold<int>(
          0,
          (sum, option) => sum + option.votes,
        );

        return FutureBuilder<bool>(
          future: _pollBusinessLogic.hasUserVoted(poll.id),
          builder: (context, votedSnapshot) {
            final hasVoted = votedSnapshot.data ?? false;
            return PollCard(
              poll: poll,
              index: index,
              options: options,
              hasVoted: hasVoted,
              totalVotes: totalVotes,
              onCardTap: () {}, // No hacer nada al hacer clic en la carta
              onVoteButtonTap: () => _openVotingModal(poll),
            );
          },
        );
      },
    );
  }

  void _openVotingModal(PollModel poll) {
    _showVotingModalWithOptions(poll);
  }

  Future<void> _showVotingModalWithOptions(PollModel poll) async {
    // Obtener las opciones más recientes del servicio
    final optionsStream = _pollService.getOptions(poll.id);
    final options = await optionsStream.first;

    // Crear un poll temporal con las opciones actualizadas
    final pollWithOptions = PollModel(
      id: poll.id,
      question: poll.question,
      createdBy: poll.createdBy,
      createdAt: poll.createdAt,
      options: options,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              VotingModal(poll: pollWithOptions, onVote: _voteForOption),
    );
  }

  void _createNewPoll() {
    Navigator.pushNamed(context, AppRoutes.newPoll).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  Future<void> _voteForOption(PollModel poll, PollOptionModel option) async {
    try {
      Navigator.pop(context);

      final confirmed = await _showConfirmationDialog(option.text);

      if (confirmed == true) {
        _showLoadingSnackBar();
        await _pollBusinessLogic.voteForOption(poll.id, option.id);
        setState(() {});
        _showSuccessSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<bool?> _showConfirmationDialog(String optionText) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar voto'),
            content: Text(
              '¿Estás seguro de que quieres votar por "$optionText"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Votar'),
              ),
            ],
          ),
    );
  }

  void _showLoadingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrando voto...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Voto registrado exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al votar: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
