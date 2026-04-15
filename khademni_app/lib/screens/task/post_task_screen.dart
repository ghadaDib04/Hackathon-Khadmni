import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/api_service.dart';
import '../main_shell.dart';

class PostTaskScreen extends StatefulWidget {
  const PostTaskScreen({super.key});

  @override
  State<PostTaskScreen> createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  bool isPhysical = true;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  String? selectedCategory;
  bool _loading = false;
  bool _loadingAiPrice = false;
  double? _aiPrice;

  static const List<String> categories = [
    'errand',
    'design',
    'dev',
    'tutoring',
    'other',
  ];

  static const Map<String, String> categoryLabels = {
    'errand': 'Errands / Delivery',
    'design': 'Design',
    'dev': 'Development',
    'tutoring': 'Tutoring',
    'other': 'Other',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _getAiPrice() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill title and description first')),
      );
      return;
    }
    setState(() => _loadingAiPrice = true);
    try {
      final response = await ApiService.post('/tasks/create', data: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': selectedCategory ?? 'other',
        'task_type': isPhysical ? 'physical' : 'digital',
        'suggested_price': double.tryParse(_budgetController.text) ?? 0,
      });
      final aiPrice = response.data['ai_price'];
      setState(() {
        _aiPrice = (aiPrice as num?)?.toDouble();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI suggested: ${_aiPrice?.toStringAsFixed(0)} DZD'),
            backgroundColor: AppColors.retroTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected: ${e.toString()}'),
            backgroundColor: AppColors.rustRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingAiPrice = false);
    }
  }

  Future<void> _submitTask() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await ApiService.post('/tasks/create', data: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': selectedCategory,
        'task_type': isPhysical ? 'physical' : 'digital',
        'suggested_price': double.tryParse(_budgetController.text) ?? 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task posted! AI price: ${response.data['ai_price']} DZD'),
            backgroundColor: AppColors.retroTeal,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.rustRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'POST TASK',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post your\nmission',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share your need with the community and find the ideal help.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            _buildLabel('TASK TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Ex: Document delivery, Logo design...',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the task in detail...',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('TASK TYPE'),
            const SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isPhysical = true),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPhysical
                              ? AppColors.burntOrange
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: isPhysical
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Physical',
                                style: TextStyle(
                                  color: isPhysical
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isPhysical = false),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: !isPhysical
                              ? AppColors.retroTeal
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.computer,
                                size: 16,
                                color: !isPhysical
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Digital',
                                style: TextStyle(
                                  color: !isPhysical
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (isPhysical)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'PIN code auto-generated on acceptance',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            _buildLabel('CATEGORY'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text(
                    'Select a category',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(categoryLabels[value] ?? value),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => selectedCategory = newValue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('YOUR BUDGET (DZD)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: AppColors.textDisabled),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const Text(
                    'DZD',
                    style: TextStyle(
                      color: AppColors.burntOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.retroTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.retroTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.retroTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.retroTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Estimation',
                              style: TextStyle(
                                color: AppColors.retroTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.retroTeal,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BETA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _aiPrice != null
                              ? 'Suggested price: ${_aiPrice!.toStringAsFixed(0)} DZD'
                              : 'Fill title & description then click Get AI Price',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_aiPrice != null)
                    TextButton(
                      onPressed: () =>
                      _budgetController.text = _aiPrice!.toStringAsFixed(0),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: AppColors.retroTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _loadingAiPrice ? null : _getAiPrice,
                icon: _loadingAiPrice
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  _loadingAiPrice ? 'Getting AI price...' : 'Get AI Price',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.retroTeal,
                  side: BorderSide(
                    color: AppColors.retroTeal.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burntOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Post Mission',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}