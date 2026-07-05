import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/manage_doctors_cubit.dart';
import '../cubit/manage_doctors_state.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditDoctorView extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const AdminEditDoctorView({Key? key, required this.doctor}) : super(key: key);

  @override
  _AdminEditDoctorViewState createState() => _AdminEditDoctorViewState();
}

class _AdminEditDoctorViewState extends State<AdminEditDoctorView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _aboutController;
  
  String? _selectedGender;
  String? _imagePath;
  int? _departmentId;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _fullNameController = TextEditingController(text: d['fullName'] ?? d['FullName'] ?? '');
    _phoneController = TextEditingController(text: d['phoneNumber'] ?? d['PhoneNumber'] ?? '');
    _addressController = TextEditingController(text: d['address'] ?? d['Address'] ?? '');
    
    final dob = d['dateOfBirth'] ?? d['DateOfBirth'];
    _dobController = TextEditingController(text: dob != null ? dob.toString().split('T').first : '');
    
    _aboutController = TextEditingController(text: d['aboutMe'] ?? d['AboutMe'] ?? '');
    
    final gender = d['gender'] ?? d['Gender'];
    if (gender == 'Male' || gender == 'Female') {
      _selectedGender = gender;
    }

    _departmentId = d['departmentId'] ?? d['DepartmentId'] ?? 1;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _aboutController.dispose();
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
      appBar: AppBar(title: const Text('Edit Doctor Profile')),
      body: BlocConsumer<ManageDoctorsCubit, ManageDoctorsState>(
        listener: (context, state) {
          if (state is ManageDoctorsOperationSuccess) {
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
                              ? AssetImage(_imagePath!)
                              : (widget.doctor['imageUrl'] != null
                                  ? NetworkImage('http://clinicbook.runasp.net${widget.doctor['imageUrl']}')
                                  : null) as ImageProvider?,
                          child: _imagePath == null && widget.doctor['imageUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
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
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _departmentId,
                    decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Cardiology')),
                      DropdownMenuItem(value: 2, child: Text('Dermatology')),
                      DropdownMenuItem(value: 3, child: Text('Neurology')),
                      DropdownMenuItem(value: 4, child: Text('Orthopedics')),
                      DropdownMenuItem(value: 5, child: Text('Pediatrics')),
                      DropdownMenuItem(value: 6, child: Text('Psychiatry')),
                      DropdownMenuItem(value: 7, child: Text('Gynecology')),
                    ],
                    onChanged: (val) => setState(() => _departmentId = val),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aboutController,
                    decoration: const InputDecoration(labelText: 'About Me', border: OutlineInputBorder()),
                    maxLines: 3,
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
                          onPressed: state is ManageDoctorsOperationLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final data = {
                                      'FullName': _fullNameController.text,
                                      'PhoneNumber': _phoneController.text,
                                      'Address': _addressController.text,
                                      'Gender': _selectedGender ?? '',
                                      'DateOfBirth': _dobController.text,
                                      'DepartmentId': _departmentId ?? 1,
                                      'AboutMe': _aboutController.text,
                                    };
                                    final doctorId = widget.doctor['id'] ?? widget.doctor['Id'];
                                    context.read<ManageDoctorsCubit>().editDoctor(doctorId, data, _imagePath);
                                  }
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: state is ManageDoctorsOperationLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
