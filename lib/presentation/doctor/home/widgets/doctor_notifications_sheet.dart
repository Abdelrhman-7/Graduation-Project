import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/notification/doctor_notification_model.dart';
import '../../../../../core/resources/color_manager.dart';
import '../cubit/doctor_home_cubit.dart';
import '../cubit/doctor_home_state.dart';
import 'package:intl/intl.dart';

class DoctorNotificationsSheet extends StatelessWidget {
  final List<DoctorNotificationModel> notifications;
  final int? processingNotificationId;

  const DoctorNotificationsSheet({
    super.key,
    required this.notifications,
    this.processingNotificationId,
  });

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
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${notifications.length} notification(s)',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: ColorManager.subtitleText,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No new notifications',
                          style: GoogleFonts.cairo(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationItem(
                        notification: notification,
                        isProcessing: processingNotificationId == notification.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final DoctorNotificationModel notification;
  final bool isProcessing;

  const _NotificationItem({
    required this.notification,
    required this.isProcessing,
  });

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      String raw = rawDate;
      if (!raw.endsWith('Z')) {
        raw += 'Z';
      }
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMM d, yyyy - h:mm a').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DoctorHomeCubit>();
    final title = notification.title ?? 'Notification';
    final message = notification.message ?? '';

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cubit.discardNotification(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: ColorManager.primary.withOpacity(0.1),
                child: Icon(
                  Icons.notifications_active,
                  color: ColorManager.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isProcessing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              cubit.discardNotification(notification.id);
                            },
                          ),
                      ],
                    ),
                    if (notification.clinicName != null)
                      Text(
                        notification.clinicName!,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: ColorManager.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (message.isNotEmpty)
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _formatDate(notification.createdAt),
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

void showDoctorNotificationsSheet(BuildContext context) {
  final state = context.read<DoctorHomeCubit>().state;
  if (state is! DoctorHomeSuccess) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<DoctorHomeCubit>(),
      child: BlocBuilder<DoctorHomeCubit, DoctorHomeState>(
        builder: (context, state) {
          if (state is DoctorHomeSuccess) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: DoctorNotificationsSheet(
                notifications: state.notifications,
                processingNotificationId: state.processingNotificationId,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

