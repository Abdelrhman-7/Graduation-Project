import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_doctors_cubit.dart';
import '../cubit/manage_doctors_state.dart';
import '../../../../data/repository/repository.dart';
import 'admin_doctor_details_view.dart';
import 'reset_password_dialog.dart';

class ManageDoctorsView extends StatelessWidget {
  const ManageDoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ManageDoctorsCubit(context.read<Repository>())..fetchDoctors(),
      child: const _ManageDoctorsBody(),
    );
  }
}

class _ManageDoctorsBody extends StatelessWidget {
  const _ManageDoctorsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageDoctorsCubit, ManageDoctorsState>(
      buildWhen: (previous, current) =>
          current is ManageDoctorsInitial ||
          current is ManageDoctorsLoading ||
          current is ManageDoctorsLoaded ||
          current is ManageDoctorsError,
      listener: (context, state) {
        if (state is ManageDoctorsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ManageDoctorsOperationSuccess) {
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
        } else if (state is ManageDoctorsDoctorDetailsLoaded) {
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
          if (isCurrentRoute) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ManageDoctorsCubit>(),
                  child: AdminDoctorDetailsView(doctor: state.doctor),
                ),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<ManageDoctorsCubit>().restoreDoctorsList();
              }
            });
          }
        }
      },
      builder: (context, state) {
        if (state is ManageDoctorsLoading || state is ManageDoctorsInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ManageDoctorsLoaded) {
          final doctors = state.doctors;
          if (doctors.isEmpty) {
            return const Center(child: Text('No doctors found.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ManageDoctorsCubit>().fetchDoctors();
            },
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final doctorId = doctor['id'] ?? doctor['Id'];
                final name =
                    doctor['fullName'] ?? doctor['FullName'] ?? 'Unknown Name';
                final email =
                    doctor['appUserEmail'] ?? doctor['email'] ?? 'No Email';
                final lockoutEndVal =
                    doctor['lockoutEnd'] ?? doctor['LockoutEnd'];
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
                              backgroundImage: doctor['imageUrl'] != null
                                  ? NetworkImage(
                                      'http://clinicbook.runasp.net${doctor['imageUrl']}',
                                    )
                                  : null,
                              child: doctor['imageUrl'] == null
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
                                    .read<ManageDoctorsCubit>()
                                    .getDoctorDetails(doctorId);
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
                                    .read<ManageDoctorsCubit>()
                                    .toggleDoctorLock(doctorId);
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
                                    value: context.read<ManageDoctorsCubit>(),
                                    child: ResetPasswordDialog(
                                      doctorId: doctorId,
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
                                _confirmDelete(context, doctorId, name);
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
        } else if (state is ManageDoctorsError) {
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
                      context.read<ManageDoctorsCubit>().fetchDoctors();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('Error loading doctors'));
      },
    );
  }

  void _confirmDelete(BuildContext context, int doctorId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete doctor $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ManageDoctorsCubit>().deleteDoctor(doctorId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
