import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_formatters.dart';

class PaymentCardFields extends StatelessWidget {
  final TextEditingController cardHolderController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final bool isProcessing;
  final Function(bool) onCvvFocusChange;

  const PaymentCardFields({
    super.key,
    required this.cardHolderController,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.isProcessing,
    required this.onCvvFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Holder Name (Added)
          _buildField(
            label: 'Card Holder Name',
            hint: 'JOHN DOE',
            controller: cardHolderController,
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            enabled: !isProcessing,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter card holder name';
              }
              if (v.trim().length < 3) {
                return 'Name is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Card Number
          _buildField(
            label: 'Card Number',
            hint: '4242 4242 4242 4242',
            controller: cardNumberController,
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberFormatter(),
            ],
            enabled: !isProcessing,
            validator: (v) {
              final digits = (v ?? '').replaceAll(' ', '');
              if (digits.length < 13) return 'Invalid card number';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Expiry + CVV Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  controller: expiryController,
                  icon: Icons.calendar_month_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryFormatter(),
                  ],
                  enabled: !isProcessing,
                  validator: (v) {
                    if (v == null || v.trim().length < 5) {
                      return 'Invalid date';
                    }
                    final parts = v.split('/');
                    final m = int.tryParse(parts[0]) ?? 0;
                    final y = int.tryParse(parts[1]) ?? 0;
                    if (m < 1 || m > 12) return 'Invalid month';
                    
                    final now = DateTime.now();
                    final currentYear = now.year % 100;
                    final currentMonth = now.month;
                    
                    if (y < currentYear || (y == currentYear && m < currentMonth)) {
                      return 'Card expired';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Focus(
                  onFocusChange: onCvvFocusChange,
                  child: _buildField(
                    label: 'CVV',
                    hint: '•••',
                    controller: cvvController,
                    icon: Icons.lock_rounded,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    enabled: !isProcessing,
                    validator: (v) {
                      if (v == null || v.length < 3) return 'Invalid CVV';
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.sourceCodePro(
            fontSize: 15,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.sourceCodePro(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF475569), size: 18),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF137FEC),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}
