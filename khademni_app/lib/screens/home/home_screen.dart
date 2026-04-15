import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../task/task_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'All';

  static const Color _bg = Color(0xFFBE5103);

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ApiService.get('/tasks/feed');
      final list = (response.data as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _tasks = list
            .map((t) => Task.fromJson(t as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tasks. Check your connection.';
        _loading = false;
      });
    }
    final response = await ApiService.get('/tasks/feed');
    print('FEED RESPONSE: ${response.data}');
    final list = (response.data as List?) ?? [];
    print('LIST LENGTH: ${list.length}');
  }

  List<Task> get _filtered {
    if (_selectedFilter == 'All')      return _tasks;
    if (_selectedFilter == 'Physical') return _tasks.where((t) => t.taskType == 'physical').toList();
    if (_selectedFilter == 'Digital')  return _tasks.where((t) => t.taskType == 'digital').toList();
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Lit le user depuis AuthProvider — mis à jour par fetchMe() après login
    final user      = context.watch<AuthProvider>().user;
    final name      = (user?['name'] as String?) ?? '';
    final firstName = name.isNotEmpty ? name.split(' ').first : 'there';
    final initial   = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ Pas de bottomNavigationBar — MainShell s'en occupe
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'KHADMNI',
          style: TextStyle(
            color: Color(0xFFBE5103),
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            // ✅ Clic sur avatar → ProfileScreen (pas de PopupMenu)
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: _Avatar(initial: initial),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _bg,
        onRefresh: _loadFeed,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find your next\ngig or task.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFBE5103),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Physical', 'Digital'].map((f) {
                          final isSelected = _selectedFilter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? _bg : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? _bg : AppColors.borderLight,
                                  ),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFBE5103)),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadFeed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('Retry',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text('No tasks available',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('Be the first to post one!',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(
                          task: _filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TaskDetailScreen(taskId: _filtered[i].id),
                            ),
                          ),
                        ),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ── AVATAR ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFFBE5103);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFCE1B), width: 2),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ── TASK CARD ──────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  const _TaskCard({required this.task, required this.onTap});

  static const Color _teal = Color(0xFF069494);
  static const Color _bg   = Color(0xFFBE5103);

  Color get _categoryColor {
    switch (task.category.toLowerCase()) {
      case 'design':   return const Color(0xFFEDE7FF);
      case 'dev':      return const Color(0xFFE3F2FD);
      case 'tutoring': return const Color(0xFFE8F5E9);
      case 'errand':   return const Color(0xFFFFF3E0);
      default:         return const Color(0xFFF5F5F5);
    }
  }

  Color get _categoryTextColor {
    switch (task.category.toLowerCase()) {
      case 'design':   return const Color(0xFF7C4DFF);
      case 'dev':      return const Color(0xFF1565C0);
      case 'tutoring': return const Color(0xFF2E7D32);
      case 'errand':   return const Color(0xFFE65100);
      default:         return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhysical = task.taskType == 'physical';
    final price = task.aiPrice ?? task.suggestedPrice ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(task.category,
                      style: TextStyle(
                          color: _categoryTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPhysical
                        ? const Color(0xFFFFF8E1)
                        : const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPhysical
                            ? Icons.directions_walk_rounded
                            : Icons.computer_rounded,
                        size: 11,
                        color: isPhysical ? const Color(0xFFF57F17) : _teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPhysical ? 'Physical' : 'Digital',
                        style: TextStyle(
                          color: isPhysical
                              ? const Color(0xFFF57F17)
                              : _teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(task.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.3)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Price',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500)),
                    Text('${price.toStringAsFixed(0)} DA',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF069494))),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: _bg.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}