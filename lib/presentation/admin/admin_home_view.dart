import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import 'manage_doctors/view/manage_doctors_view.dart';
import 'manage_patients/view/manage_patients_view.dart';
import 'package:graduationproject/presentation/login/view/login_view.dart';
import '../../../data/repository/shared_pref_controller.dart';
import 'package:graduationproject/presentation/role_selection/cubit/role_selection_state.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ManageDoctorsView(),
    const ManagePatientsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SharedPrefController().logout();
              Navigator.pushAndRemoveUntil(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginView(role: UserRole.patient),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: ColorManager.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
        ],
      ),
    );
  }
}
