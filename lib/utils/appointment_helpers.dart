import 'package:flutter/material.dart';

bool isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
  if (time1.hour > time2.hour) return true;
  if (time1.hour < time2.hour) return false;
  return time1.minute > time2.minute;
}

TimeOfDay parseTimeString(String timeStr) {
  try {
    final trimmed = timeStr.trim();
    if (trimmed.toUpperCase().contains('AM') ||
        trimmed.toUpperCase().contains('PM')) {
      final parts = trimmed.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      }
      if (parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } else {
      final parts = trimmed.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  } catch (e) {
    debugPrint('Error parsing time: $e');
    return TimeOfDay.now();
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
