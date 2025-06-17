class Appointment {
  final String id;
  final String userId;
  final String providerId;
  final String username;    
  final String providerName;
  final String userImageURL;
  final String providerImageURL;
  final String service;  
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final String notes;
  final String status;
  final int cost;
  final String destinationAddress;
  final bool hasReview;

  Appointment({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.username,   
    required this.providerName,  
    required this.userImageURL,
    required this.providerImageURL,
    required this.service,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.notes,
    required this.status,
    required this.cost,
    required this.destinationAddress,
    this.hasReview = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'providerId': providerId,
      'username': username,    
      'providerName': providerName,  
      'userImageURL': userImageURL,
      'providerImageURL': providerImageURL,
      'service': service,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'notes': notes,
      'status': status,
      'cost': cost,
      'destinationAddress': destinationAddress,
      'hasReview': hasReview,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['\$id'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      username: json['username'] as String,
      providerName: json['providerName'] as String,
      userImageURL: json['userImageURL'] as String,
      providerImageURL: json['providerImageURL'] as String,
      service: json['service'] as String,
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      duration: json['duration'] as int,
      notes: json['notes'] as String,
      status: json['status'] as String,
      cost: json['cost'] as int,
      destinationAddress: json['destinationAddress'] as String,
      hasReview: json['hasReview'] as bool? ?? false,
    );
  }
}

