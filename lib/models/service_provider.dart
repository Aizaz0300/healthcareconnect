import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healthcare/models/review.dart';

// ServiceProvider Model
class ServiceProvider {
  final String id;
  final String name;                
  final String email;               
  final String gender;               
  final String imageUrl;            
  final List<String> services;   
  final double rating;                 
  final int reviewCount;               
  final String phone;                
  final int experience;           
  final String about;                
  final Availability availability;       
  final String address;     
  final List<String> cnic;               
  final List<String> gallery;    
  final List<String> certifications;   
  final List<SocialMedia> socialLinks;         
  final List<Review> reviewList;   
  final LicenseInfo licenseInfo;     
  final String status;
  final int hourlyRate;  

  ServiceProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.imageUrl,
    required this.services,
    required this.rating,
    required this.phone,
    required this.reviewCount,
    required this.experience,
    required this.about,
    required this.availability,
    required this.address,
    required this.licenseInfo,
    required this.cnic, 
    this.gallery = const [],
    this.certifications = const [],
    this.socialLinks = const [],
    this.reviewList = const [],
    this.status = "pending",
    required this.hourlyRate,
  });

  ServiceProvider copyWith({
    String? name,
    String? email,
    String? gender,
    String? imageUrl,
    List<String>? services,
    double? rating,
    String? phone,
    int? reviewCount,
    int? experience,
    String? about,
    Availability? availability,
    String? address,
    List<String>? cnic,
    List<String>? gallery,
    List<String>? certifications,
    List<SocialMedia>? socialLinks,
    List<Review>? reviewList,
    LicenseInfo? licenseInfo,
    String? status,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
      reviewCount: reviewCount ?? this.reviewCount,
      experience: experience ?? this.experience,
      about: about ?? this.about,
      availability: availability ?? this.availability,
      address: address ?? this.address,
      cnic: cnic ?? this.cnic,
      gallery: gallery ?? this.gallery,
      certifications: certifications ?? this.certifications,
      socialLinks: socialLinks ?? this.socialLinks,
      reviewList: reviewList ?? this.reviewList,
      licenseInfo: licenseInfo ?? this.licenseInfo,
      status: status ?? this.status,
      hourlyRate: hourlyRate, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'imageUrl': imageUrl,
      'services': services,
      'rating': rating,
      'phone': phone,
      'reviewCount': reviewCount,
      'experience': experience,
      'about': about,
      'availability': availability.toJson(),
      'address': address,
      'licenseInfo': licenseInfo.toJson(),
      'gallery': gallery,
      'certifications': certifications,
      'socialLinks': socialLinks.map((sm) => sm.toJson()).toList(),
      'reviewList': reviewList.map((rev) => rev.toJson()).toList(),
      'cnic': cnic,
      'status': status,
      'hourlyRate': hourlyRate,
    };
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['\$id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      imageUrl: json['imageUrl'] as String,
      services: List<String>.from(json['services'] as List),
      rating: (json['rating'] as num).toDouble(),
      phone: json['phone'] as String,
      reviewCount: json['reviewCount'] as int,
      experience: json['experience'] as int,
      about: json['about'] as String,
      cnic: List<String>.from(json['cnic'] as List),
      availability: Availability.fromJson(
          jsonDecode(json['availability'] as String) as Map<String, dynamic>
      ),
      address: json['address'] as String,
      licenseInfo: LicenseInfo.fromJson(
          jsonDecode(json['licenseInfo'] as String) as Map<String, dynamic>
      ),
      gallery: List<String>.from(json['gallery'] as List),
      certifications: List<String>.from(json['certifications'] as List),
      socialLinks: (json['socialLinks'] as List)
          .map((e) => SocialMedia.fromJson(
          jsonDecode(e as String) as Map<String, dynamic>))
          .toList(),
      reviewList: (json['reviewList'] as List)
          .map((e) => Review.fromJson(
          jsonDecode(e as String) as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'pending',
      hourlyRate: (json['hourlyRate'] as num?)?.toInt() ?? 0,
    );
  }

}

// Availability Model
class Availability {
  final DaySchedule monday;
  final DaySchedule tuesday;
  final DaySchedule wednesday;
  final DaySchedule thursday;
  final DaySchedule friday;
  final DaySchedule saturday;
  final DaySchedule sunday;

  Availability({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  Map<String, dynamic> toJson() {
    return {
      'monday': monday.toJson(),
      'tuesday': tuesday.toJson(),
      'wednesday': wednesday.toJson(),
      'thursday': thursday.toJson(),
      'friday': friday.toJson(),
      'saturday': saturday.toJson(),
      'sunday': sunday.toJson(),
    };
  }

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      monday: DaySchedule.fromJson(json['monday'] as Map<String, dynamic>),
      tuesday: DaySchedule.fromJson(json['tuesday'] as Map<String, dynamic>),
      wednesday: DaySchedule.fromJson(json['wednesday'] as Map<String, dynamic>),
      thursday: DaySchedule.fromJson(json['thursday'] as Map<String, dynamic>),
      friday: DaySchedule.fromJson(json['friday'] as Map<String, dynamic>),
      saturday: DaySchedule.fromJson(json['saturday'] as Map<String, dynamic>),
      sunday: DaySchedule.fromJson(json['sunday'] as Map<String, dynamic>),
    );
  }
}

// DaySchedule Model
class DaySchedule {
  final bool isAvailable;
  final List<TimeWindow> timeWindows;

  DaySchedule({
    this.isAvailable = false,
    this.timeWindows = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'timeWindows': timeWindows.map((tw) => tw.toJson()).toList(),
    };
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      isAvailable: json['isAvailable'] as bool? ?? false,
      timeWindows: (json['timeWindows'] as List<dynamic>?)
              ?.map((e) =>
                  TimeWindow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// TimeWindow Model with TimeOfDay Conversion Helpers
class TimeWindow {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeWindow({
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': _timeOfDayToJson(start),
      'end': _timeOfDayToJson(end),
    };
  }

  factory TimeWindow.fromJson(Map<String, dynamic> json) {
    return TimeWindow(
      start: _timeOfDayFromJson(json['start'] as Map<String, dynamic>),
      end: _timeOfDayFromJson(json['end'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _timeOfDayToJson(TimeOfDay time) {
    return {'hour': time.hour, 'minute': time.minute};
  }

  static TimeOfDay _timeOfDayFromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }
}

// SocialMedia Model with IconData Conversion Helpers
class SocialMedia {
  final String platform;
  final String url;
  final IconData icon;

  SocialMedia({
    required this.platform,
    required this.url,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
      'icon': _iconDataToJson(icon),
    };
  }

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      platform: json['platform'] as String,
      url: json['url'] as String,
      icon: _iconDataFromJson(json['icon'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _iconDataToJson(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
      'matchTextDirection': icon.matchTextDirection,
    };
  }

  static IconData _iconDataFromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String?,
      fontPackage: json['fontPackage'] as String?,
      matchTextDirection: json['matchTextDirection'] as bool? ?? false,
    );
  }
}

// LicenseInfo Model
class LicenseInfo {
  final String licenseNumber;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String licenseImageUrl;

  LicenseInfo({
    required this.licenseNumber,
    required this.issuingAuthority,
    required this.issueDate,
    required this.expiryDate,
    this.licenseImageUrl = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'licenseNumber': licenseNumber,
      'issuingAuthority': issuingAuthority,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'licenseImageUrl': licenseImageUrl,
    };
  }

  factory LicenseInfo.fromJson(Map<String, dynamic> json) {
    return LicenseInfo(
      licenseNumber: json['licenseNumber'] as String,
      issuingAuthority: json['issuingAuthority'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      licenseImageUrl: json['licenseImageUrl'] as String? ?? "",
    );
  }
}
