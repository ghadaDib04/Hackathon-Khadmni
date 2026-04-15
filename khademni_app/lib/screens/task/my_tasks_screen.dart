import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/api_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  List<dynamic> _postedTasks = [];
  List<dynamic> _workingTasks = [];
  bool _loadingPosted = true;
  bool _loadingWorking = true;

  @override
  void initState() {
    super.initState();
    _loadPosted();
    _loadWorking();
  }

  Future<void> _loadPosted() async {
    setState(() => _loadingPosted = true);
    try {
      final response = await ApiService.get('/tasks/my/posted');
      setState(() => _postedTasks = response.data as List);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posted tasks: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingPosted = false);
    }
  }

  Future<void> _loadWorking() async {
    setState(() => _loadingWorking = true);
    try {
      final response = await ApiService.get('/tasks/my/working');
      setState(() => _workingTasks = response.data as List);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading working tasks: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingWorking = false);
    }
  }

  // POST /tasks/{id}/deliver
  Future<void> _deliverTask(int taskId) async {
    try {
      await ApiService.post('/tasks/$taskId/deliver');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task marked as delivered!'), backgroundColor: Colors.green),
      );
      _loadWorking();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rustRed),
      );
    }
  }

  // POST /tasks/{id}/confirm?pin=YOURPIN
  Future<void> _confirmWithPin(int taskId) async {
    final pinController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dialpad_rounded, size: 40, color: AppColors.rustRed),
            const SizedBox(height: 12),
            const Text('Enter PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Ask the poster for the PIN to confirm delivery', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            TextField(
              controller: pinController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: 'A3F9C1',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final response = await ApiService.post('/tasks/$taskId/confirm?pin=${pinController.text.trim().toUpperCase()}');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment released! You received ${response.data['amount_received']} DZD'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadWorking();
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wrong PIN: $e'), backgroundColor: AppColors.rustRed),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rustRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm Delivery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show PIN to poster
  void _showPin(String pin) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pin_rounded, size: 40, color: AppColors.rustRed),
            const SizedBox(height: 12),
            const Text('Your PIN Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Give this PIN to the worker only when satisfied', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text(pin, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 8, color: AppColors.rustRed)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // POST /tasks/{id}/dispute
  Future<void> _openDispute(int taskId) async {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
            const SizedBox(height: 12),
            const Text('Open Dispute', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Explain the issue...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ApiService.post('/tasks/$taskId/dispute?reason=${Uri.encodeComponent(reasonController.text)}');
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispute opened. Escrow frozen.'), backgroundColor: Colors.orange),
                    );
                    _loadPosted();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rustRed),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Dispute', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POST /tasks/{id}/rate
  Future<void> _rateTask(int taskId) async {
    int selectedScore = 5;
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 40, color: Colors.amber),
              const SizedBox(height: 12),
              const Text('Rate this task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setModalState(() => selectedScore = i + 1),
                  child: Icon(
                    i < selectedScore ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: Colors.amber,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ApiService.post('/tasks/$taskId/rate', data: {
                        'score': selectedScore,
                        'comment': commentController.text,
                      });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating submitted!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rustRed),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Missions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Posted by me'),
              Tab(text: 'My work'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1 — Posted tasks
            _loadingPosted
                ? const Center(child: CircularProgressIndicator())
                : _postedTasks.isEmpty
                ? const EmptyState(
              title: 'No posted missions',
              subtitle: 'Post your first mission and find help quickly.',
              icon: Icons.add_task_rounded,
              actionLabel: 'Post a mission',
            )
                : RefreshIndicator(
              onRefresh: _loadPosted,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _postedTasks.length,
                itemBuilder: (_, i) {
                  final task = _postedTasks[i];
                  return _PostedTaskItem(
                    task: task,
                    onShowPin: () => _showPin(task['pin'] ?? ''),
                    onDispute: () => _openDispute(task['id']),
                    onRate: () => _rateTask(task['id']),
                  );
                },
              ),
            ),

            // Tab 2 — Working tasks
            _loadingWorking
                ? const Center(child: CircularProgressIndicator())
                : _workingTasks.isEmpty
                ? const EmptyState(
              title: 'No active work',
              subtitle: 'Browse the feed and offer your services.',
              icon: Icons.work_outline_rounded,
              actionLabel: 'Explore feed',
            )
                : RefreshIndicator(
              onRefresh: _loadWorking,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _workingTasks.length,
                itemBuilder: (_, i) {
                  final task = _workingTasks[i];
                  return _WorkingTaskItem(
                    task: task,
                    onDeliver: () => _deliverTask(task['id']),
                    onConfirmPin: () => _confirmWithPin(task['id']),
                    onRate: () => _rateTask(task['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Posted task item widget
class _PostedTaskItem extends StatelessWidget {
  final dynamic task;
  final VoidCallback onShowPin;
  final VoidCallback onDispute;
  final VoidCallback onRate;

  const _PostedTaskItem({required this.task, required this.onShowPin, required this.onDispute, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final status = task['status'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('${task['bid_count'] ?? 0} bids · ${task['escrow_amount'] ?? 0} DZD in escrow',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            if (status == 'in_progress') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShowPin,
                      icon: const Icon(Icons.pin_rounded, size: 16),
                      label: const Text('Show PIN'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.rustRed, side: const BorderSide(color: AppColors.rustRed)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDispute,
                      icon: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: const Text('Dispute'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                    ),
                  ),
                ],
              ),
            ],
            if (status == 'delivered') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRate,
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text('Rate'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDispute,
                      icon: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: const Text('Dispute'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Working task item widget
class _WorkingTaskItem extends StatelessWidget {
  final dynamic task;
  final VoidCallback onDeliver;
  final VoidCallback onConfirmPin;
  final VoidCallback onRate;

  const _WorkingTaskItem({required this.task, required this.onDeliver, required this.onConfirmPin, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final status = task['status'] ?? '';
    final poster = task['poster'] ?? {};
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Posted by ${poster['name'] ?? 'Unknown'} · Trust: ${poster['trust_score'] ?? 100}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('Agreed: ${task['agreed_amount'] ?? 0} DZD',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (status == 'in_progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDeliver,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Mark as Delivered'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.retroTeal),
                ),
              ),
            if (status == 'delivered') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirmPin,
                      icon: const Icon(Icons.dialpad_rounded, size: 16),
                      label: const Text('Enter PIN'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rustRed),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRate,
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: const Text('Rate'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Status badge
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get color {
    switch (status) {
      case 'open': return Colors.green;
      case 'in_progress': return Colors.blue;
      case 'delivered': return Colors.orange;
      case 'completed': return Colors.teal;
      case 'disputed': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}