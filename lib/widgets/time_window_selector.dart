import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/models/service_provider.dart';

class TimeWindowSelector extends StatelessWidget {
  final String day;
  final TimeWindow window;
  final Function(String, TimeWindow, bool) onTimeSelect;
  final Function(String, TimeWindow) onRemove;

  const TimeWindowSelector({
    super.key,
    required this.day,
    required this.window,
    required this.onTimeSelect,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(child: _buildTimeButton(context, true)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('to'),
            ),
            Expanded(child: _buildTimeButton(context, false)),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
              onPressed: () => onRemove(day, window),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, bool isStart) {
    return InkWell(
      onTap: () => onTimeSelect(day, window, isStart),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatTimeOfDay(isStart ? window.start : window.end),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
