import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/notification/patient_notification_model.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/presentation/patient_booking/cubit/patient_booking_cubit.dart';
import 'package:graduationproject/presentation/patient_booking/view/payment_card_view.dart';
import '../../../../core/resources/color_manager.dart';

// ─── Bottom sheet entry point ──────────────────────────────────────────────
Future<void> showPatientNotificationsSheet(BuildContext context) async {
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.45,
      builder: (_, __) => _NotificationsSheetContent(
        repository: context.read<Repository>(),
      ),
    ),
  );
}

// ─── Sheet content widget (StatefulWidget to manage list state) ────────────
class _NotificationsSheetContent extends StatefulWidget {
  final Repository repository;
  const _NotificationsSheetContent({required this.repository});

  @override
  State<_NotificationsSheetContent> createState() =>
      _NotificationsSheetContentState();
}

class _NotificationsSheetContentState
    extends State<_NotificationsSheetContent> {
  List<PatientNotificationModel> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await widget.repository.getPatientNotifications();
      final parsed = raw
          .whereType<Map<String, dynamic>>()
          .map((e) => PatientNotificationModel.fromJson(e))
          .toList();
      setState(() {
        _notifications = parsed;
        _loading = false;
      });
      // Mark all notifications read locally/API-wise
      await widget.repository.markPatientNotificationsRead();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _discard(PatientNotificationModel n) async {
    final ok = await widget.repository.discardPatientNotification(n.id);
    if (ok && mounted) {
      setState(() => _notifications.removeWhere((x) => x.id == n.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  if (!_loading)
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadNotifications,
                      tooltip: 'Refresh',
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          if (!_loading && _error == null)
            Text(
              '${_notifications.length} notification(s)',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: ColorManager.subtitleText,
              ),
            ),
          const SizedBox(height: 16),

          // Body
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManager.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Could not load notifications',
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final n = _notifications[index];
        return _NotificationItem(
          notification: n,
          onDiscard: () => _discard(n),
          repository: widget.repository,
        );
      },
    );
  }
}

// ─── Single notification tile ──────────────────────────────────────────────
class _NotificationItem extends StatelessWidget {
  final PatientNotificationModel notification;
  final VoidCallback onDiscard;
  final Repository repository;

  const _NotificationItem({
    required this.notification,
    required this.onDiscard,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;

    // Determine colour/icon by content
    Color color;
    Color bg;
    IconData icon;

    if (n.isApproved) {
      color = const Color(0xFF059669);
      bg = const Color(0xFFD1FAE5);
      icon = Icons.check_circle_rounded;
    } else if (n.isRejected) {
      color = const Color(0xFFDC2626);
      bg = const Color(0xFFFEE2E2);
      icon = Icons.cancel_rounded;
    } else {
      color = const Color(0xFF2563EB);
      bg = const Color(0xFFEFF6FF);
      icon = Icons.notifications_rounded;
    }

    final title = n.title ??
        (n.isApproved
            ? 'Booking Approved'
            : n.isRejected
                ? 'Booking Rejected'
                : 'Notification');

    final subtitle = n.message ??
        [
          if (n.doctorName != null) 'Dr. ${n.doctorName}',
          if (n.clinicName != null) n.clinicName!,
        ].join(' — ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
              if (n.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(n.createdAt!),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: ColorManager.subtitleText,
                  ),
                ),
              ],
              // ── زر Pay Now يظهر فقط لما الحجز مقبول وعندنا appointmentId ──
              if (n.isApproved && n.appointmentId != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final cubit = PatientBookingCubit(repository);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentCardView(
                            appointmentId: n.appointmentId!,
                            amount: 0,
                            doctorName: n.doctorName ?? '',
                            clinicName: n.clinicName ?? '',
                            cubit: cubit,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: Text(
                      'Pay Now',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Discard button
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          color: Colors.grey.shade400,
          tooltip: 'Discard',
          onPressed: onDiscard,
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
