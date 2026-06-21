import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_patients_cubit.dart';
import '../cubit/manage_patients_state.dart';
import '../../../../data/repository/repository.dart';

class ManagePatientsView extends StatelessWidget {
  const ManagePatientsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManagePatientsCubit(context.read<Repository>())..fetchPatients(),
      child: const _ManagePatientsBody(),
    );
  }
}

class _ManagePatientsBody extends StatelessWidget {
  const _ManagePatientsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagePatientsCubit, ManagePatientsState>(
      listener: (context, state) {
        if (state is ManagePatientsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ManagePatientsLoading) {
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
                final name = patient['fullName'] ?? patient['FullName'] ?? 'Unknown Name';
                final email = patient['appUserEmail'] ?? patient['email'] ?? 'No Email';
                final phone = patient['phoneNumber'] ?? 'No Phone';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(name),
                    subtitle: Text('$phone\n$email'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, patientId, name);
                      },
                    ),
                  ),
                );
              },
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

