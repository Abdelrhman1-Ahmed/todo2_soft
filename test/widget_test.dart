// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo2_app/core/hive_boxes.dart';
import 'package:todo2_app/data/model/task_model.dart';
import 'package:todo2_app/data/model/user_model.dart';
import 'package:todo2_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Hive.init('./.dart_tool/test_hive');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    await Hive.openBox<UserModel>(HiveBoxes.user);
    await Hive.openBox<TaskModel>(HiveBoxes.tasks);
  });

  tearDown(() async {
    await Hive.box<UserModel>(HiveBoxes.user).clear();
    await Hive.box<TaskModel>(HiveBoxes.tasks).clear();
  });

  testWidgets('Shows create profile screen when no user exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Create Your Profile'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
