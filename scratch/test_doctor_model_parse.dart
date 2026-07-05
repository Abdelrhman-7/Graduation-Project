import 'package:graduationproject/data/models/schudule/doctorModel.dart';

void main() {
  final items = [
    {
      'doctorId': 1,
      'displayImageUrl': '/images/doctors/test.png',
      'fullName': 'Abdel-Rahman Al-hussieny',
      'departmentName': 'Orthopedics',
      'gender': 'Male',
      'age': 21,
    },
    {
      'doctorId': 2,
      'displayImageUrl': '/images/doctors/default.png',
      'fullName': 'Abdo',
      'departmentName': 'Neurology',
      'gender': 'Male',
      'age': 24,
    },
  ];

  final doctors = items
      .map((item) => DoctorModel.fromJson(Map<String, dynamic>.from(item)))
      .where((doctor) => doctor.id > 0)
      .toList();

  print('Parsed ${doctors.length} doctors');
  for (final d in doctors) {
    print('${d.id}: ${d.fullName} (${d.departmentName}) img=${d.imageUrl}');
  }
}
