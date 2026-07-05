import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_doctors_cubit.dart';
import '../cubit/manage_doctors_state.dart';

class ResetPasswordDialog extends StatefulWidget {
  final int doctorId;

  const ResetPasswordDialog({Key? key, required this.doctorId}) : super(key: key);

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageDoctorsCubit, ManageDoctorsState>(
      listener: (context, state) {
        if (state is ManageDoctorsOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Reset Doctor Password'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value != _newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: state is ManageDoctorsOperationLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ManageDoctorsCubit>().resetDoctorPassword(
                              widget.doctorId,
                              _newPasswordController.text,
                              _confirmPasswordController.text,
                            );
                      }
                    },
              child: state is ManageDoctorsOperationLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
