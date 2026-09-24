import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo2_app/core/app_colors.dart';
import 'package:todo2_app/core/app_routes.dart';
import 'package:todo2_app/core/hive_boxes.dart';
import 'package:todo2_app/data/model/user_model.dart';
import 'package:todo2_app/data/view/widgets/custom_text_form_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    fullName.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() => _imagePath = picked.path);
    } catch (error) {
      log(error.toString());
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Could not pick an image')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = fullName.text.trim();

    try {
      final userBox = Hive.box<UserModel>(HiveBoxes.user);
      await userBox.put(
        HiveBoxes.userKey,
        UserModel(fullname: name, imagePath: _imagePath),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (error) {
      log(error.toString());
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Could not save your profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 72),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.avatarFill,
                    backgroundImage: _imagePath == null
                        ? null
                        : FileImage(File(_imagePath!)),
                    child: _imagePath == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Your Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your name and profile picture',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8A93A6)),
                ),
                const SizedBox(height: 32),
                CustomTextFormField(
                  label: 'Full Name',
                  hint: 'Ahmed Abdelsattar',
                  controller: fullName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continue',
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
