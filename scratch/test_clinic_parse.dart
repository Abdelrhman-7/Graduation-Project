import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';

void main() {
  final item = {
    "id": 2,
    "name": "sui",
    "address": "ss",
    "phoneNumber": "01008765502",
    "consultationPrice": 330.00,
    "createdAt": "2026-07-01T19:55:14.3598583"
  };

  final clinic = ClinicModel.fromJson(item);
  print('Clinic parsed:');
  print('id: ${clinic.id}');
  print('name: ${clinic.name}');
  print('address: ${clinic.address}');
  print('phoneNumber: ${clinic.phoneNumber}');
  print('consultationPrice: ${clinic.consultationPrice}');
}
