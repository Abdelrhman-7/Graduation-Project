import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../data/repository/shared_pref_controller.dart';
import 'package:intl/intl.dart';

Future<void> showHealthMetricsHistorySheet(BuildContext context) async {
  final prefs = SharedPrefController();
  final historyRaw = await prefs.getHealthMetricsHistory();
  
  final history = historyRaw.map((e) {
    try {
      return jsonDecode(e) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }).where((e) => e.isNotEmpty).toList();

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: _HealthMetricsHistorySheet(history: history),
    ),
  );
}

class _HealthMetricsHistorySheet extends StatelessWidget {
  const _HealthMetricsHistorySheet({required this.history});
  final List<Map<String, dynamic>> history;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 390).clamp(0.88, 1.15);
    double s(double v) => v * scale;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          'History Records: ${history.length}',
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDragHandle(double Function(double) s) {
    return Container(
      margin: EdgeInsets.only(top: s(12), bottom: s(8)),
      width: s(40),
      height: s(4),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(s(2)),
      ),
    );
  }

  Widget _buildHeader(double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'History',
            style: GoogleFonts.cairo(
              fontSize: s(20),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(6)),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(s(999)),
            ),
            child: Text(
              '${history.length} records',
              style: GoogleFonts.cairo(
                fontSize: s(12),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double Function(double) s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: s(64), color: const Color(0xFFCBD5E1)),
          SizedBox(height: s(16)),
          Text(
            'No History Yet',
            style: GoogleFonts.cairo(
              fontSize: s(16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: s(8)),
          Text(
            'Your saved health metrics will appear here.',
            style: GoogleFonts.cairo(
              fontSize: s(14),
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(double Function(double) s, Map<String, dynamic> item) {
    String formattedDate = 'Unknown Date';
    String formattedTime = '';
    try {
      if (item['timestamp'] != null) {
        final dt = DateTime.parse(item['timestamp'].toString());
        formattedDate = DateFormat('MMM dd, yyyy').format(dt);
        formattedTime = DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {}

    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: s(14), color: ColorManager.primary),
                  SizedBox(width: s(6)),
                  Text(
                    formattedDate,
                    style: GoogleFonts.cairo(
                      fontSize: s(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                formattedTime,
                style: GoogleFonts.cairo(
                  fontSize: s(12),
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: s(16)),
          
          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(s, 'Heart Rate', '${item['heartRate'] ?? '-'} bpm', Icons.favorite_border_rounded, Colors.red),
              ),
              Expanded(
                child: _buildMetricItem(s, 'Blood Press.', '${item['bloodPressure'] ?? '-'}', Icons.monitor_heart_rounded, Colors.blue),
              ),
            ],
          ),
          SizedBox(height: s(12)),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(s, 'Blood Sugar', '${item['bloodSugar'] ?? '-'} mg/dL', Icons.water_drop_outlined, Colors.purple),
              ),
              Expanded(
                child: _buildMetricItem(s, 'Weight', '${item['weight'] ?? '-'} kg', Icons.monitor_weight_outlined, Colors.orange),
              ),
            ],
          ),
          
          // Notes section
          if (item['notes'] != null && item['notes'].toString().isNotEmpty) ...[
            SizedBox(height: s(16)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(s(12)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(s(8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: s(16), color: const Color(0xFF94A3B8)),
                  SizedBox(width: s(8)),
                  Expanded(
                    child: Text(
                      item['notes'].toString(),
                      style: GoogleFonts.cairo(
                        fontSize: s(13),
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(double Function(double) s, String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(s(6)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          child: Icon(icon, size: s(14), color: color),
        ),
        SizedBox(width: s(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: s(11),
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: s(13),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
