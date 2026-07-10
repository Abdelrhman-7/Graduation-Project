class AvatarHelper {
  static String getDoctorAvatar({required int doctorId, String? imageUrl}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final s = imageUrl.trim().replaceAll('\\', '/');
      if (s.startsWith('http')) return s;
      return 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
    }
    
    // Return empty string to let the UI show the default placeholder icon
    return '';
  }
}
