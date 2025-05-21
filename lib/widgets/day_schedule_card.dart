import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/models/service_provider.dart';
import 'time_window_selector.dart';

class DayScheduleCard extends StatelessWidget {
  final String day;
  final DaySchedule schedule;
  final Function(String, bool) onAvailabilityChanged;
  final Function(String) onAddTimeWindow;
  final Function(String, TimeWindow, bool) onTimeSelect;
  final Function(String, TimeWindow) onRemoveTimeWindow;

  const DayScheduleCard({
    super.key,
    required this.day,
    required this.schedule,
    required this.onAvailabilityChanged,
    required this.onAddTimeWindow,
    required this.onTimeSelect,
    required this.onRemoveTimeWindow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: schedule.isAvailable
            ? AppColors.primary.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.isAvailable
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (schedule.isAvailable) ...[
            const Divider(height: 1
                , color: Colors.grey),
            _buildTimeWindows(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getDayIcon(),
                color: schedule.isAvailable
                    ? AppColors.primary
                    : Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: schedule.isAvailable
                      ? Colors.black87
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          Switch(
            value: schedule.isAvailable,
            activeColor: AppColors.primary,
            onChanged: (value) => onAvailabilityChanged(day, value),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeWindows() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...schedule.timeWindows.map((window) => TimeWindowSelector(
                day: day,
                window: window,
                onTimeSelect: onTimeSelect,
                onRemove: onRemoveTimeWindow,
              )),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => onAddTimeWindow(day),
            icon: const Icon(Icons.add),
            label: const Text('Add Time Window'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon() {
    switch (day) {
      case 'Monday':
        return Icons.looks_one;
      case 'Tuesday':
        return Icons.looks_two;
      case 'Wednesday':
        return Icons.looks_3;
      case 'Thursday':
        return Icons.looks_4;
      case 'Friday':
        return Icons.looks_5;
      case 'Saturday':
        return Icons.looks_6;
      case 'Sunday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }
}
