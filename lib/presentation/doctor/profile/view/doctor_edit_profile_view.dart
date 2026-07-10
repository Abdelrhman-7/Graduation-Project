import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/resources/color_manager.dart';
import '../cubit/doctor_profile_cubit.dart';
import '../cubit/doctor_profile_state.dart';

class DoctorEditProfileView extends StatefulWidget {
  final String currentName;

  const DoctorEditProfileView({super.key, required this.currentName});

  @override
  State<DoctorEditProfileView> createState() => _DoctorEditProfileViewState();
}

class _DoctorEditProfileViewState extends State<DoctorEditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;
  late TextEditingController _aboutMeController;
  File? _imageFile;
  String? _currentImageUrl; // الصورة الحالية من السيرفر

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _aboutMeController = TextEditingController();

    // Fetch current profile data
    context.read<DoctorProfileCubit>().getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _aboutMeController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.cairo()),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
        listener: (context, state) {
          if (state is DoctorProfileEditSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context, true); // Return true to refresh parent
          } else if (state is DoctorProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DoctorProfileLoaded) {
            final data = state.profileData;
            _nameController.text = data['fullName'] ?? data['FullName'] ?? widget.currentName;
            _phoneController.text = data['phoneNumber'] ?? data['PhoneNumber'] ?? '';
            _addressController.text = data['address'] ?? data['Address'] ?? '';
            _genderController.text = data['gender'] ?? data['Gender'] ?? '';
            final rawDob = data['dateOfBirth'] ?? data['DateOfBirth'] ?? '';
            _dobController.text = rawDob.contains('T') ? rawDob.split('T').first : rawDob;
            _aboutMeController.text = data['aboutMe'] ?? data['AboutMe'] ?? '';
            // تحديث رابط الصورة الحالية من السيرفر
            final rawImageUrl = data['displayImageUrl'] ?? data['imageUrl'] ?? data['ImageUrl'] ?? data['profileImageUrl'] ?? data['ProfileImageUrl'] ?? data['imagePath'] ?? data['ImagePath'];
            if (rawImageUrl != null && rawImageUrl.toString().isNotEmpty) {
              final raw = rawImageUrl.toString();
              setState(() {
                _currentImageUrl = raw.startsWith('http')
                    ? raw
                    : 'http://mediconnect.somee.com$raw';
              });
            }
          }
        },
        builder: (context, state) {
          if (state is DoctorProfileLoading) {
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
                _buildTextField(_phoneController, 'Phone Number'),
                const SizedBox(height: 16),
                _buildTextField(_addressController, 'Address'),
                const SizedBox(height: 16),
                _buildTextField(_genderController, 'Gender'),
                const SizedBox(height: 16),
                _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)'),
                const SizedBox(height: 16),
                _buildTextField(_aboutMeController, 'About Me', maxLines: 3),
                const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final fullName = _nameController.text.trim();
                        final phone = _phoneController.text.trim();
                        final address = _addressController.text.trim();
                        final rawGender = _genderController.text.trim();
                        final rawDob = _dobController.text.trim();
                        final aboutMe = _aboutMeController.text.trim();

                        if (fullName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your Full Name')),
                          );
                          return;
                        }
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your Phone Number')),
                          );
                          return;
                        }
                        if (address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your Address')),
                          );
                          return;
                        }
                        if (rawGender.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your Gender')),
                          );
                          return;
                        }
                        if (rawDob.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your Date of Birth')),
                          );
                          return;
                        }

                        // Clean up dateOfBirth - strip time component if present
                        final cleanDob = rawDob.contains('T') ? rawDob.split('T').first : rawDob;
                        
                        // Capitalize gender
                        final cleanGender = rawGender.isEmpty ? '' : rawGender[0].toUpperCase() + rawGender.substring(1).toLowerCase();

                        context.read<DoctorProfileCubit>().editProfile(
                              fullName: fullName,
                              phoneNumber: phone,
                              address: address,
                              gender: cleanGender,
                              dateOfBirth: cleanDob,
                              aboutMe: aboutMe,
                              imagePath: _imageFile?.path,
                            );
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Changes', style: GoogleFonts.cairo(color: Colors.white, fontSize: 16)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
