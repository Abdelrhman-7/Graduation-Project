import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';

import '../widgets/payment/payment_summary_badge.dart';
import '../widgets/payment/payment_card_preview.dart';
import '../widgets/payment/payment_card_fields.dart';
import '../widgets/payment/payment_pay_button.dart';
import '../widgets/payment/payment_success_view.dart';

/// شاشة إدخال بيانات البطاقة الائتمانية ودفع قيمة الحجز
class PaymentCardView extends StatefulWidget {
  final int appointmentId;
  final double amount;
  final String doctorName;
  final String clinicName;
  final int doctorId; // معرف الدكتور الفريد للمحفظة
  final PatientBookingCubit cubit;

  const PaymentCardView({
    super.key,
    required this.appointmentId,
    required this.amount,
    required this.doctorName,
    required this.clinicName,
    required this.doctorId,
    required this.cubit,
  });

  @override
  State<PaymentCardView> createState() => _PaymentCardViewState();
}

class _PaymentCardViewState extends State<PaymentCardView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _cardHolderController = TextEditingController(text: 'Abdo');
  final _cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/34'); // MM/YY
  final _cvvController = TextEditingController(text: '567');

  final ValueNotifier<String> _cardNumberNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _cardHolderNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _expiryNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _cvvNotifier = ValueNotifier<String>('');

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  double _resolvedAmount = 0;

  @override
  void initState() {
    super.initState();
    _resolvedAmount = widget.amount;
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _cardNumberController.addListener(
      () => _cardNumberNotifier.value = _cardNumberController.text,
    );
    _cardHolderController.addListener(
      () => _cardHolderNotifier.value = _cardHolderController.text,
    );
    _expiryController.addListener(
      () => _expiryNotifier.value = _expiryController.text,
    );
    _cvvController.addListener(() => _cvvNotifier.value = _cvvController.text);

    if (_resolvedAmount == 0 && widget.appointmentId > 0) {
      _fetchAmountFromApi();
    }
  }

  Future<void> _fetchAmountFromApi() async {
    double? extractFee(Map<String, dynamic>? map) {
      if (map == null) return null;
      final fee =
          map['consultationPrice'] ??
          map['ConsultationPrice'] ??
          map['price'] ??
          map['Price'] ??
          map['fee'] ??
          map['Fee'] ??
          map['amount'] ??
          map['Amount'] ??
          map['consultationFee'] ??
          map['ConsultationFee'] ??
          map['clinic']?['consultationPrice'] ??
          map['clinic']?['ConsultationPrice'] ??
          map['clinic']?['price'] ??
          map['Clinic']?['consultationPrice'] ??
          map['Clinic']?['price'] ??
          map['schedule']?['consultationPrice'] ??
          map['schedule']?['price'] ??
          map['doctor']?['consultationPrice'] ??
          map['doctor']?['price'];
      if (fee == null) return null;
      final parsed = (fee is num)
          ? fee.toDouble()
          : double.tryParse(fee.toString());
      return (parsed != null && parsed > 0) ? parsed : null;
    }

    try {
      final summary = await widget.cubit.repository.getAppointmentSummary(
        widget.appointmentId,
      );
      final fromSummary = extractFee(summary);
      if (fromSummary != null && mounted) {
        setState(() => _resolvedAmount = fromSummary);
        return;
      }
    } catch (_) {}

    try {
      final details = await widget.cubit.repository.apiManager
          .getPatientHistoryAppointmentDetails(widget.appointmentId);
      final fromDetails = extractFee(details);
      if (fromDetails != null && mounted) {
        setState(() => _resolvedAmount = fromDetails);
        return;
      }
    } catch (_) {}

    try {
      final list = await widget.cubit.repository.apiManager
          .getPatientAppointments();
      for (final appt in list) {
        if (appt is Map<String, dynamic>) {
          final id = appt['id'] ?? appt['appointmentId'] ?? appt['bookingId'];
          final apptId = id is int ? id : int.tryParse(id?.toString() ?? '');
          if (apptId == widget.appointmentId) {
            final fromList = extractFee(appt);
            if (fromList != null && mounted) {
              setState(() => _resolvedAmount = fromList);
              return;
            }
          }
        }
      }
    } catch (_) {}

    try {
      if (widget.clinicName.isNotEmpty || widget.doctorName.isNotEmpty) {
        final clinics = await widget.cubit.repository.getPatientAllClinics();
        for (final clinic in clinics) {
          final clinicNameMatch =
              widget.clinicName.isNotEmpty &&
              clinic.name.toLowerCase().trim() ==
                  widget.clinicName.toLowerCase().trim();
          final doctorNameMatch =
              widget.doctorName.isNotEmpty &&
              clinic.doctorName != null &&
              (clinic.doctorName!.toLowerCase().contains(
                    widget.doctorName.toLowerCase(),
                  ) ||
                  widget.doctorName.toLowerCase().contains(
                    clinic.doctorName!.toLowerCase(),
                  ));

          if (clinicNameMatch || doctorNameMatch) {
            if (mounted && clinic.consultationPrice > 0) {
              setState(
                () => _resolvedAmount = clinic.consultationPrice.toDouble(),
              );
              return;
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();

    _cardNumberNotifier.dispose();
    _cardHolderNotifier.dispose();
    _expiryNotifier.dispose();
    _cvvNotifier.dispose();

    _flipController.dispose();
    super.dispose();
  }

  void _onCvvFocus(bool hasFocus) {
    if (hasFocus) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final expiry = _expiryController.text.trim();
    final parts = expiry.split('/');
    final month = parts.isNotEmpty ? parts[0].trim() : '01';
    final yearShort = parts.length > 1 ? parts[1].trim() : '25';
    final year = yearShort.length == 2 ? '20$yearShort' : yearShort;

    widget.cubit.payAppointmentByCard(
      appointmentId: widget.appointmentId,
      amount: _resolvedAmount,
      cardHolderName: _cardHolderController.text.trim(),
      cardNumber: _cardNumberController.text.replaceAll(' ', ''),
      expiryMonth: month,
      expiryYear: year,
      cvv: _cvvController.text.trim(),
      doctorId: widget.doctorId,
    );
  }

  void _showResult(
    BuildContext ctx, {
    required bool success,
    required String message,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: success
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFEF2F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Secure Payment',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.lock_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
          ],
        ),
        body: BlocConsumer<PatientBookingCubit, PatientBookingState>(
          listener: (context, state) {
            if (state is PatientPaymentSuccess) {
              _showResult(context, success: true, message: state.message);
            } else if (state is PatientPaymentError) {
              _showResult(context, success: false, message: state.message);
            }
          },
          builder: (context, state) {
            final isProcessing = state is PatientPaymentProcessing;

            if (state is PatientPaymentSuccess) {
              return PaymentSuccessView(
                message: state.message,
                appointmentId: widget.appointmentId,
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaymentSummaryBadge(
                      doctorName: widget.doctorName,
                      clinicName: widget.clinicName,
                      amount: _resolvedAmount,
                    ),
                    const SizedBox(height: 24),

                    PaymentCardPreview(
                      flipAnimation: _flipAnimation,
                      cardNumberListenable: _cardNumberNotifier,
                      cardHolderListenable: _cardHolderNotifier,
                      expiryListenable: _expiryNotifier,
                      cvvListenable: _cvvNotifier,
                    ),
                    const SizedBox(height: 28),

                    PaymentCardFields(
                      cardHolderController: _cardHolderController,
                      cardNumberController: _cardNumberController,
                      expiryController: _expiryController,
                      cvvController: _cvvController,
                      isProcessing: isProcessing,
                      onCvvFocusChange: _onCvvFocus,
                    ),
                    const SizedBox(height: 28),

                    PaymentPayButton(
                      isProcessing: isProcessing,
                      amount: _resolvedAmount,
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your payment is SSL-encrypted and secure',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
