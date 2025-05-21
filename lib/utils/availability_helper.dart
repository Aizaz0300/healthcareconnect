import 'package:flutter/material.dart';
import '/models/service_provider.dart';

class AvailabilityHelper {
  static DaySchedule addTimeWindow(DaySchedule schedule) {
    return DaySchedule(
      isAvailable: true,
      timeWindows: [
        ...schedule.timeWindows,
        TimeWindow(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 17, minute: 0),
        ),
      ],
    );
  }

  static DaySchedule removeTimeWindow(DaySchedule schedule, TimeWindow window) {
    return DaySchedule(
      isAvailable: schedule.timeWindows.length > 1,
      timeWindows: schedule.timeWindows.where((w) => w != window).toList(),
    );
  }

  static DaySchedule updateAvailability(DaySchedule schedule, bool isAvailable) {
    return DaySchedule(
      isAvailable: isAvailable,
      timeWindows: schedule.timeWindows,
    );
  }

  static Map<String, DaySchedule> getInitialAvailability() {
    return {
      'Monday': DaySchedule(),
      'Tuesday': DaySchedule(),
      'Wednesday': DaySchedule(),
      'Thursday': DaySchedule(),
      'Friday': DaySchedule(),
      'Saturday': DaySchedule(),
      'Sunday': DaySchedule(),
    };
  }
}
