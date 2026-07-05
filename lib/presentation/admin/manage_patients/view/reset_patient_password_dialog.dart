import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_patients_cubit.dart';
import '../cubit/manage_patients_state.dart';

class ResetPatientPasswordDialog extends StatefulWidget {
  final int patientId;

  const ResetPatientPasswordDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  _ResetPatientPasswordDialogState createState() => _ResetPatientPasswordDialogState();
}

class _ResetPatientPasswordDialogState extends State<ResetPatientPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagePatientsCubit, ManagePatientsState>(
      listener: (context, state) {
        if (state is ManagePatientsOperationSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Reset Patient Password'),
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
              onPressed: state is ManagePatientsOperationLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ManagePatientsCubit>().resetPatientPassword(
                              widget.patientId,
                              _newPasswordController.text,
                              _confirmPasswordController.text,
                            );
                      }
                    },
              child: state is ManagePatientsOperationLoading
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
