import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../data/repository/shared_pref_controller.dart';
import '../../../../data/api/api_manager.dart';
import '../../../../data/repository/repository.dart';

class DoctorWalletView extends StatefulWidget {
  const DoctorWalletView({super.key});

  @override
  State<DoctorWalletView> createState() => _DoctorWalletViewState();
}

class _DoctorWalletViewState extends State<DoctorWalletView> {
  final SharedPrefController _prefs = SharedPrefController();
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      final api = await ApiManager.create();
      final repo = Repository(api);
      
      // Fetch bookings from API
      final allBookings = await repo.getDoctorAllBookings();
      
      double calculatedBalance = 0.0;
      final List<Map<String, dynamic>> apiTxs = [];
      
      for (final b in allBookings) {
        final status = b.status?.toLowerCase() ?? '';
        final paymentMethod = b.paymentMethod?.toLowerCase() ?? '';
        final isPaid = status.contains('paid') || status.contains('complet') || status.contains('success') || paymentMethod == 'card';
        
        final price = b.price ?? 0.0;
        
        if (isPaid && price > 0) {
          calculatedBalance += price;
          apiTxs.add({
            'appointmentId': b.id,
            'patientName': b.patientName,
            'amount': price,
            'date': b.date ?? b.createdAt ?? DateTime.now().toIso8601String(),
            'isDeposit': true,
          });
        }
      }

      // Read local withdrawals (negative amounts)
      final txStrings = await _prefs.getDoctorWalletTransactions();
      double totalWithdrawn = 0.0;
      final List<Map<String, dynamic>> localTxs = [];
      
      for (final txStr in txStrings) {
        try {
          final decoded = json.decode(txStr);
          if (decoded is Map<String, dynamic>) {
            final amt = (decoded['amount'] as num?)?.toDouble() ?? 0.0;
            if (amt < 0) {
              totalWithdrawn += amt.abs();
              decoded['isDeposit'] = false;
              localTxs.add(decoded);
            }
          }
        } catch (_) {}
      }
      
      double finalBalance = calculatedBalance - totalWithdrawn;
      if (finalBalance < 0) finalBalance = 0.0;

      final List<Map<String, dynamic>> allTxs = [];
      allTxs.addAll(apiTxs);
      allTxs.addAll(localTxs);
      
      // Sort by date descending
      allTxs.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _balance = finalBalance;
        _transactions = allTxs;
        _isLoading = false;
      });
    } catch (e) {
      print('Wallet Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Withdraw Funds',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.headlineText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available Balance: \$${_balance.toStringAsFixed(2)} EGP',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.subtitleText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount (EGP)',
                      labelStyle: GoogleFonts.cairo(fontSize: 14),
                      prefixText: 'EGP ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: ColorManager.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount to withdraw';
                      }
                      final amt = double.tryParse(value.trim());
                      if (amt == null || amt <= 0) {
                        return 'Please enter a valid positive amount';
                      }
                      if (amt > _balance) {
                        return 'Insufficient balance in wallet';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final toWithdraw = double.parse(amountController.text.trim());
                      
                      Navigator.pop(context);
                      
                      // Process locally using doctorId as unique key
                      await _prefs.addToDoctorWalletBalance(-toWithdraw);
                      await _prefs.addDoctorWalletTransaction(
                        appointmentId: DateTime.now().millisecondsSinceEpoch,
                        patientName: 'Withdrawal to Bank Account',
                        amount: -toWithdraw,
                        date: DateTime.now().toIso8601String(),
                      );
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Successfully requested withdrawal of \$${toWithdraw.toStringAsFixed(2)} EGP'),
                            backgroundColor: ColorManager.primary,
                          ),
                        );
                        _loadWalletData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Request Withdrawal',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorManager.headlineText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wallet',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorManager.headlineText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ColorManager.primary),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- WALLET BALANCE CARD ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Color(0xFF1E293B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
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
                              Text(
                                'TOTAL BALANCE',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${_balance.toStringAsFixed(2)} EGP',
                            style: GoogleFonts.cairo(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _balance > 0 ? _showWithdrawDialog : null,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white30),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Withdraw Funds',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _balance > 0 ? Colors.white : Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- TRANSACTION HISTORY TITLE ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.headlineText,
                          ),
                        ),
                        if (_transactions.isNotEmpty)
                          Text(
                            '${_transactions.length} items',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: ColorManager.subtitleText,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- TRANSACTION LIST ---
                    _transactions.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: ColorManager.borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 48,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Transactions Yet',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.headlineText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Payments made by patients via card will be displayed here.',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: ColorManager.subtitleText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tx = _transactions[index];
                              final patientName = tx['patientName'] ?? 'Patient';
                              final double amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                              final dateStr = tx['date'] ?? '';
                              
                              DateTime? parsedDate = DateTime.tryParse(dateStr);
                              String formattedDate = dateStr;
                              if (parsedDate != null) {
                                formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate);
                              }

                              final isDeposit = amount > 0;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: ColorManager.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDeposit
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFEBEE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isDeposit
                                            ? Icons.arrow_downward_rounded
                                            : Icons.arrow_upward_rounded,
                                        color: isDeposit
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patientName,
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: ColorManager.headlineText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedDate,
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: ColorManager.subtitleText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isDeposit ? '+' : ''}\$${amount.toStringAsFixed(2)} EGP',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDeposit ? Colors.green[700] : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
