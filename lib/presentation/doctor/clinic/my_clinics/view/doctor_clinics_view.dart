import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/presentation/doctor/clinic/my_clinics/cubit/doctor_clinics_state.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../data/api/api_manager.dart';
import '../../../../../data/repository/scheduleRepository/clinic_repository.dart';
import '../../add_clinic/cubit/add_clinic_cubit.dart';
import '../../add_clinic/cubit/add_clinic_state.dart';
import '../cubit/doctor_clinics_cubit.dart';
import '../widgets/clinic_list_item.dart';
import '../widgets/edit_clinic_dialog.dart';
import '../widgets/clinic_bookings_sheet.dart';

class DoctorClinicsView extends StatefulWidget {
  const DoctorClinicsView({super.key});

  @override
  State<DoctorClinicsView> createState() => _DoctorClinicsViewState();
}

class _DoctorClinicsViewState extends State<DoctorClinicsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<ApiManager> _apiManagerFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _apiManagerFuture = ApiManager.create();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiManager>(
      future: _apiManagerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(child: Text('Failed to initialize: ${snapshot.error}')),
          );
        }
        final apiManager = snapshot.data!;
        return BlocProvider(
          create: (context) =>
              DoctorClinicsCubit(clinicRepository: ClinicRepository(apiManager))
                ..loadClinics(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _MyClinicsTab(tabController: _tabController),
                        _AddClinicTab(tabController: _tabController, apiManager: apiManager),
                      ],
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
            'My Clinics',
            style: GoogleFonts.lexend(
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
            GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(icon: Icon(Icons.local_hospital_outlined), text: 'My Clinics'),
          Tab(icon: Icon(Icons.add_circle_outline_rounded), text: 'Add New'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1: My Clinics list
// ─────────────────────────────────────────────────────────────
class _MyClinicsTab extends StatelessWidget {
  final TabController tabController;
  const _MyClinicsTab({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorClinicsCubit, DoctorClinicsState>(
      listener: (context, state) {
        if (state is DoctorClinicsError) {
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
        if (state is DoctorClinicsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorManager.primary),
          );
        }

        if (state is DoctorClinicsSuccess) {
          if (state.clinics.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 100),
                itemCount: state.clinics.length,
                itemBuilder: (context, index) {
                  final clinic = state.clinics[index];
                  return ClinicListItem(
                    clinic: clinic,
                    onTap: () =>
                        _showBookings(context, clinic.id!, clinic.name),
                    onEdit: () => _showEditDialog(context, clinic),
                    onDelete: () => _confirmDelete(context, clinic.id!),
                  );
                },
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  heroTag: 'add_clinic_fab',
                  onPressed: () => tabController.animateTo(1),
                  backgroundColor: ColorManager.primary,
                  elevation: 4,
                  icon: const Icon(Icons.add_business_rounded,
                      color: Colors.white),
                  label: Text(
                    'Add Clinic',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
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
              Icon(Icons.local_hospital_outlined,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No clinics added yet',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add your first clinic',
                style: GoogleFonts.lexend(
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
            heroTag: 'add_clinic_fab_empty',
            onPressed: () => tabController.animateTo(1),
            backgroundColor: ColorManager.primary,
            elevation: 4,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: Text(
              'Add Clinic',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBookings(
      BuildContext context, int clinicId, String clinicName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final bookings = await context
          .read<DoctorClinicsCubit>()
          .clinicRepository
          .getClinicBookings(clinicId);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) => ClinicBookingsSheet(
            clinicId: clinicId,
            clinicName: clinicName,
            bookings: bookings,
          ),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load bookings: $e')));
    }
  }

  void _showEditDialog(BuildContext context, ClinicModel clinic) {
    showDialog(
      context: context,
      builder: (_) => EditClinicDialog(
        clinic: clinic,
        onSave: (updated) =>
            context.read<DoctorClinicsCubit>().updateClinic(updated),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Clinic',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this clinic? This action cannot be undone.',
          style: GoogleFonts.lexend(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: GoogleFonts.lexend(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DoctorClinicsCubit>().deleteClinic(id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete',
                style: GoogleFonts.lexend(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2: Add New Clinic (inline form)
// ─────────────────────────────────────────────────────────────
class _AddClinicTab extends StatefulWidget {
  final TabController tabController;
  final ApiManager apiManager;
  const _AddClinicTab({required this.tabController, required this.apiManager});

  @override
  State<_AddClinicTab> createState() => _AddClinicTabState();
}

class _AddClinicTabState extends State<_AddClinicTab> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _notsController = TextEditingController();

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _priceController.clear();
    _durationController.clear();
    _notsController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _notsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddClinicCubit(ClinicRepository(widget.apiManager)),
      child: BlocConsumer<AddClinicCubit, AddClinicState>(
        listener: (context, state) {
          if (state is AddClinicSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clinic added successfully!'),
                backgroundColor: Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _clearForm();
            // Reload the list then switch to My Clinics tab
            context.read<DoctorClinicsCubit>().loadClinics();
            widget.tabController.animateTo(0);
          } else if (state is AddClinicError) {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Clinic Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g., Hope Medical Center',
                  icon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Clinic Address'),
                _buildTextField(
                  controller: _addressController,
                  hint: 'e.g., 123 Main St, Cityville',
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Phone Number'),
                _buildTextField(
                  controller: _phoneController,
                  hint: 'e.g., +20 100 000 0000',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Consultation Price (EGP)'),
                _buildTextField(
                  controller: _priceController,
                  hint: 'e.g., 500',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Appointment Duration (min)'),
                _buildTextField(
                  controller: _durationController,
                  hint: 'e.g., 30',
                  icon: Icons.timer_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('Notes'),
                _buildTextField(
                  controller: _notsController,
                  hint: 'Any notes about the clinic...',
                  icon: Icons.note_alt_outlined,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is AddClinicLoading
                        ? null
                        : () {
                            context.read<AddClinicCubit>().addClinic(
                                  name: _nameController.text.trim(),
                                  address: _addressController.text.trim(),
                                  phoneNumber: _phoneController.text.trim(),
                                  consultationPriceStr:
                                      _priceController.text.trim(),
                                  appointmentDuration:
                                      _durationController.text.trim(),
                                  nots: _notsController.text.trim(),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: state is AddClinicLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Save Clinic',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style:
            GoogleFonts.lexend(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(
            fontSize: 15,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
