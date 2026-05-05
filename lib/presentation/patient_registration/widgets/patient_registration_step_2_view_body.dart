import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientRegistrationStep2ViewBody extends StatefulWidget {
  const PatientRegistrationStep2ViewBody({super.key});

  @override
  State<PatientRegistrationStep2ViewBody> createState() => _PatientRegistrationStep2ViewBodyState();
}

class _PatientRegistrationStep2ViewBodyState extends State<PatientRegistrationStep2ViewBody> {
  @override
  Widget build(BuildContext context) {
    const Color pageBackground = Color(0xFFF6EFF1);
    const Color primaryBlue = Color(0xFF137FEC);
    const Color titleColor = Color(0xFF0F172A);
    const Color subtitleColor = Color(0xFF64748B);

    return Container(
      color: pageBackground,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 104,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Good Morning,',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                      Text(
                        'Alex',
                        style: GoogleFonts.lexend(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: const [
                        Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A)),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Next Appointment', action: 'See All'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFF1E3A8A),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, color: Colors.white, size: 40),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Tomorrow',
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '10:00 AM',
                                      style: GoogleFonts.lexend(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Dr. Emily Chen',
                                  style: GoogleFonts.lexend(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cardiologist',
                                  style: GoogleFonts.lexend(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFE7EDF3),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Check-in',
                                          style: GoogleFonts.lexend(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Quick Actions'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _ActionItem(icon: Icons.calendar_today_outlined, label: 'Book', color: Color(0xFF137FEC)),
                        _ActionItem(icon: Icons.medication_outlined, label: 'Refill', color: Color(0xFFF97316)),
                        _ActionItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', color: Color(0xFF22C55E)),
                        _ActionItem(icon: Icons.science_outlined, label: 'Labs', color: Color(0xFFA855F7)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Current Medications'),
                    const SizedBox(height: 16),
                    const _MedicationItem(
                      icon: Icons.medication_outlined,
                      title: 'Amoxicillin',
                      subtitle: '500mg • 1 pill/day',
                      tag: 'ACTIVE',
                      tagColor: Color(0xFF16A34A),
                      tagBackground: Color(0xFFDCFCE7),
                    ),
                    const SizedBox(height: 12),
                    const _MedicationItem(
                      icon: Icons.assignment_outlined,
                      title: 'Lisinopril',
                      subtitle: '10mg • 1 pill/day',
                      tag: 'REFILL',
                      tagColor: Color(0xFF2563EB),
                      tagBackground: Color(0xFFDBEAFE),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const _MiniStat(icon: Icons.favorite_border, label: 'Heart Rate', value: '72', unit: 'bpm', iconColor: Color(0xFFEF4444)),
                          Container(width: 1, height: 32, color: const Color(0xFFCBD5E1)),
                          const _MiniStat(icon: Icons.water_drop_outlined, label: 'Blood Type', value: 'O+', unit: '', iconColor: Color(0xFF3B82F6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 92,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(icon: Icons.home_outlined, label: 'Home', selected: true),
                  _NavItem(icon: Icons.calendar_month_outlined, label: 'Schedule'),
                  _NavItem(icon: Icons.favorite_border, label: 'My Health'),
                  _NavItem(icon: Icons.person_outline, label: 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionTitle(title),
        Text(
          action,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF137FEC),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
        height: 1,
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.5,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationItem extends StatelessWidget {
  const _MedicationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagBackground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF137FEC), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF137FEC);
    final Color inactiveColor = const Color(0xFF94A3B8);
    final Color itemColor = selected ? activeColor : inactiveColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: itemColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: itemColor,
          ),
        ),
      ],
    );
  }
}
