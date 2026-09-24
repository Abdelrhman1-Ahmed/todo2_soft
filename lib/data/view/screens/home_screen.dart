import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo2_app/core/app_colors.dart';
import 'package:todo2_app/core/app_routes.dart';
import 'package:todo2_app/core/hive_boxes.dart';
import 'package:todo2_app/data/model/task_model.dart';
import 'package:todo2_app/data/model/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>(HiveBoxes.user);
    final user = userBox.get(HiveBoxes.userKey);
    final name = user?.fullname ?? 'Guest';
    final imagePath = user?.imagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 4),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.addtask);
          },
          backgroundColor: AppColors.fabBg,
          foregroundColor: AppColors.fabFg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add),
          label: const Text(
            'Task',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<TaskModel>(HiveBoxes.tasks).listenable(),
          builder: (context, Box<TaskModel> taskBox, _) {
            final tasks = taskBox.values.toList();
            final doneCount = tasks
                .where((task) => task.status == TaskStatus.done)
                .length;
            final pendingCount = tasks.length - doneCount;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.avatarFill,
                      backgroundImage: imagePath == null
                          ? null
                          : FileImage(File(imagePath)),
                      child: imagePath == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()} 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A93A6),
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statsCard,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      _StatItem(value: '${tasks.length}', label: 'Tasks'),
                      _StatItem(value: '$doneCount', label: 'Done'),
                      _StatItem(value: '$pendingCount', label: 'Pending'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No tasks yet. Tap + Task to add one.',
                        style: TextStyle(color: Color(0xFF8A93A6)),
                      ),
                    ),
                  )
                else
                  ...tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.addtask, arguments: task);
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFD5DAF5), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final TaskModel task;
  final VoidCallback onTap;

  Color get _chipBg {
    switch (task.status) {
      case TaskStatus.done:
        return AppColors.chipDoneBg;
      case TaskStatus.inProgress:
        return AppColors.chipProgressBg;
      default:
        return AppColors.chipPendingBg;
    }
  }

  Color get _chipFg {
    switch (task.status) {
      case TaskStatus.done:
        return AppColors.chipDoneFg;
      case TaskStatus.inProgress:
        return AppColors.chipProgressFg;
      default:
        return AppColors.chipPendingFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 12, 16),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(task.colorValue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A93A6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          color: _chipFg,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFB0B6C5)),
            ],
          ),
        ),
      ),
    );
  }
}
