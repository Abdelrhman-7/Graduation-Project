import 'package:flutter/material.dart';
import 'chat_view_body.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChatViewBody(),
    );
  }
}
