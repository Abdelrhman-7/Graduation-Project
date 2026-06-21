import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'clinic_schedules_view.dart';

class DoctorClinicsView extends StatefulWidget {
  final DoctorModel doctor;
  final PatientBookingCubit cubit;
  final double scale;

  const DoctorClinicsView({
    super.key,
    required this.doctor,
    required this.cubit,
    required this.scale,
  });

  @override
  State<DoctorClinicsView> createState() => _DoctorClinicsViewState();
}

class _DoctorClinicsViewState extends State<DoctorClinicsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSortedByName = false;

  double s(double v) => v * widget.scale;

  @override
  void initState() {
    super.initState();
    widget.cubit.fetchDoctorClinics(widget.doctor.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSortedByName = false;
    });
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
            icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: s(24)),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Clinic List',
            style: GoogleFonts.lexend(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: s(12)),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.person_rounded, size: s(16), color: const Color(0xFF475569)),
                  label: Text(
                    'Back to Doctor',
                    style: GoogleFonts.lexend(
                      fontSize: s(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(8)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildFilters(),
              Expanded(
                child: BlocBuilder<PatientBookingCubit, PatientBookingState>(
                  builder: (context, state) {
                    if (state is PatientBookingLoading) {
                      return _buildLoadingState();
                    } else if (state is PatientBookingError) {
                      return _buildErrorState(state.message);
                    } else if (state is PatientBookingClinicsSuccess) {
                      var clinics = state.clinics.where((c) {
                        return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.address.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (_isSortedByName) {
                        clinics.sort((a, b) => a.name.compareTo(b.name));
                      }

                      if (clinics.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
                        physics: const BouncingScrollPhysics(),
                        itemCount: clinics.length,
                        itemBuilder: (context, index) {
                          return _buildClinicCard(clinics[index]);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
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
                      fontSize: s(13),
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search clinics...',
                      hintStyle: GoogleFonts.lexend(
                        fontSize: s(13),
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF64748B),
                        size: s(18),
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
                                size: s(18),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: s(10),
                        horizontal: s(12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: s(10)),
              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(12)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(12)),
                ),
                child: Text('Reset', style: GoogleFonts.lexend(fontSize: s(13), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: s(8)),
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

  Widget _buildClinicCard(ClinicModel clinic) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital_rounded, size: s(24), color: const Color(0xFF10B981)),
                SizedBox(width: s(10)),
                Expanded(
                  child: Text(
                    clinic.name,
                    style: GoogleFonts.lexend(
                      fontSize: s(16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: s(12)),
            _buildDetailRow(Icons.location_on_rounded, clinic.address),
            _buildDetailRow(Icons.phone_rounded, clinic.phoneNumber),
            _buildDetailRow(Icons.payments_rounded, '\$${clinic.consultationPrice}.00 EGP', iconColor: const Color(0xFFEA580C)),
            SizedBox(height: s(16)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: s(12)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClinicSchedulesView(
                        doctor: widget.doctor,
                        clinic: clinic,
                        cubit: widget.cubit,
                        scale: widget.scale,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.event_note_rounded, size: s(16), color: Colors.white),
                label: Text(
                  'View Schedules',
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

  Widget _buildDetailRow(IconData icon, String value, {Color iconColor = const Color(0xFF64748B)}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: s(16), color: iconColor),
          SizedBox(width: s(8)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lexend(
                fontSize: s(13),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
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
            'Loading clinics...',
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: const Color(0xFFEF4444), size: s(48)),
            SizedBox(height: s(16)),
            Text(
              'Failed to load clinics',
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
              style: GoogleFonts.lexend(fontSize: s(14), color: const Color(0xFF64748B)),
            ),
            SizedBox(height: s(24)),
            ElevatedButton(
              onPressed: () {
                widget.cubit.fetchDoctorClinics(widget.doctor.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_outlined, color: const Color(0xFF137FEC), size: s(48)),
            SizedBox(height: s(16)),
            Text(
              'No clinics found',
              style: GoogleFonts.lexend(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              'This doctor does not have any clinics registered.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: s(14), color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
