import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum TaskType { physical, digital }

enum TaskStatus { open, pending, completed, disputed }

class TaskModel {
  final String id;
  final String title;
  final String posterName;
  final String university;
  final double price;
  final double rating;
  final TaskType type;
  final TaskStatus status;
  final String category;
  final String? timeAgo;
  final String? location;

  const TaskModel({
    required this.id,
    required this.title,
    required this.posterName,
    required this.university,
    required this.price,
    required this.rating,
    required this.type,
    required this.status,
    required this.category,
    this.timeAgo,
    this.location,
  });
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final bool showStatus;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showStatus = false,
  });

  Color get _borderColor =>
      task.type == TaskType.physical ? AppColors.rustRed : AppColors.retroTeal;

  Color get _badgeColor =>
      task.type == TaskType.physical ? AppColors.rustRed : AppColors.retroTeal;

  String get _typeLabel =>
      task.type == TaskType.physical ? 'PHYSIQUE' : 'DIGITAL';

  String get _statusLabel {
    switch (task.status) {
      case TaskStatus.open:
        return 'OUVERT';
      case TaskStatus.pending:
        return 'EN COURS';
      case TaskStatus.completed:
        return 'TERMINÉ';
      case TaskStatus.disputed:
        return 'LITIGE';
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case TaskStatus.open:
        return AppColors.retroTeal;
      case TaskStatus.pending:
        return AppColors.goldenYellow;
      case TaskStatus.completed:
        return AppColors.burntOrange;
      case TaskStatus.disputed:
        return AppColors.rustRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D2420).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ligne du haut
                        Row(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _badgeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _typeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _badgeColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Badge de statut si showStatus est true
                            if (showStatus) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Prix
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldenYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${task.price.toStringAsFixed(0)}DT',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Titre
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Avatar et nom
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.burntOrange,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=${task.id.hashCode % 10}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.posterName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    task.timeAgo ?? 'Posté récemment',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Bas
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.location ?? '${task.university}, Tunis',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Voir Détails',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
