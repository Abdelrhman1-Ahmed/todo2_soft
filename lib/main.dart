import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo2_app/core/app_colors.dart';
import 'package:todo2_app/core/app_routes.dart';
import 'package:todo2_app/core/hive_boxes.dart';
import 'package:todo2_app/data/model/task_model.dart';
import 'package:todo2_app/data/model/user_model.dart';
import 'package:todo2_app/data/view/screens/add_task.dart';
import 'package:todo2_app/data/view/screens/home_screen.dart';
import 'package:todo2_app/data/view/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<UserModel>(HiveBoxes.user);
  await Hive.openBox<TaskModel>(HiveBoxes.tasks);
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUser = Hive.box<UserModel>(HiveBoxes.user).isNotEmpty;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: hasUser ? AppRoutes.home : AppRoutes.profile,
      routes: {
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.addtask: (context) => const AddTask(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
    );
  }
}
