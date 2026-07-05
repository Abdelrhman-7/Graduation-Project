import 'package:flutter/material.dart';
import 'chat_view_body.dart';

class ChatView extends StatelessWidget {
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorImageUrl;

  const ChatView({
    super.key,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatViewBody(
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        doctorImageUrl: doctorImageUrl,
      ),
    );
  }
}
