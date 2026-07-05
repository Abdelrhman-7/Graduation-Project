import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/resources/color_manager.dart';

class CustomChangePasswordDialog extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final Function(String currentPass, String newPass, String confirmPass) onSubmit;

  const CustomChangePasswordDialog({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<CustomChangePasswordDialog> createState() => _CustomChangePasswordDialogState();
}

class _CustomChangePasswordDialogState extends State<CustomChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Subtitle
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: ColorManager.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Change Password',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.headlineText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new password to keep your account secure.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: ColorManager.subtitleText,
                  ),
                ),
                const SizedBox(height: 24),

                // Current Password Field
                _buildField(
                  controller: _currentPasswordController,
                  labelText: 'Current Password',
                  obscureText: _obscureCurrent,
                  onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New Password Field
                _buildField(
                  controller: _newPasswordController,
                  labelText: 'New Password',
                  obscureText: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                _buildField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm New Password',
                  obscureText: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isLoading ? null : widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  widget.onSubmit(
                                    _currentPasswordController.text,
                                    _newPasswordController.text,
                                    _confirmPasswordController.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Change',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14, color: ColorManager.headlineText),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: ColorManager.subtitleText),
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: ColorManager.subtitleText),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: ColorManager.subtitleText,
          ),
          onPressed: onToggleObscure,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorManager.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}
