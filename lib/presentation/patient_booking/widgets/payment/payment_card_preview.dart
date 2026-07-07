import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class PaymentCardPreview extends StatelessWidget {
  final Animation<double> flipAnimation;
  final ValueListenable<String> cardNumberListenable;
  final ValueListenable<String> cardHolderListenable;
  final ValueListenable<String> expiryListenable;
  final ValueListenable<String> cvvListenable;

  const PaymentCardPreview({
    super.key,
    required this.flipAnimation,
    required this.cardNumberListenable,
    required this.cardHolderListenable,
    required this.expiryListenable,
    required this.cvvListenable,
  });

  String _getMaskedNumber(String number) {
    final raw = number.replaceAll(' ', '');
    if (raw.length < 4) return '•••• •••• •••• ••••';
    final last4 = raw.substring(raw.length > 4 ? raw.length - 4 : 0);
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final isBack = flipAnimation.value > 0.5;
        final rotateY = flipAnimation.value * 3.14159;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotateY),
          child: isBack ? _buildCardBack() : _buildCardFront(),
        );
      },
    );
  }

  Widget _buildCardFront() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF7C3AED),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless_rounded,
                  color: Colors.white70, size: 28),
              Text(
                'CLINICBOOK',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          ValueListenableBuilder<String>(
            valueListenable: cardNumberListenable,
            builder: (context, cardNumber, child) {
              return Text(
                _getMaskedNumber(cardNumber),
                style: GoogleFonts.sourceCodePro(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: GoogleFonts.cairo(
                          fontSize: 9, color: Colors.white54),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: cardHolderListenable,
                      builder: (context, holder, child) {
                        return Text(
                          holder.isEmpty
                              ? 'YOUR NAME'
                              : holder.toUpperCase().substring(
                                  0,
                                  holder.length > 20 ? 20 : holder.length),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style:
                        GoogleFonts.cairo(fontSize: 9, color: Colors.white54),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: expiryListenable,
                    builder: (context, expiry, child) {
                      return Text(
                        expiry.isEmpty ? 'MM/YY' : expiry,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF374151), Color(0xFF1F2937)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 28),
            Container(height: 44, color: const Color(0xFF111827)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 38,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: ValueListenableBuilder<String>(
                      valueListenable: cvvListenable,
                      builder: (context, cvv, child) {
                        return Text(
                          cvv.isEmpty ? 'CVV' : '•' * cvv.length,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
