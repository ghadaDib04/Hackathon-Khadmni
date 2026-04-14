import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';

// Hardcoded seed data — replace with API: GET /tasks/feed (filtered by user)
final List<TaskModel> _myPostedTasks = [
  const TaskModel(
    id: '1',
    title: 'Impression 50 pages + reliure thèse',
    posterName: 'Sara B.',
    university: 'Constantine 2',
    price: 12.000,
    rating: 4.8,
    type: TaskType.physical,
    status: TaskStatus.pending,
    category: 'Services à domicile',
  ),
  const TaskModel(
    id: '2',
    title: 'Correction rapport Figma en anglais',
    posterName: 'Sara B.',
    university: 'Constantine 2',
    price: 25.000,
    rating: 4.8,
    type: TaskType.digital,
    status: TaskStatus.open,
    category: 'Traduction',
  ),
  const TaskModel(
    id: '3',
    title: 'Course cantine — menu du midi',
    posterName: 'Sara B.',
    university: 'Constantine 2',
    price: 5.500,
    rating: 4.8,
    type: TaskType.physical,
    status: TaskStatus.completed,
    category: 'Courses / Livraison',
  ),
];

final List<TaskModel> _myTakenJobs = [
  const TaskModel(
    id: '4',
    title: 'Design logo pour club informatique',
    posterName: 'Fatma K.',
    university: 'Constantine 2',
    price: 40.000,
    rating: 4.6,
    type: TaskType.digital,
    status: TaskStatus.pending,
    category: 'Design',
  ),
  const TaskModel(
    id: '5',
    title: 'Traduction résumé article IEEE',
    posterName: 'Hadil M.',
    university: 'Constantine 2',
    price: 15.000,
    rating: 5.0,
    type: TaskType.digital,
    status: TaskStatus.disputed,
    category: 'Traduction',
  ),
];

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Missions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Postées par moi'),
              Tab(text: 'Jobs pris'),
            ],
          ),
        ),
        body: const TabBarView(children: [_PostedTab(), _TakenTab()]),
      ),
    );
  }
}

// ─── Tab 1 : Postées par moi ──────────────────────────────────────────────────
class _PostedTab extends StatelessWidget {
  const _PostedTab();

  @override
  Widget build(BuildContext context) {
    if (_myPostedTasks.isEmpty) {
      return const EmptyState(
        title: 'Aucune mission postée',
        subtitle:
            'Publiez votre première mission et trouvez de l\'aide rapidement.',
        icon: Icons.add_task_rounded,
        actionLabel: 'Publier une mission',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myPostedTasks.length,
      itemBuilder: (_, i) {
        final task = _myPostedTasks[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskCard(task: task, showStatus: true),
            // Contextual action button based on status
            if (task.status == TaskStatus.pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActionButton(task: task, isPosted: true),
              ),
          ],
        );
      },
    );
  }
}

// ─── Tab 2 : Jobs pris ────────────────────────────────────────────────────────
class _TakenTab extends StatelessWidget {
  const _TakenTab();

  @override
  Widget build(BuildContext context) {
    if (_myTakenJobs.isEmpty) {
      return const EmptyState(
        title: 'Vous n\'avez pris aucun job',
        subtitle: 'Parcourez le feed et proposez vos services à la communauté.',
        icon: Icons.work_outline_rounded,
        actionLabel: 'Explorer le feed',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myTakenJobs.length,
      itemBuilder: (_, i) {
        final task = _myTakenJobs[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskCard(task: task, showStatus: true),
            if (task.status == TaskStatus.pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActionButton(task: task, isPosted: false),
              ),
          ],
        );
      },
    );
  }
}

// ─── Contextual Action Button ─────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final TaskModel task;
  final bool isPosted;
  const _ActionButton({required this.task, required this.isPosted});

  @override
  Widget build(BuildContext context) {
    final isPhysical = task.type == TaskType.physical;

    // Poster sees the PIN, provider uploads proof
    final String label = isPosted
        ? (isPhysical ? 'Voir le code PIN' : 'Confirmer la livraison')
        : (isPhysical ? 'Entrer le code PIN' : 'Uploader la preuve');

    final Color color = isPhysical ? AppColors.rustRed : AppColors.retroTeal;
    final IconData icon = isPosted
        ? (isPhysical ? Icons.pin_rounded : Icons.check_circle_outline_rounded)
        : (isPhysical ? Icons.dialpad_rounded : Icons.upload_file_rounded);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: () => _handleAction(context, task, isPosted),
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext ctx, TaskModel task, bool isPosted) {
    final isPhysical = task.type == TaskType.physical;

    if (isPhysical) {
      _showPinDialog(ctx, task, isPosted);
    } else {
      // TODO: navigate to upload screen or open file picker
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Upload de preuve — à connecter au backend'),
        ),
      );
    }
  }

  void _showPinDialog(BuildContext ctx, TaskModel task, bool isPosted) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PinBottomSheet(task: task, isPoster: isPosted),
    );
  }
}

// ─── PIN Bottom Sheet ─────────────────────────────────────────────────────────
class _PinBottomSheet extends StatefulWidget {
  final TaskModel task;
  final bool isPoster;
  const _PinBottomSheet({required this.task, required this.isPoster});

  @override
  State<_PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<_PinBottomSheet> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  // Hardcoded PIN for demo — replace with: GET /tasks/{id}
  static const String _mockPin = '4827';

  @override
  void dispose() {
    for (final c in _pinControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (widget.isPoster) ...[
            // ── Poster sees the PIN ────────────────────────────────────
            const Icon(Icons.pin_rounded, size: 40, color: AppColors.rustRed),
            const SizedBox(height: 12),
            const Text(
              'Votre code PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Communiquez ce code au prestataire lors de la remise',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _PinDisplay(pin: _mockPin),
          ] else ...[
            // ── Provider enters the PIN ────────────────────────────────
            const Icon(
              Icons.dialpad_rounded,
              size: 40,
              color: AppColors.rustRed,
            ),
            const SizedBox(height: 12),
            const Text(
              'Entrer le code PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Demandez le code PIN au client pour valider la livraison',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            _PinInput(controllers: _pinControllers, focusNodes: _focusNodes),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rustRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Valider la livraison',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _verifyPin() {
    final entered = _pinControllers.map((c) => c.text).join();
    // TODO: POST $BASE_URL/tasks/{id}/verify-pin
    if (entered == _mockPin) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Livraison validée ! Paiement libéré.'),
          backgroundColor: AppColors.retroTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code PIN incorrect. Réessayez.'),
          backgroundColor: AppColors.rustRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

// ─── PIN Display (poster sees) ────────────────────────────────────────────────
class _PinDisplay extends StatelessWidget {
  final String pin;
  const _PinDisplay({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.rustRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.rustRed, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            pin[i],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.rustRed,
            ),
          ),
        );
      }),
    );
  }
}

// ─── PIN Input (provider enters) ─────────────────────────────────────────────
class _PinInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const _PinInput({required this.controllers, required this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.burntOrange,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.borderLight,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.burntOrange,
                  width: 2,
                ),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 3) {
                focusNodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
