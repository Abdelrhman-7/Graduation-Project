class TimeFormatter {
  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == 'TBD') return timeStr ?? '';
    
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        String period = 'AM';
        if (hour >= 12) {
          period = 'PM';
          if (hour > 12) hour -= 12;
        }
        if (hour == 0) hour = 12;
        
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // fallback
    }
    return timeStr;
  }
}
