import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'doctor_profile_view.dart';

class DoctorListView extends StatefulWidget {
  const DoctorListView({super.key});

  @override
  State<DoctorListView> createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<DoctorListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDepartment = 'All Departments';
  bool _isSortedByName = false;

  final List<String> _departments = [
    'All Departments',
    'Orthopedics',
    'Neurology',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Ophthalmology',
    'Dentistry',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedDepartment = 'All Departments';
      _isSortedByName = false;
    });
  }

  // Deterministic fallback avatars
  final List<String> _avatarPool = const [
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=250',
  ];

  String _getDoctorAvatar(DoctorModel doctor) {
    if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
      return doctor.imageUrl!;
    }
    final index = doctor.id % _avatarPool.length;
    return _avatarPool[index];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.15);
        double s(double v) => v * scale;

        return Column(
          children: [
            _buildHeader(context, s),
            _buildFilters(s),
            Expanded(
              child: BlocBuilder<PatientBookingCubit, PatientBookingState>(
                builder: (context, state) {
                  if (state is PatientBookingLoading) {
                    return _buildLoadingState(s);
                  } else if (state is PatientBookingError) {
                    return _buildErrorState(context, state.message, s);
                  } else if (state is PatientBookingDoctorsSuccess) {
                    var doctors = state.doctors.where((doctor) {
                      final nameMatch = doctor.fullName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      
                      final deptMatch = _selectedDepartment == 'All Departments' ||
                          (doctor.departmentName ?? '')
                              .toLowerCase()
                              .contains(_selectedDepartment.toLowerCase());

                      return nameMatch && deptMatch;
                    }).toList();

                    if (_isSortedByName) {
                      doctors.sort((a, b) => a.fullName.compareTo(b.fullName));
                    }

                    if (doctors.isEmpty) {
                      return _buildEmptyState(s);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: s(16),
                        vertical: s(8),
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(doctors[index], scale, s);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double Function(double) s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(s(16), s(16), s(16), s(8)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: EdgeInsets.all(s(8)),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFF0F172A),
                size: s(20),
              ),
            ),
          ),
          SizedBox(width: s(16)),
          Text(
            'Doctor List',
            style: GoogleFonts.lexend(
              fontSize: s(22),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
      child: Column(
        children: [
          // Search Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(s(12)),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.lexend(
                fontSize: s(14),
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                hintStyle: GoogleFonts.lexend(
                  fontSize: s(14),
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF64748B),
                  size: s(20),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFF64748B),
                          size: s(20),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: s(14),
                  horizontal: s(16),
                ),
              ),
            ),
          ),
          SizedBox(height: s(10)),
          Row(
            children: [
              // Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: s(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s(10)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: GoogleFonts.lexend(
                        fontSize: s(13),
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDepartment = newValue;
                          });
                        }
                      },
                      items: _departments
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: s(10)),
              // Reset Button
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.refresh_rounded, size: s(16)),
                label: Text(
                  'Reset',
                  style: GoogleFonts.lexend(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(10)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(12)),
                ),
              ),
            ],
          ),
          SizedBox(height: s(10)),
          // Sort option
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.lexend(
                  fontSize: s(13),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              ChoiceChip(
                label: Text(
                  'Name',
                  style: GoogleFonts.lexend(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                    color: _isSortedByName ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                selected: _isSortedByName,
                onSelected: (bool selected) {
                  setState(() {
                    _isSortedByName = selected;
                  });
                },
                selectedColor: const Color(0xFF137FEC),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(8)),
                ),
                padding: EdgeInsets.symmetric(horizontal: s(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    DoctorModel doctor,
    double scale,
    double Function(double) s,
  ) {
    final doctorAvatar = _getDoctorAvatar(doctor);

    return Container(
      margin: EdgeInsets.only(bottom: s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(20)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(s(16)),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  padding: EdgeInsets.all(s(2)),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF137FEC), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: s(30),
                    backgroundImage: NetworkImage(doctorAvatar),
                    backgroundColor: const Color(0xFFEFF6FF),
                  ),
                ),
                SizedBox(width: s(16)),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: GoogleFonts.lexend(
                          fontSize: s(16),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: s(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: s(14),
                            color: const Color(0xFF137FEC),
                          ),
                          SizedBox(width: s(4)),
                          Text(
                            doctor.departmentName ?? 'General Specialist',
                            style: GoogleFonts.lexend(
                              fontSize: s(13),
                              color: const Color(0xFF137FEC),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: s(6)),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: s(14),
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: s(4)),
                          Text(
                            doctor.gender ?? 'Not Specified',
                            style: GoogleFonts.lexend(
                              fontSize: s(12),
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: s(12)),
                          Icon(
                            Icons.cake_outlined,
                            size: s(14),
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: s(4)),
                          Text(
                            doctor.age != null ? 'Age: ${doctor.age}' : 'Age: N/A',
                            style: GoogleFonts.lexend(
                              fontSize: s(12),
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: s(16)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: s(12)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final cubit = context.read<PatientBookingCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfileView(
                        doctorId: doctor.id,
                        cubit: cubit,
                        scale: scale,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.visibility_rounded, size: s(16), color: Colors.white),
                label: Text(
                  'View Profile',
                  style: GoogleFonts.lexend(
                    fontSize: s(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137FEC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: s(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double Function(double) s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF137FEC),
            strokeWidth: 3,
          ),
          SizedBox(height: s(16)),
          Text(
            'Fetching doctors...',
            style: GoogleFonts.lexend(
              fontSize: s(14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    double Function(double) s,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(s(16)),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: const Color(0xFFEF4444),
                size: s(40),
              ),
            ),
            SizedBox(height: s(16)),
            Text(
              'Failed to load doctors',
              style: GoogleFonts.lexend(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: s(14),
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: s(24)),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PatientBookingCubit>().fetchDoctors();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: s(24),
                  vertical: s(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double Function(double) s) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(s(20)),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                color: const Color(0xFF137FEC),
                size: s(40),
              ),
            ),
            SizedBox(height: s(16)),
            Text(
              'No doctors found',
              style: GoogleFonts.lexend(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              'Try adjusting your search query or department.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: s(14),
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
