import 'dart:convert';

import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/models/service_provider.dart';
import '/services/appwrite_provider_service.dart';
import '/providers/service_provider_provider.dart';
import 'package:provider/provider.dart';
import '/widgets/day_schedule_card.dart';
import '/widgets/section_title.dart';
import '/utils/availability_helper.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  final _appwriteProviderService = AppwriteProviderService();
  bool _isLoading = false;
  Map<String, DaySchedule> _availability = AvailabilityHelper.getInitialAvailability();

  @override
  void initState() {
    super.initState();
    _loadCurrentAvailability();
  }

  Future<void> _loadCurrentAvailability() async {
    final provider = context.read<ServiceProviderProvider>().provider;
    if (provider != null) {
      setState(() {
        _availability = {
          'Monday': provider.availability.monday,
          'Tuesday': provider.availability.tuesday,
          'Wednesday': provider.availability.wednesday,
          'Thursday': provider.availability.thursday,
          'Friday': provider.availability.friday,
          'Saturday': provider.availability.saturday,
          'Sunday': provider.availability.sunday,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: _saveAvailability,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle(title: 'Weekly Availability'),
                const SizedBox(height: 16),
                const Text(
                  'Set your weekly availability schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ..._availability.entries.map((entry) {
                  return DayScheduleCard(
                    day: entry.key,
                    schedule: entry.value,
                    onAvailabilityChanged: (day, value) {
                      setState(() {
                        _availability[day] = AvailabilityHelper.updateAvailability(
                          entry.value, 
                          value
                        );
                        if (value && entry.value.timeWindows.isEmpty) {
                          _addTimeWindow(day);
                        }
                      });
                    },
                    onAddTimeWindow: _addTimeWindow,
                    onTimeSelect: _selectTime,
                    onRemoveTimeWindow: _removeTimeWindow,
                  );
                }).toList(),
              ],
            ),
    );
  }

  void _addTimeWindow(String day) {
    final schedule = _availability[day]!;
    setState(() {
      _availability[day] = AvailabilityHelper.addTimeWindow(schedule);
    });
  }

  void _removeTimeWindow(String day, TimeWindow window) {
    final schedule = _availability[day]!;
    setState(() {
      _availability[day] = AvailabilityHelper.removeTimeWindow(schedule, window);
    });
  }

  Future<void> _selectTime(String day, TimeWindow window, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? window.start : window.end,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final schedule = _availability[day]!;
        final index = schedule.timeWindows.indexOf(window);
        final updatedWindow = TimeWindow(
          start: isStart ? picked : window.start,
          end: isStart ? window.end : picked,
        );
        final updatedWindows = List<TimeWindow>.from(schedule.timeWindows);
        updatedWindows[index] = updatedWindow;
        _availability[day] = DaySchedule(
          isAvailable: true,
          timeWindows: updatedWindows,
        );
      });
    }
  }

  Future<void> _saveAvailability() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final provider = context.read<ServiceProviderProvider>().provider;
      if (provider != null) {
        final updatedAvailability = Availability(
          monday: _availability['Monday']!,
          tuesday: _availability['Tuesday']!,
          wednesday: _availability['Wednesday']!,
          thursday: _availability['Thursday']!,
          friday: _availability['Friday']!,
          saturday: _availability['Saturday']!,
          sunday: _availability['Sunday']!,
        );

        // Update provider with new availability
        final updatedProvider = provider.copyWith(
          availability: updatedAvailability,
        );

        // Create the update data with properly encoded fields
        final Map<String, dynamic> updates = {
          'availability': jsonEncode(updatedAvailability.toJson()),
        };

        // Update in database
        await _appwriteProviderService.updateProvider(
          providerId: provider.id,
          updates: updates,
        );

        if (!mounted) return;

        // Update local state after checking mounted
        context.read<ServiceProviderProvider>().updateProvider(updatedProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating availability: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
    }
  }
}
