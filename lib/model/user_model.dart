import 'package:collection/collection.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String gender; // 'ذكر' | 'انثى' or server English mapping
  final int age;
  final String city;
  final String userType; // 'User' | 'Doctor' | 'Secretary' | 'Representative'

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.city,
    required this.userType,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? gender,
    int? age,
    String? city,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'gender': gender,
    'age': age,
    'city': city,
    'userType': userType,
  };

  static UserModel fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json; // some APIs wrap in data
    return UserModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      gender: (data['gender'] ?? '').toString(),
      age: int.tryParse((data['age'] ?? '0').toString()) ?? 0,
      city: (data['city'] ?? '').toString(),
      userType: (data['userType'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        const DeepCollectionEquality().equals(toJson(), other.toJson());
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(toJson());
}
