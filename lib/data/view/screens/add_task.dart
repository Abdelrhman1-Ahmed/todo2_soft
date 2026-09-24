import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo2_app/core/app_colors.dart';
import 'package:todo2_app/core/hive_boxes.dart';
import 'package:todo2_app/data/model/task_model.dart';
import 'package:todo2_app/data/view/widgets/custom_text_form_field.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = TaskStatus.pending;
  Color _color = AppColors.taskPalette.first;
  TaskModel? _existing;
  var _didLoadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadArgs) return;
    _didLoadArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TaskModel) {
      _existing = args;
      _titleController.text = args.title;
      _descriptionController.text = args.description;
      _status = args.status;
      _color = Color(args.colorValue);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_existing != null) {
      _existing!
        ..title = title
        ..description = description
        ..status = _status
        ..colorValue = _color.toARGB32();
      await _existing!.save();
    } else {
      final box = Hive.box<TaskModel>(HiveBoxes.tasks);
      await box.add(
        TaskModel(
          title: title,
          description: description,
          status: _status,
          colorValue: _color.toARGB32(),
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          isEdit ? 'Edit Task' : 'Add Task',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormField(
                  label: 'Task Title',
                  hint: 'Design Login Screen',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  label: 'Description',
                  hint: 'Task Description...',
                  controller: _descriptionController,
                  maxLines: 5,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  items: TaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Choose Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: AppColors.taskPalette
                      .map(
                        (color) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _color = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _color.toARGB32() == color.toARGB32()
                                    ? Border.all(color: Colors.black26, width: 2)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Save Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
