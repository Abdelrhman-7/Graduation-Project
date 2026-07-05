import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../data/models/schudule/cliniceSchedual.dart';

class ClinicListItem extends StatelessWidget {
  final ClinicModel clinic;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const ClinicListItem({
    super.key,
    required this.clinic,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    clinic.name,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: ColorManager.primary,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.location_on_outlined, text: clinic.address),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.phone_outlined, text: clinic.phoneNumber),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: (clinic.schedules != null && clinic.schedules!.isNotEmpty)
                  ? "${clinic.schedules![0]['startTime'] ?? clinic.schedules![0]['StartTime'] ?? ''} - ${clinic.schedules![0]['endTime'] ?? clinic.schedules![0]['EndTime'] ?? ''}"
                  : "Duration: ${clinic.appointmentDuration} mins",
            ),
            if (clinic.nots.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.note_alt_outlined,
                text: "Notes: ${clinic.nots}",
              ),
            ],
            if (clinic.schedules != null && clinic.schedules!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 16, color: Color(0xFFE2E8F0)),
              Text(
                "Schedules / Working Hours:",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              ...clinic.schedules!.map((s) {
                final day = s['dayOfWeek'] ?? s['day'] ?? s['DayOfWeek'] ?? '';
                final start = s['startTime'] ?? s['StartTime'] ?? '';
                final end = s['endTime'] ?? s['EndTime'] ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: ColorManager.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$day: $start - $end",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${clinic.consultationPrice} EGP",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
