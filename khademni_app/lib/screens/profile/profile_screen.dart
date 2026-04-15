import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().fetchMe();
      final user = context.read<AuthProvider>().user;
      setState(() { _profile = user; });
    } catch (e) {
      setState(() => _error = 'Failed to load profile.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name       = (user?['name'] as String?) ?? '';
    final email      = (user?['email'] as String?) ?? '';
    final university = (user?['university'] as String?) ?? '';
    final skills     = (user?['skills'] as String?) ?? '';
    final trust      = (user?['trust_score'] ?? 0).toDouble();
    final wallet     = (user?['wallet_balance'] ?? 0).toDouble();
    final stats      = user?['stats'] as Map<String, dynamic>? ?? {};
    final posted     = stats['tasks_posted'] ?? 0;
    final completed  = stats['tasks_completed'] ?? 0;
    final initial    = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final stars      = (trust / 20).clamp(0.0, 5.0); // trust 0-100 → stars 0-5

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBE5103)))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE5103),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'KHADMNI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.burntOrange,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card with avatar
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.burntOrange, AppColors.rustRed],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    Positioned(
                      left: 40,
                      bottom: -30,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBE5103),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // University
                      if (university.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                university,
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      // Trust score stars
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < stars.floor()) {
                              return const Icon(Icons.star_rounded, color: AppColors.goldenYellow, size: 18);
                            } else if (i < stars) {
                              return const Icon(Icons.star_half_rounded, color: AppColors.goldenYellow, size: 18);
                            } else {
                              return const Icon(Icons.star_outline_rounded, color: AppColors.goldenYellow, size: 18);
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            trust.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(' / 100', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          _buildStatCard('TASKS\nCOMPLETED', completed.toString(), AppColors.burntOrange),
                          const SizedBox(width: 12),
                          _buildStatCard('TASKS\nPOSTED', posted.toString(), AppColors.retroTeal),
                          const SizedBox(width: 12),
                          _buildStatCard('WALLET\n(DA)', wallet.toStringAsFixed(0), AppColors.goldenYellow),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Skills
                      if (skills.isNotEmpty) ...[
                        _buildSectionTitle('Skills'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: skills
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .map((s) => _buildSkillChip(s))
                              .toList(),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.burntOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.goldenYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}