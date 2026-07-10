import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/core/resources/color_manager.dart';
import 'package:graduationproject/core/resources/values_manager.dart';
import 'package:graduationproject/core/widgets/custom_dropdown_field.dart';
import 'package:graduationproject/core/widgets/custom_text_field.dart';
import 'package:graduationproject/presentation/doctor/register%20screen/cubit/doctor_register_cubit.dart';
import 'package:graduationproject/presentation/login/view/login_view.dart';
import 'package:graduationproject/presentation/role_selection/cubit/role_selection_state.dart';

class DoctorRegisterForm extends StatefulWidget {
  const DoctorRegisterForm({super.key});

  @override
  State<DoctorRegisterForm> createState() => _DoctorRegisterFormState();
}

class _DoctorRegisterFormState extends State<DoctorRegisterForm> {
  // ─── Form ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers (pre-filled for testing) ───────────────────
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _aboutMe;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  late final TextEditingController _dob;

  // ─── Dropdown state ──────────────────────────────────────────
  String? _gender;
  int? _departmentId;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  static const List<Map<String, dynamic>> _departments = [
    {'id': 1, 'name': 'Cardiology'},
    {'id': 2, 'name': 'Dermatology'},
    {'id': 3, 'name': 'Neurology'},
    {'id': 4, 'name': 'Orthopedics'},
    {'id': 5, 'name': 'Pediatrics'},
    {'id': 6, 'name': 'Psychiatry'},
    {'id': 7, 'name': 'Ophthalmology'},
  ];

  // ─── Lifecycle ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController();
    _email = TextEditingController(text: 'abdo@gmail.com');
    _phone = TextEditingController();
    _address = TextEditingController();
    _aboutMe = TextEditingController();
    _password = TextEditingController(text: '01008765502Abdo@');
    _confirmPassword = TextEditingController(text: '01008765502Abdo@');
    _dob = TextEditingController();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _aboutMe.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _dob.dispose();
    super.dispose();
  }

  // ─── Date picker ─────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1985, 6, 15),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && mounted) {
      setState(() {
        _dob.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // ─── Submit ──────────────────────────────────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      _snack('Please fill all required fields correctly', error: true);
      return;
    }
    if (_gender == null) {
      _snack('Please select gender', error: true);
      return;
    }
    if (_departmentId == null) {
      _snack('Please select department', error: true);
      return;
    }

    context.read<DoctorRegisterCubit>().register(
      fullName: _fullName.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      confirmPassword: _confirmPassword.text,
      phoneNumber: _phone.text.trim(),
      address: _address.text.trim(),
      gender: _gender!,
      dateOfBirth: _dob.text,
      departmentId: _departmentId!,
      aboutMe: _aboutMe.text.trim(),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorRegisterCubit, DoctorRegisterState>(
      listener: (ctx, state) {
        if (state is DoctorRegisterSuccess) {
          _snack(state.message);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginView(role: UserRole.doctor),
            ),
            (_) => false,
          );
        } else if (state is DoctorRegisterError) {
          _snack(state.message, error: true);
        }
      },
      builder: (ctx, state) {
        final loading = state is DoctorRegisterLoading;
        final errorMsg = state is DoctorRegisterError ? state.message : null;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Error banner ──────────────────────────────────
              if (errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMsg,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSize.s16),
              ],

              // ── Section: Personal ─────────────────────────────
              _sectionTitle(Icons.person_outline, 'Personal Information'),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: 'Full Name',
                hintText: 'Dr. John Smith',
                controller: _fullName,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSize.s12),

              CustomTextField(
                label: 'Email Address',
                hintText: 'doctor@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: AppSize.s12),

              CustomTextField(
                label: 'Phone Number',
                hintText: '01012345678',
                controller: _phone,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSize.s12),

              CustomTextField(
                label: 'Address',
                hintText: 'Cairo, Egypt',
                controller: _address,
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSize.s12),

              // Gender + DOB in a row
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownField<String>(
                      label: 'Gender',
                      hintText: 'Select',
                      value: _gender,
                      items: ['Male', 'Female']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                  const SizedBox(width: AppSize.s12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Date of Birth',
                      hintText: 'YYYY-MM-DD',
                      controller: _dob,
                      readOnly: true,
                      prefixIcon: Icons.calendar_today_outlined,
                      onChanged: (_) {},
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: _pickDate,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s12),

              CustomDropdownField<int>(
                label: 'Department / Specialization',
                hintText: 'Select department',
                value: _departmentId,
                items: _departments
                    .map(
                      (d) => DropdownMenuItem<int>(
                        value: d['id'] as int,
                        child: Text(d['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _departmentId = v),
              ),
              const SizedBox(height: AppSize.s12),

              CustomTextField(
                label: 'About Me',
                hintText: 'Briefly describe your experience...',
                controller: _aboutMe,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSize.s24),

              // ── Section: Security ─────────────────────────────
              _sectionTitle(Icons.lock_outline, 'Security'),
              const SizedBox(height: AppSize.s16),

              CustomTextField(
                label: 'Password',
                hintText: 'Min 8 chars, 1 uppercase',
                controller: _password,
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'Min 8 characters';
                  if (!v.contains(RegExp(r'[A-Z]')))
                    return 'Must have uppercase letter';
                  return null;
                },
              ),
              const SizedBox(height: AppSize.s12),

              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter password',
                controller: _confirmPassword,
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _password.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: AppSize.s32),

              // ── Submit button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppSize.s56,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    disabledBackgroundColor: ColorManager.primary.withOpacity(
                      0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.s12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit & Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
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

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: ColorManager.headlineText, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ColorManager.headlineText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
