import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../data/models/schudule/creatSchudel.dart';
import '../cubit/creat_schedule_cubit.dart';
import '../cubit/creat_schedule_state.dart';
import 'creat_schedule_form.dart';
import 'creat_schedule_header.dart';

class ManageScheduleScreen extends StatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MySchedulesTab(tabController: _tabController),
              _AddScheduleTab(tabController: _tabController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            'Manage Schedules',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorManager.primary,
        unselectedLabelColor: const Color(0xFF94A3B8),
        indicatorColor: ColorManager.primary,
        indicatorWeight: 3,
        labelStyle:
            GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(icon: Icon(Icons.calendar_month_rounded), text: 'My Schedules'),
          Tab(icon: Icon(Icons.add_circle_outline_rounded), text: 'Add New'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1: My Schedules
// ─────────────────────────────────────────────────────────────
class _MySchedulesTab extends StatelessWidget {
  final TabController tabController;
  const _MySchedulesTab({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateScheduleCubit, CreateScheduleState>(
      listener: (context, state) {
        if (state is CreateScheduleDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is CreateScheduleEditSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule updated successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is CreateScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CreateScheduleLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorManager.primary),
          );
        }

        final schedules =
            context.read<CreateScheduleCubit>().allSchedules;

        if (schedules.isEmpty) {
          return _buildEmptyState(context);
        }

        return Stack(
          children: [
            ListView.builder(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final s = schedules[index] as Map;
                return _ScheduleCard(
                  schedule: s,
                  onEdit: () => _showEditDialog(context, s),
                  onDelete: () => _confirmDelete(context, s),
                );
              },
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                heroTag: 'add_schedule_fab',
                onPressed: () => tabController.animateTo(1),
                backgroundColor: ColorManager.primary,
                elevation: 4,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'Add Schedule',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No schedules yet',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add your first schedule',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'add_schedule_fab_empty',
            onPressed: () => tabController.animateTo(1),
            backgroundColor: ColorManager.primary,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Add Schedule',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Map schedule) {
    final id = schedule['id'] ?? schedule['Id'];
    final clinicId = (schedule['clinicId'] ?? schedule['ClinicId'] ??
            schedule['_clinicId'])
        ?.toString();
    final day =
        schedule['dayOfWeek'] ?? schedule['DayOfWeek'] ?? schedule['day'] ?? '';
    final start =
        schedule['startTime'] ?? schedule['StartTime'] ?? '';
    final end = schedule['endTime'] ?? schedule['EndTime'] ?? '';

    showDialog(
      context: context,
      builder: (_) => _EditScheduleDialog(
        scheduleId: id is int ? id : int.tryParse(id.toString()),
        clinicId: clinicId ?? '',
        initialDay: day.toString(),
        initialStart: start.toString(),
        initialEnd: end.toString(),
        onSave: (editModel) =>
            context.read<CreateScheduleCubit>().editScheduleEntry(editModel),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map schedule) {
    final id = schedule['id'] ?? schedule['Id'];
    final scheduleId = id is int ? id : int.tryParse(id.toString());
    if (scheduleId == null) return;

    final day =
        schedule['dayOfWeek'] ?? schedule['DayOfWeek'] ?? schedule['day'] ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Schedule',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete the "$day" schedule? This cannot be undone.',
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                Text('Cancel', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CreateScheduleCubit>().deleteSchedule(scheduleId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete',
                style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Schedule Card Widget
// ─────────────────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  final Map schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(String rawTime) {
    if (rawTime == '--:--') return rawTime;
    try {
      final dt = DateFormat('HH:mm:ss').parse(rawTime);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      try {
        final dt = DateFormat('HH:mm').parse(rawTime);
        return DateFormat('hh:mm a').format(dt);
      } catch (_) {
        return rawTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = schedule['dayOfWeek'] ??
        schedule['DayOfWeek'] ??
        schedule['day'] ??
        'Unknown Day';
    final start = _formatTime(schedule['startTime'] ?? schedule['StartTime'] ?? '--:--');
    final end = _formatTime(schedule['endTime'] ?? schedule['EndTime'] ?? '--:--');
    final clinicName = schedule['_clinicName'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day icon box
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: ColorManager.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '$start – $end',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (clinicName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_hospital_outlined,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinicName,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: ColorManager.primary, size: 20),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Edit Schedule Dialog
// ─────────────────────────────────────────────────────────────
class _EditScheduleDialog extends StatefulWidget {
  final int? scheduleId;
  final String clinicId;
  final String initialDay;
  final String initialStart;
  final String initialEnd;
  final Function(editClinicModel) onSave;

  const _EditScheduleDialog({
    required this.scheduleId,
    required this.clinicId,
    required this.initialDay,
    required this.initialStart,
    required this.initialEnd,
    required this.onSave,
  });

  @override
  State<_EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<_EditScheduleDialog> {
  static const List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  late String _selectedDay;
  late TextEditingController _startController;
  late TextEditingController _endController;

  String _to12Hour(String text) {
    try {
      final dt = DateFormat('HH:mm:ss').parse(text);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      try {
        final dt = DateFormat('HH:mm').parse(text);
        return DateFormat('hh:mm a').format(dt);
      } catch (_) {
        return text;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _days.contains(widget.initialDay)
        ? widget.initialDay
        : _days.first;
    _startController = TextEditingController(text: _to12Hour(widget.initialStart));
    _endController = TextEditingController(text: _to12Hour(widget.initialEnd));
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    TimeOfDay initial;
    try {
      final dt = DateFormat('hh:mm a').parse(ctrl.text);
      initial = TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      try {
        final dt = DateFormat('HH:mm').parse(ctrl.text);
        initial = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {
        initial = const TimeOfDay(hour: 9, minute: 0);
      }
    }
    
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final dt = DateTime(2000, 1, 1, picked.hour, picked.minute);
        ctrl.text = DateFormat('hh:mm a').format(dt);
      });
    }
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Edit Schedule',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Day of Week',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: _dec('Day', Icons.calendar_today_rounded),
              items: _days
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDay = v ?? _days.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startController,
              readOnly: true,
              onTap: () => _pickTime(_startController),
              decoration: _dec('Start Time', Icons.access_time_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endController,
              readOnly: true,
              onTap: () => _pickTime(_endController),
              decoration:
                  _dec('End Time', Icons.access_time_filled_rounded),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.cairo(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            String to24Hour(String text) {
              try {
                final dt = DateFormat('hh:mm a').parse(text);
                return DateFormat('HH:mm').format(dt);
              } catch (_) {
                return text;
              }
            }
            
            final model = editClinicModel(
              id: widget.scheduleId,
              clinicId: widget.clinicId,
              day: _selectedDay,
              startTime: to24Hour(_startController.text),
              endTime: to24Hour(_endController.text),
            );
            widget.onSave(model);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Save', style: GoogleFonts.cairo(color: Colors.white)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2: Add Schedule
// ─────────────────────────────────────────────────────────────
class _AddScheduleTab extends StatefulWidget {
  final TabController tabController;
  const _AddScheduleTab({required this.tabController});

  @override
  State<_AddScheduleTab> createState() => _AddScheduleTabState();
}

class _AddScheduleTabState extends State<_AddScheduleTab> {
  static const List<String> _days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  String _selectedDay = 'Sunday';
  int? _selectedClinicId;
  final TextEditingController _startTimeController =
      TextEditingController(text: '09:00 AM');
  final TextEditingController _endTimeController =
      TextEditingController(text: '05:00 PM');

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateScheduleCubit, CreateScheduleState>(
      listener: (context, state) {
        if (state is CreateScheduleAddSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule added successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Switch back to My Schedules tab
          widget.tabController.animateTo(0);
        } else if (state is CreateScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final clinics = context.read<CreateScheduleCubit>().clinics;

        if (state is CreateScheduleLoading && clinics.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ColorManager.primary),
          );
        }

        if (_selectedClinicId == null && clinics.isNotEmpty) {
          _selectedClinicId = clinics.first.id;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateScheduleHeader(),
              const SizedBox(height: 32),
              CreateScheduleForm(
                clinics: clinics,
                isLoading: state is CreateScheduleLoading,
                selectedDay: _selectedDay,
                selectedClinicId: _selectedClinicId,
                days: _days,
                startTimeController: _startTimeController,
                endTimeController: _endTimeController,
                onDayChanged: (v) => setState(() => _selectedDay = v!),
                onClinicChanged: (v) => setState(() => _selectedClinicId = v),
                onSubmit: _submitForm,
                onTapStartTime: () => _selectTime(_startTimeController),
                onTapEndTime: () => _selectTime(_endTimeController),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initial;
    try {
      final dt = DateFormat('hh:mm a').parse(controller.text);
      initial = TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      initial = const TimeOfDay(hour: 9, minute: 0);
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final dt = DateTime(2000, 1, 1, picked.hour, picked.minute);
        controller.text = DateFormat('hh:mm a').format(dt);
      });
    }
  }

  void _submitForm() {
    if (_selectedClinicId == null) return;
    
    int getMinutes(String text) {
      try {
        final dt = DateFormat('hh:mm a').parse(text);
        return dt.hour * 60 + dt.minute;
      } catch (_) {
        return 0;
      }
    }
    
    final startTotal = getMinutes(_startTimeController.text);
    final endTotal = getMinutes(_endTimeController.text);
    
    if (startTotal >= endTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time must be before end time!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String to24Hour(String text) {
      try {
        final dt = DateFormat('hh:mm a').parse(text);
        return DateFormat('HH:mm').format(dt);
      } catch (_) {
        return text;
      }
    }

    context.read<CreateScheduleCubit>().addSchedule(
          day: _selectedDay,
          startTime: to24Hour(_startTimeController.text),
          endTime: to24Hour(_endTimeController.text),
          clinicId: _selectedClinicId!,
        );
  }
}
