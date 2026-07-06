import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_patients_cubit.dart';
import '../cubit/manage_patients_state.dart';
import '../../../../data/repository/repository.dart';
import 'admin_patient_details_view.dart';
import 'reset_patient_password_dialog.dart';

class ManagePatientsView extends StatelessWidget {
  const ManagePatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ManagePatientsCubit(context.read<Repository>())..fetchPatients(),
      child: const _ManagePatientsBody(),
    );
  }
}

class _ManagePatientsBody extends StatelessWidget {
  const _ManagePatientsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagePatientsCubit, ManagePatientsState>(
      buildWhen: (previous, current) =>
          current is ManagePatientsInitial ||
          current is ManagePatientsLoading ||
          current is ManagePatientsLoaded ||
          current is ManagePatientsError,
      listener: (context, state) {
        if (state is ManagePatientsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ManagePatientsOperationSuccess) {
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
        } else if (state is ManagePatientsPatientDetailsLoaded) {
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
          if (isCurrentRoute) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ManagePatientsCubit>(),
                  child: AdminPatientDetailsView(patient: state.patient),
                ),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<ManagePatientsCubit>().restorePatientsList();
              }
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ManagePatientsLoading || state is ManagePatientsInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ManagePatientsLoaded) {
          final patients = state.patients;
          if (patients.isEmpty) {
            return const Center(child: Text('No patients found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ManagePatientsCubit>().fetchPatients();
            },
            child: ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                final patientId = patient['id'] ?? patient['Id'];
                final name =
                    patient['fullName'] ??
                    patient['FullName'] ??
                    'Unknown Name';
                final email =
                    patient['appUserEmail'] ?? patient['email'] ?? 'No Email';
                final phone = patient['phoneNumber'] ?? 'No Phone';

                final lockoutEndVal =
                    patient['lockoutEnd'] ?? patient['LockoutEnd'];
                final isLocked =
                    lockoutEndVal != null &&
                    DateTime.tryParse(lockoutEndVal.toString()) != null &&
                    DateTime.parse(
                      lockoutEndVal.toString(),
                    ).isAfter(DateTime.now());
                final lockStatus = isLocked ? 'Locked' : 'Unlocked';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: patient['imageUrl'] != null
                                  ? NetworkImage(
                                      'http://clinicbook.runasp.net${patient['imageUrl']}',
                                    )
                                  : null,
                              child: patient['imageUrl'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lockStatus,
                                style: TextStyle(
                                  color: isLocked
                                      ? Colors.red[800]
                                      : Colors.green[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF17A2B8,
                                ), // Teal
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text(
                                'Details',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                context
                                    .read<ManagePatientsCubit>()
                                    .getPatientDetails(patientId);
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLocked
                                    ? const Color(0xFF28A745)
                                    : const Color(0xFF6C757D), // Green or Gray
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                              icon: Icon(
                                isLocked ? Icons.lock_open : Icons.lock,
                                size: 16,
                              ),
                              label: Text(
                                isLocked ? 'Unlock' : 'Lock',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                context
                                    .read<ManagePatientsCubit>()
                                    .togglePatientLock(patientId);
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF343A40,
                                ), // Dark gray
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                              icon: const Icon(Icons.key, size: 16),
                              label: const Text(
                                'Reset Pwd',
                                style: TextStyle(fontSize: 12),
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
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: () {
                                _confirmDelete(context, patientId, name);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is ManagePatientsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ManagePatientsCubit>().fetchPatients();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('Error loading patients'));
      },
    );
  }

  void _confirmDelete(BuildContext context, int patientId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete patient $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ManagePatientsCubit>().deletePatient(patientId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
