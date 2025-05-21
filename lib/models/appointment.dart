class Appointment {
  final String id;
  final String userId;
  final String providerId;
  final String username;    
  final String providerName;  
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final String notes;
  final String status;
  final double cost;

  Appointment({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.username,   
    required this.providerName,  
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.notes,
    required this.status,
    required this.cost,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'providerId': providerId,
      'username': username,    
      'providerName': providerName,  
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'notes': notes,
      'status': status,
      'cost': cost,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['\$id'] ?? '',
      userId: json['user_id'],
      providerId: json['provider_id'],
      username: json['username'],    
      providerName: json['providerName'],  
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      duration: json['duration'],
      notes: json['notes'],
      status: json['status'],
      cost: json['cost'],
    );
  }
}
