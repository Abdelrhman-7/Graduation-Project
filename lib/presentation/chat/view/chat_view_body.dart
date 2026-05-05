import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/resources/theme_manager.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: _buildChatArea(),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppPadding.p16, AppPadding.p48, AppPadding.p16, AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: Color(0x1A7F13EC)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: AppSize.s20),
          ),
          const SizedBox(width: AppSize.s8),
          Stack(
            children: [
              Container(
                width: AppSize.s40,
                height: AppSize.s40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x337F13EC), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.s80),
                  child: Image.asset(
                    'assets/images/chat/sarah_johnson.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ColorManager.onlineStatus,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorManager.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.drSarahJohnson,
                  style: ThemeManager.getDoctorNameStyle(),
                ),
                Text(
                  AppStrings.cardiologistOnline,
                  style: ThemeManager.getDoctorStatusStyle(),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      color: ColorManager.background,
      child: ListView(
        padding: const EdgeInsets.all(AppPadding.p16),
        children: [
          _buildDateDivider(),
          const SizedBox(height: AppSize.s24),
          _buildDoctorBubble(AppStrings.doctorWelcomeMessage, "10:24 AM"),
          const SizedBox(height: AppSize.s16),
          _buildPatientBubble(AppStrings.patientResponse, "10:26 AM"),
          const SizedBox(height: AppSize.s16),
          _buildPatientAttachmentBubble(
            AppStrings.attachmentMessage,
            "assets/images/chat/medication_bottle.png",
            "10:27 AM",
          ),
          const SizedBox(height: AppSize.s16),
          _buildTypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildDateDivider() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p4),
        decoration: BoxDecoration(
          color: ColorManager.chatPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSize.s80),
        ),
        child: Text(
          AppStrings.today,
          style: ThemeManager.getChatDateStyle(),
        ),
      ),
    );
  }

  Widget _buildDoctorBubble(String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: const AssetImage('assets/images/chat/doctor_avatar.png'),
          onBackgroundImageError: (_, __) {},
          child: const Icon(Icons.person, size: 16),
        ),
        const SizedBox(width: AppSize.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppPadding.p16),
                decoration: const BoxDecoration(
                  color: ColorManager.chatBubbleDoctor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSize.s16),
                    topRight: Radius.circular(AppSize.s16),
                    bottomRight: Radius.circular(AppSize.s16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: ThemeManager.getDoctorBubbleStyle(),
                ),
              ),
              const SizedBox(height: AppSize.s4),
              Text(
                time,
                style: ThemeManager.getChatTimeStyle(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPatientBubble(String text, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(AppPadding.p16),
                decoration: const BoxDecoration(
                  color: ColorManager.chatPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSize.s16),
                    topRight: Radius.circular(AppSize.s16),
                    bottomLeft: Radius.circular(AppSize.s16),
                  ),
                ),
                child: Text(
                  text,
                  style: ThemeManager.getPatientBubbleStyle(),
                ),
              ),
              const SizedBox(height: AppSize.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: ThemeManager.getChatTimeStyle(),
                  ),
                  const SizedBox(width: AppSize.s4),
                  const Icon(Icons.done_all_rounded, size: 14, color: ColorManager.chatTime),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientAttachmentBubble(String text, String imagePath, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(AppPadding.p8),
                decoration: const BoxDecoration(
                  color: ColorManager.chatPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSize.s16),
                    topRight: Radius.circular(AppSize.s16),
                    bottomLeft: Radius.circular(AppSize.s16),
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.s12),
                      child: Image.asset(
                        imagePath,
                        height: AppSize.s192,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: AppSize.s192,
                          color: Colors.white24,
                          child: const Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text,
                        style: ThemeManager.getPatientBubbleStyle(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: ThemeManager.getChatTimeStyle(),
                  ),
                  const SizedBox(width: AppSize.s4),
                  const Icon(Icons.done_all_rounded, size: 14, color: ColorManager.chatTime),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: const AssetImage('assets/images/chat/doctor_typing.png'),
          onBackgroundImageError: (_, __) {},
          child: const Icon(Icons.person, size: 16),
        ),
        const SizedBox(width: AppSize.s12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p12),
          decoration: const BoxDecoration(
            color: ColorManager.chatBubbleDoctor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.s16),
              topRight: Radius.circular(AppSize.s16),
              bottomRight: Radius.circular(AppSize.s16),
            ),
          ),
          child: Row(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: ColorManager.chatPrimary.withValues(alpha: index == 0 ? 1 : 0.4),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: const BoxDecoration(
        color: ColorManager.white,
        border: Border(
          top: BorderSide(color: Color(0x1A7F13EC)),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: ColorManager.chatPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSize.s16),
                    border: Border.all(color: const Color(0x1A7F13EC)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle_outline_rounded, color: ColorManager.chatPrimary),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: TextField(
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: AppStrings.typeAMessage,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.sentiment_satisfied_alt_rounded, color: ColorManager.chatTime),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSize.s8),
              Container(
                decoration: BoxDecoration(
                  color: ColorManager.chatPrimary,
                  borderRadius: BorderRadius.circular(AppSize.s12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_rounded, color: ColorManager.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 12, color: ColorManager.chatTime),
              const SizedBox(width: AppSize.s4),
              Text(
                AppStrings.encryptedSecure,
                style: ThemeManager.getChatTimeStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
