import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../data/models/schudule/cliniceSchedual.dart';

class EditClinicDialog extends StatefulWidget {
  final ClinicModel clinic;
  final Function(ClinicModel) onSave;

  const EditClinicDialog({
    super.key,
    required this.clinic,
    required this.onSave,
  });

  @override
  State<EditClinicDialog> createState() => _EditClinicDialogState();
}

class _EditClinicDialogState extends State<EditClinicDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clinic.name);
    _addressController = TextEditingController(text: widget.clinic.address);
    _phoneController = TextEditingController(text: widget.clinic.phoneNumber);
    _priceController = TextEditingController(
      text: widget.clinic.consultationPrice.toString(),
    );
    _durationController = TextEditingController(
      text: widget.clinic.appointmentDuration,
    );
    _notesController = TextEditingController(text: widget.clinic.nots);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        "Edit Clinic",
        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              _nameController,
              "Name",
              Icons.local_hospital_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressController,
              "Address",
              Icons.location_on_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, "Phone", Icons.phone_rounded),
            const SizedBox(height: 16),
            _buildTextField(
              _priceController,
              "Price",
              Icons.payments_rounded,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _durationController,
              "Duration (min)",
              Icons.timer_rounded,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(_notesController, "Notes", Icons.note_rounded),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: GoogleFonts.lexend(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty ||
                _addressController.text.trim().isEmpty ||
                _phoneController.text.trim().isEmpty ||
                _priceController.text.trim().isEmpty ||
                _durationController.text.trim().isEmpty ||
                _notesController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            final int? consultationPrice = int.tryParse(_priceController.text.trim());
            if (consultationPrice == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Price must be a valid number.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            final updatedClinic = ClinicModel(
              id: widget.clinic.id,
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              consultationPrice: consultationPrice,
              appointmentDuration: _durationController.text.trim(),
              nots: _notesController.text.trim(),
              schedules: widget.clinic.schedules,
            );
            widget.onSave(updatedClinic);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Save", style: GoogleFonts.lexend(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
