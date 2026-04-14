import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/task_card.dart';
import '../profile/profile_screen.dart';
import '../task/task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'Tous';

  final List<TaskModel> tasks = [
    const TaskModel(
      id: '1',
      title: 'Course urgente IHEC',
      posterName: 'Syrine M.',
      university: 'IHEC',
      price: 15.000,
      rating: 4.8,
      type: TaskType.physical,
      status: TaskStatus.open,
      category: 'Courses',
      timeAgo: 'Posté il y a 10 min',
      location: 'Carthage, Tunis',
    ),
    const TaskModel(
      id: '2',
      title: 'Logo association étudiante',
      posterName: 'Ahmed B.',
      university: 'ESSTHS',
      price: 45.000,
      rating: 4.5,
      type: TaskType.digital,
      status: TaskStatus.open,
      category: 'Design',
      timeAgo: 'Posté il y a 2h',
      location: 'À rendre Dimanche',
    ),
    const TaskModel(
      id: '3',
      title: 'Traduction article scientifique',
      posterName: 'Leila K.',
      university: 'FSG',
      price: 25.000,
      rating: 5.0,
      type: TaskType.digital,
      status: TaskStatus.open,
      category: 'Traduction',
      timeAgo: 'Posté il y a 5h',
      location: 'Remote',
    ),
    const TaskModel(
      id: '4',
      title: 'Aide déménagement studio',
      posterName: 'Karim T.',
      university: 'INSAT',
      price: 60.000,
      rating: 4.2,
      type: TaskType.physical,
      status: TaskStatus.open,
      category: 'Services',
      timeAgo: 'Posté hier',
      location: 'La Marsa',
    ),
  ];

  List<TaskModel> get filteredTasks {
    if (selectedFilter == 'Tous') return tasks;
    if (selectedFilter == 'Physique') {
      return tasks.where((t) => t.type == TaskType.physical).toList();
    }
    if (selectedFilter == 'Digital') {
      return tasks.where((t) => t.type == TaskType.digital).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            // Menu latéral si besoin
          },
        ),
        title: const Text(
          'KHADEMNI',
          style: TextStyle(
            color: AppColors.burntOrange,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.burntOrange, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Header Text
            Text(
              'Trouvez votre\nprochain coup de main.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.burntOrange,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La plateforme d\'entraide étudiante premium.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous', selectedFilter == 'Tous'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Physique', selectedFilter == 'Physique'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Digital', selectedFilter == 'Digital'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Liste des missions
            ...filteredTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TaskDetailScreen(),
                      ),
                    );
                  },
                  child: TaskCard(task: task),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Section "Plus de missions"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderLight,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.goldenYellow,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Plus de missions ?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Découvrir tout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.burntOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burntOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.burntOrange : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
