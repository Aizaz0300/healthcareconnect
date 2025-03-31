class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final DateTime date;
  final String time;
  final String status;
  final String reason;
  final String location;
  final double price;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.reason,
    required this.location,
    required this.price,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      status: json['status'],
      reason: json['reason'],
      location: json['location'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'reason': reason,
      'location': location,
      'price': price,
    };
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? patientId,
    String? patientName,
    DateTime? date,
    String? time,
    String? status,
    String? reason,
    String? location,
    double? price,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      price: price ?? this.price,
    );
  }
}
