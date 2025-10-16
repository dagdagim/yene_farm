import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phone;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String role; // 'farmer', 'buyer', 'driver', 'admin'
  
  @HiveField(5)
  final String location;
  
  @HiveField(6)
  final String language;
  
  @HiveField(7)
  final bool isVerified;
  
  @HiveField(8)
  final double rating;
  
  @HiveField(9)
  final int totalTransactions;
  
  @HiveField(10)
  final String? profileImage;
  
  @HiveField(11)
  final String? farmLocation;
  
  @HiveField(12)
  final double? farmSize;
  
  @HiveField(13)
  final List<String> crops;
  
  @HiveField(14)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.location,
    required this.language,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalTransactions = 0,
    this.profileImage,
    this.farmLocation,
    this.farmSize,
    this.crops = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'location': location,
      'language': language,
      'isVerified': isVerified,
      'rating': rating,
      'totalTransactions': totalTransactions,
      'profileImage': profileImage,
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'crops': crops,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      location: json['location'],
      language: json['language'],
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      profileImage: json['profileImage'],
      farmLocation: json['farmLocation'],
      farmSize: json['farmSize']?.toDouble(),
      crops: List<String>.from(json['crops'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}