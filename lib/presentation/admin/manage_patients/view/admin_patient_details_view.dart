import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/shared_pref_controller.dart';
import '../cubit/manage_patients_cubit.dart';
import '../cubit/manage_patients_state.dart';
import 'admin_edit_patient_view.dart';
import 'reset_patient_password_dialog.dart';

class AdminPatientDetailsView extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AdminPatientDetailsView({Key? key, required this.patient})
    : super(key: key);

  @override
  State<AdminPatientDetailsView> createState() =>
      _AdminPatientDetailsViewState();
}

class _AdminPatientDetailsViewState extends State<AdminPatientDetailsView> {
  final SharedPrefController _sharedPrefController = SharedPrefController();
  bool? _savedLockStatus; // null = not loaded yet

  @override
  void initState() {
    super.initState();
    _loadSavedLockStatus();
  }

  Future<void> _loadSavedLockStatus() async {
    final patientId = widget.patient['id'] ?? widget.patient['Id'];
    if (patientId == null) return;
    final saved = await _sharedPrefController.getPatientLockStatus(
      patientId.toString(),
    );
    if (mounted) {
      setState(() {
        _savedLockStatus = saved;
      });
    }
  }

  Future<void> _saveLockStatus(String patientId, bool isLocked) async {
    await _sharedPrefController.savePatientLockStatus(patientId, isLocked);
    if (mounted) {
      setState(() {
        _savedLockStatus = isLocked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagePatientsCubit, ManagePatientsState>(
      buildWhen: (previous, current) =>
          current is ManagePatientsPatientDetailsLoaded,
      listener: (context, state) {
        if (state is ManagePatientsOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ManagePatientsOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Use updated patient data if available
        Map<String, dynamic> currentPatient = widget.patient;
        if (state is ManagePatientsPatientDetailsLoaded) {
          currentPatient = state.patient;
        }

        final patientId = currentPatient['id'] ?? currentPatient['Id'];
        final name =
            currentPatient['fullName'] ??
            currentPatient['FullName'] ??
            'Unknown Name';
        final email =
            currentPatient['appUserEmail'] ??
            currentPatient['email'] ??
            'No Email';
        final phone =
            currentPatient['phoneNumber'] ??
            currentPatient['PhoneNumber'] ??
            'N/A';
        final address =
            currentPatient['address'] ?? currentPatient['Address'] ?? 'N/A';
        final gender =
            currentPatient['gender'] ?? currentPatient['Gender'] ?? 'N/A';
        final dob =
            currentPatient['dateOfBirth'] ??
            currentPatient['DateOfBirth'] ??
            'N/A';

        // حساب الحالة من الـ API
        final lockoutEndVal =
            currentPatient['lockoutEnd'] ?? currentPatient['LockoutEnd'];
        final isLockedFromApi =
            lockoutEndVal != null &&
            DateTime.tryParse(lockoutEndVal.toString()) != null &&
            DateTime.parse(lockoutEndVal.toString()).isAfter(DateTime.now());

        // استخدام الحالة المحفوظة إذا موجودة، وإلا استخدام حالة الـ API
        final isLocked = _savedLockStatus ?? isLockedFromApi;
        final lockStatus = isLocked ? 'UnLocked' : 'locked';

        return Scaffold(
          appBar: AppBar(title: const Text('Patient Profile')),
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
                    
                    final String imageUrl = getImageUrl(currentPatient['imageUrl'] ?? currentPatient['displayImageUrl']);
                    
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
                              value: context.read<ManagePatientsCubit>(),
                              child: AdminEditPatientView(
                                patient: currentPatient,
                              ),
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
                              _saveLockStatus(patientId.toString(), false);
                              context.read<ManagePatientsCubit>().togglePatientLock(
                                patientId,
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
                              _saveLockStatus(patientId.toString(), true);
                              context.read<ManagePatientsCubit>().togglePatientLock(
                                patientId,
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
                            value: context.read<ManagePatientsCubit>(),
                            child: ResetPatientPasswordDialog(
                              patientId: patientId,
                            ),
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
                              'Are you sure you want to delete this patient account?',
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
                                      .read<ManagePatientsCubit>()
                                      .deletePatient(patientId);
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
