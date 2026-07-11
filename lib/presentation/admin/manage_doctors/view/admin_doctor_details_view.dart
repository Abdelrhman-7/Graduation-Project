import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/shared_pref_controller.dart';
import '../cubit/manage_doctors_cubit.dart';
import '../cubit/manage_doctors_state.dart';
import 'admin_edit_doctor_view.dart';
import 'reset_password_dialog.dart';

class AdminDoctorDetailsView extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const AdminDoctorDetailsView({super.key, required this.doctor});

  @override
  State<AdminDoctorDetailsView> createState() => _AdminDoctorDetailsViewState();
}

class _AdminDoctorDetailsViewState extends State<AdminDoctorDetailsView> {
  final SharedPrefController _sharedPrefController = SharedPrefController();
  bool? _savedLockStatus; // null = not loaded yet

  @override
  void initState() {
    super.initState();
    _loadSavedLockStatus();
  }

  Future<void> _loadSavedLockStatus() async {
    final doctorId = widget.doctor['id'] ?? widget.doctor['Id'];
    if (doctorId == null) return;
    final saved = await _sharedPrefController.getDoctorLockStatus(doctorId.toString());
    if (mounted) {
      setState(() {
        _savedLockStatus = saved;
      });
    }
  }

  Future<void> _saveLockStatus(String doctorId, bool isLocked) async {
    await _sharedPrefController.saveDoctorLockStatus(doctorId, isLocked);
    if (mounted) {
      setState(() {
        _savedLockStatus = isLocked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageDoctorsCubit, ManageDoctorsState>(
      buildWhen: (previous, current) =>
          current is ManageDoctorsDoctorDetailsLoaded,
      listener: (context, state) {
        if (state is ManageDoctorsOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ManageDoctorsOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Use updated doctor data if available
        Map<String, dynamic> currentDoctor = widget.doctor;
        if (state is ManageDoctorsDoctorDetailsLoaded) {
          currentDoctor = state.doctor;
        }

        final doctorId = currentDoctor['id'] ?? currentDoctor['Id'];
        final name =
            currentDoctor['fullName'] ??
            currentDoctor['FullName'] ??
            'Unknown Name';
        final email =
            currentDoctor['appUserEmail'] ??
            currentDoctor['email'] ??
            'No Email';
        final department =
            currentDoctor['departmentName'] ??
            currentDoctor['Department'] ??
            'General';
        final phone =
            currentDoctor['phoneNumber'] ??
            currentDoctor['PhoneNumber'] ??
            'N/A';
        final address =
            currentDoctor['address'] ?? currentDoctor['Address'] ?? 'N/A';
        final gender =
            currentDoctor['gender'] ?? currentDoctor['Gender'] ?? 'N/A';
        final dob =
            currentDoctor['dateOfBirth'] ??
            currentDoctor['DateOfBirth'] ??
            'N/A';
        final about =
            currentDoctor['aboutMe'] ?? currentDoctor['AboutMe'] ?? 'N/A';

        // حساب الحالة من الـ API
        final lockoutEndVal =
            currentDoctor['lockoutEnd'] ?? currentDoctor['LockoutEnd'];
        final isLockedFromApi =
            lockoutEndVal != null &&
            DateTime.tryParse(lockoutEndVal.toString()) != null &&
            DateTime.parse(lockoutEndVal.toString()).isAfter(DateTime.now());

        // استخدام الحالة المحفوظة إذا موجودة، وإلا استخدام حالة الـ API
        final isLocked = _savedLockStatus ?? isLockedFromApi;
        final lockStatus = isLocked ? 'Locked' : 'Unlocked';

        return Scaffold(
          appBar: AppBar(title: const Text('Doctor Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    String getImageUrl(dynamic path) {
                      if (path == null || path.toString().isEmpty) {
                        return '';
                      }
                      String strPath = path.toString().replaceAll('\\', '/');
                      if (strPath.startsWith('http')) {
                        return strPath;
                      } else if (strPath.startsWith('/')) {
                        return 'http://mediconnect.somee.com$strPath';
                      } else {
                        return 'http://mediconnect.somee.com/$strPath';
                      }
                    }
                    
                    final String imageUrl = getImageUrl(currentDoctor['imageUrl'] ?? currentDoctor['displayImageUrl']);
                    
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    );
                  }
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.email, 'Email', email),
                        const Divider(),
                        _buildDetailRow(Icons.phone, 'Phone Number', phone),
                        const Divider(),
                        _buildDetailRow(Icons.location_on, 'Address', address),
                        const Divider(),
                        _buildDetailRow(Icons.person_outline, 'Gender', gender),
                        const Divider(),
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Date of Birth',
                          dob.toString().split('T').first,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          Icons.local_hospital,
                          'Department',
                          department,
                        ),
                        const Divider(),
                        _buildDetailRow(Icons.info_outline, 'About Me', about),
                        const Divider(),
                        _buildDetailRow(
                          Icons.security,
                          'Lockout Status',
                          lockStatus,
                          valueColor: isLocked ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6C757D,
                        ), // Back to list - Gray
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      label: const Text('Back to List'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFC107,
                        ), // Edit - Yellow
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ManageDoctorsCubit>(),
                              child: AdminEditDoctorView(doctor: currentDoctor),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Profile'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745), // Green
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: !isLocked
                          ? null
                          : () {
                              _saveLockStatus(doctorId.toString(), false);
                              context.read<ManageDoctorsCubit>().toggleDoctorLock(
                                doctorId,
                              );
                            },
                      icon: const Icon(Icons.lock_open, size: 16),
                      label: const Text('Unblock'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3545), // Red
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: isLocked
                          ? null
                          : () {
                              _saveLockStatus(doctorId.toString(), true);
                              context.read<ManageDoctorsCubit>().toggleDoctorLock(
                                doctorId,
                              );
                            },
                      icon: const Icon(Icons.lock, size: 16),
                      label: const Text('Block'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF343A40,
                        ), // Reset Password - Dark Gray
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ManageDoctorsCubit>(),
                            child: ResetPasswordDialog(doctorId: doctorId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.key, size: 16),
                      label: const Text('Reset Password'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFDC3545,
                        ), // Delete - Red
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'Are you sure you want to delete this doctor account?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context
                                      .read<ManageDoctorsCubit>()
                                      .deleteDoctor(doctorId);
                                  Navigator.pop(context); // Go back to list
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete Account'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
