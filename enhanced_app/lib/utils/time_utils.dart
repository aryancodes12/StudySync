/// Utility class for safe time parsing and formatting
class TimeUtils {
  /// Parse hour from time string safely
  /// Returns fallback value if parsing fails
  static int parseHour(String time, {int fallback = 0}) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        if (hour != null && hour >= 0 && hour < 24) {
          return hour;
        }
      }
    } catch (e) {
      return fallback;
    }
    return fallback;
  }
  
  /// Parse minute from time string safely
  /// Returns fallback value if parsing fails
  static int parseMinute(String time, {int fallback = 0}) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final minute = int.tryParse(parts[1]);
        if (minute != null && minute >= 0 && minute < 60) {
          return minute;
        }
      }
    } catch (e) {
      return fallback;
    }
    return fallback;
  }
  
  /// Validate time format (HH:MM)
  static bool isValidTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return false;
      
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      
      if (hour == null || minute == null) return false;
      return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
    } catch (e) {
      return false;
    }
  }
  
  /// Format time from hour and minute
  static String formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// Parse time string to hour and minute tuple
  static (int hour, int minute) parseTime(String time) {
    return (parseHour(time), parseMinute(time));
  }
}
