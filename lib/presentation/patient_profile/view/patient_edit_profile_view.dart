import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/resources/color_manager.dart';
import '../cubit/patient_profile_cubit.dart';
import '../cubit/patient_profile_state.dart';

class PatientEditProfileView extends StatefulWidget {
  final PatientProfileCubit cubit;
  final String currentName;
  
  const PatientEditProfileView({super.key, required this.cubit, required this.currentName});

  @override
  State<PatientEditProfileView> createState() => _PatientEditProfileViewState();
}

class _PatientEditProfileViewState extends State<PatientEditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  File? _imageFile;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();

    // تملى الفيلدات بالبيانات الموجودة من الـ state
    final state = widget.cubit.state;
    if (state is PatientProfileSuccess) {
      _nameController.text = state.name;
      _emailController.text = state.email;
      _phoneController.text = state.phone;
      _addressController.text = state.address;
      _genderController.text = state.gender;
      final rawDob = state.dateOfBirth;
      _dobController.text = rawDob.contains('T') ? rawDob.split('T').first : rawDob;
      if (state.imageUrl != null && state.imageUrl!.isNotEmpty) {
        _currentImageUrl = state.imageUrl;
      }
    } else {
      // Fallback: استخدم currentName لو مفيش state
      _nameController.text = widget.currentName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
      maxHeight: 1440,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: GoogleFonts.lexend()),
          backgroundColor: ColorManager.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (!mounted) return; // ← منع أي UI action بعد dispose
            if (state is PatientProfileEditSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              // نعمل pop في microtask عشان نضمن إن build cycle خلص
              Future.microtask(() {
                if (mounted) Navigator.pop(context);
              });
            } else if (state is PatientProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is PatientProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                                  ? NetworkImage(_currentImageUrl!) as ImageProvider
                                  : null,
                          child: (_imageFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: ColorManager.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_nameController, 'Full Name'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Phone Number'),
                  const SizedBox(height: 16),
                  _buildTextField(_addressController, 'Address'),
                  const SizedBox(height: 16),
                  _buildTextField(_genderController, 'Gender'),
                  const SizedBox(height: 16),
                  _buildTextField(_dobController, 'Date of Birth'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.cubit.editProfile(
                          fullName: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                          gender: _genderController.text.trim(),
                          dateOfBirth: _dobController.text.trim(),
                          imagePath: _imageFile?.path,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Save Changes', style: GoogleFonts.lexend(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorManager.primary),
        ),
      ),
    );
  }
}
