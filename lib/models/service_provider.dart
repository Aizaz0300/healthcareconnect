import 'package:flutter/material.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String imageUrl;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String experience;
  final double consultationFee;
  final String about;
  final List<String> services;
  final List<String> availability;
  final String location;
  final List<String> gallery;
  final List<Credential> credentials;
  final List<SocialMedia> socialLinks;
  final String chatId;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.consultationFee,
    required this.about,
    required this.services,
    required this.availability,
    required this.location,
    this.gallery = const [],
    this.credentials = const [],
    this.socialLinks = const [],
    this.chatId = '',
  });
}

class Credential {
  final String title;
  final String institute;
  final String year;
  final String? certificationUrl;

  Credential({
    required this.title,
    required this.institute,
    required this.year,
    this.certificationUrl,
  });
}

class SocialMedia {
  final String platform;
  final String url;
  final IconData icon;

  SocialMedia({
    required this.platform,
    required this.url,
    required this.icon,
  });
}
