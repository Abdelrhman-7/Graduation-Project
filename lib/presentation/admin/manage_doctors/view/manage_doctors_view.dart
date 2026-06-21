import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_doctors_cubit.dart';
import '../cubit/manage_doctors_state.dart';
import '../../../../data/repository/repository.dart';

class ManageDoctorsView extends StatelessWidget {
  const ManageDoctorsView({Key? key}) : super(key: key);

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
      listener: (context, state) {
        if (state is ManageDoctorsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ManageDoctorsLoading) {
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
                final department = doctor['departmentName'] ?? 'General';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name),
                    subtitle: Text('$department\n$email'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _confirmDelete(context, doctorId, name);
                      },
                    ),
                  ),
                );
              },
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
