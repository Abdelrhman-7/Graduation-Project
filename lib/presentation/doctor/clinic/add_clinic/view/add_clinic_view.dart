import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/color_manager.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';
import '../cubit/add_clinic_cubit.dart';
import '../cubit/add_clinic_state.dart';

class AddClinicView extends StatelessWidget {
  const AddClinicView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddClinicCubit(ClinicRepository(context.read<ApiManager>())),
      child: const AddClinicViewBody(),
    );
  }
}

class AddClinicViewBody extends StatefulWidget {
  const AddClinicViewBody({super.key});

  @override
  State<AddClinicViewBody> createState() => _AddClinicViewBodyState();
}

class _AddClinicViewBodyState extends State<AddClinicViewBody> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _appointmentDurationController = TextEditingController();
  final _notsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _appointmentDurationController.dispose();
    _notsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Clinic',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AddClinicCubit, AddClinicState>(
        listener: (context, state) {
          if (state is AddClinicSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clinic added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AddClinicError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Clinic Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g., Hope Medical Center',
                  icon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Clinic Address'),
                _buildTextField(
                  controller: _addressController,
                  hint: 'e.g., 123 Main St, Cityville',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Phone Number'),
                _buildTextField(
                  controller: _phoneController,
                  hint: 'e.g., +1 234 567 8900',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Consultation Price (EGP)'),
                _buildTextField(
                  controller: _priceController,
                  hint: 'e.g., 500',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Appointment Duration'),
                _buildTextField(
                  controller: _appointmentDurationController,
                  hint: 'Appointment Duration',
                  icon: Icons.timer,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Nots'),
                _buildTextField(
                  controller: _notsController,
                  hint: 'Nots',
                  icon: Icons.book,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is AddClinicLoading
                        ? null
                        : () {
                            context.read<AddClinicCubit>().addClinic(
                              name: _nameController.text.trim(),
                              address: _addressController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              consultationPriceStr: _priceController.text
                                  .trim(),
                              appointmentDuration:
                                  _appointmentDurationController.text.trim(),
                              nots: _notsController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: state is AddClinicLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Clinic',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.lexend(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(
            fontSize: 15,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
