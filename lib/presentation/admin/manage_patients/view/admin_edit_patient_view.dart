import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_patients_cubit.dart';
import '../cubit/manage_patients_state.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditPatientView extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AdminEditPatientView({super.key, required this.patient});

  @override
  // ignore: library_private_types_in_public_api
  _AdminEditPatientViewState createState() => _AdminEditPatientViewState();
}

class _AdminEditPatientViewState extends State<AdminEditPatientView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;

  String? _selectedGender;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _fullNameController = TextEditingController(
      text: p['fullName'] ?? p['FullName'] ?? '',
    );
    _phoneController = TextEditingController(
      text: p['phoneNumber'] ?? p['PhoneNumber'] ?? '',
    );
    _addressController = TextEditingController(
      text: p['address'] ?? p['Address'] ?? '',
    );

    final dob = p['dateOfBirth'] ?? p['DateOfBirth'];
    _dobController = TextEditingController(
      text: dob != null ? dob.toString().split('T').first : '',
    );

    final gender = p['gender'] ?? p['Gender'];
    if (gender == 'Male' || gender == 'Female') {
      _selectedGender = gender;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Patient Profile')),
      body: BlocConsumer<ManagePatientsCubit, ManagePatientsState>(
        listener: (context, state) {
          if (state is ManagePatientsOperationSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imagePath != null
                              ? NetworkImage(_imagePath!)
                              : (widget.patient['imageUrl'] != null
                                        ? NetworkImage(
                                            'http://mediconnect.somee.com${widget.patient['imageUrl']}',
                                          )
                                        : null)
                                    as ImageProvider?,
                          child:
                              _imagePath == null &&
                                  widget.patient['imageUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),

                        /* return CircleAvatar(
                                  radius: 24,
                                  backgroundImage: imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : null,
                                  child: imageUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                );*/
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload New Image'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state is ManagePatientsOperationLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final data = {
                                      'FullName': _fullNameController.text,
                                      'PhoneNumber': _phoneController.text,
                                      'Address': _addressController.text,
                                      'Gender': _selectedGender ?? '',
                                      'DateOfBirth': _dobController.text,
                                    };
                                    final patientId =
                                        widget.patient['id'] ??
                                        widget.patient['Id'];
                                    context
                                        .read<ManagePatientsCubit>()
                                        .editPatient(
                                          patientId,
                                          data,
                                          _imagePath,
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: state is ManagePatientsOperationLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
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
  }
}
