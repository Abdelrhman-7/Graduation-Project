import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:graduationproject/core/resources/color_manager.dart';
import 'package:graduationproject/core/resources/values_manager.dart';
import 'package:graduationproject/core/widgets/custom_text_field.dart';
import 'package:graduationproject/core/widgets/custom_dropdown_field.dart';
import 'package:graduationproject/presentation/doctor/register%20screen/cubit/registergoctor_cubit.dart';
import '../../../login/view/login_view.dart';
import '../../../role_selection/cubit/role_selection_state.dart';

class DoctorRegisterForm extends StatefulWidget {
  const DoctorRegisterForm({super.key});

  @override
  State<DoctorRegisterForm> createState() => _DoctorRegisterFormState();
}

class _DoctorRegisterFormState extends State<DoctorRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController(text: "abdo85@gmail.com");
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _passwordController = TextEditingController(
    text: '01008765502Abdo@',
  );
  final _confirmPasswordController = TextEditingController(
    text: '01008765502Abdo@',
  );
  final _dobController = TextEditingController();

  String? _gender;
  int? _departmentId;
  File? _profileImage;      // صورة البروفايل
  File? _credentialsFile;   // ملف الـ credentials
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _departments = [
    {'id': 1, 'name': 'Cardiology'},
    {'id': 2, 'name': 'Dermatology'},
    {'id': 3, 'name': 'Neurology'},
    {'id': 4, 'name': 'Orthopedics'},
    {'id': 5, 'name': 'Pediatrics'},
    {'id': 6, 'name': 'Psychiatry'},
    {'id': 7, 'name': 'Ophthalmology'},
  ];

  // اختيار صورة البروفايل
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
      maxHeight: 1440,
    );
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // اختيار ملف الـ credentials (منفصل عن البروفايل)
  Future<void> _pickCredentials() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1440,
      maxHeight: 1440,
    );
    if (file != null) {
      setState(() {
        _credentialsFile = File(file.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterDoctorCubit, DoctorRegisterState>(
      listener: (context, state) {
        if (state is DoctorRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginView(role: UserRole.doctor),
            ),
            (route) => false,
          );
        } else if (state is DoctorRegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: ColorManager.borderColor,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: ColorManager.bodyText,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: ColorManager.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSize.s20),

              CustomTextField(
                label: "Full Name",
                hintText: "Enter your full name",
                controller: _fullNameController,
                prefixIcon: Icons.person_outline,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: "Email Address",
                hintText: "example@mail.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (val) =>
                    val == null || !val.contains('@') ? "Invalid email" : null,
              ),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: "Phone Number",
                hintText: "Enter phone number",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: "Address",
                hintText: "Enter your address",
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: AppSize.s16),

              Row(
                children: [
                  Expanded(
                    child: CustomDropdownField<String>(
                      label: "Gender",
                      hintText: "Select",
                      value: _gender,
                      items: ["Male", "Female"]
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                  ),
                  const SizedBox(width: AppSize.s16),
                  Expanded(
                    child: CustomTextField(
                      label: "Date of Birth",
                      hintText: "YYYY-MM-DD",
                      controller: _dobController,
                      readOnly: true,
                      prefixIcon: Icons.calendar_today_outlined,
                      onChanged: (_) {}, // dummy to trigger rebuild if needed
                      validator: (val) =>
                          val == null || val.isEmpty ? "Required" : null,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _selectDate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s16),

              CustomDropdownField<int>(
                label: "Department",
                hintText: "Select your department",
                value: _departmentId,
                items: _departments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d['id'] as int,
                        child: Text(d['name']),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _departmentId = val),
              ),
              const SizedBox(height: AppSize.s16),

              const SizedBox(height: AppSize.s24),

              CustomTextField(
                label: "About Me",
                hintText: "Briefly describe your experience...",
                controller: _aboutMeController,
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: AppSize.s24),

              // Security Settings Section
              Row(
                children: [
                  Icon(
                    Icons.security_outlined,
                    color: ColorManager.headlineText,
                    size: AppSize.s24,
                  ),
                  const SizedBox(width: AppSize.s12),
                  Text(
                    "Security Settings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorManager.headlineText,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize.s18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: "Create Password",
                hintText: "At least 8 characters",
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (val) =>
                    val == null || val.length < 8 ? "Min 8 characters" : null,
              ),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: "Confirm Password",
                hintText: "Re-enter your password",
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "The ConfirmPassword field is required.";
                  }
                  if (val != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSize.s24),

              // Identity Verification Section
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: ColorManager.headlineText,
                    size: AppSize.s24,
                  ),
                  const SizedBox(width: AppSize.s12),
                  Text(
                    "Identity Verification",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorManager.headlineText,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize.s18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s8),
              Text(
                "Your documents are encrypted and securely stored. We are HIPAA compliant and value your privacy.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorManager.subtitleText,
                  fontSize: AppSize.s14,
                ),
              ),
              const SizedBox(height: AppSize.s16),

              // Upload Credentials Box
              GestureDetector(
                onTap: _pickCredentials,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppPadding.p24),
                  decoration: BoxDecoration(
                    color: _credentialsFile != null
                        ? Colors.green.withOpacity(0.05)
                        : ColorManager.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSize.s16),
                    border: Border.all(
                      color: _credentialsFile != null
                          ? Colors.green.withOpacity(0.4)
                          : ColorManager.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _credentialsFile != null
                            ? Icons.check_circle_outline
                            : Icons.upload_file_outlined,
                        size: AppSize.s48,
                        color: _credentialsFile != null
                            ? Colors.green
                            : ColorManager.primary,
                      ),
                      const SizedBox(height: AppSize.s12),
                      Text(
                        "Upload Credentials",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: ColorManager.headlineText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Text(
                        _credentialsFile != null
                            ? "File: ${_credentialsFile!.path.split('/').last}"
                            : "PDF • JPG • PNG",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _credentialsFile != null
                              ? Colors.green
                              : ColorManager.subtitleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSize.s40),

              SizedBox(
                width: double.infinity,
                height: AppSize.s56,
                child: ElevatedButton(
                  onPressed: state is DoctorRegisterLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() &&
                              _gender != null &&
                              _departmentId != null) {
                            context.read<RegisterDoctorCubit>().registerDoctor(
                              fullName: _fullNameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              phoneNumber: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                              gender: _gender!,
                              dateOfBirth: _dobController.text,
                              departmentId: _departmentId!,
                              aboutMe: _aboutMeController.text.trim(),
                              imageFile: _profileImage?.path,
                            );
                          } else if (_gender == null || _departmentId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select gender and department",
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                  ),
                  child: state is DoctorRegisterLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit & Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSize.s20),
            ],
          ),
        );
      },
    );
  }
}
