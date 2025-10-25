import 'package:collection/collection.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String gender; // 'ذكر' | 'انثى' or server English mapping
  final int age;
  final String city;
  final String userType; // 'User' | 'Doctor' | 'Secretary' | 'Representative'
  final String image; // profile image URL
  final String specialization; // doctor's specialization if any
  final Map<String, String> socialMedia; // Social media links
  final String
  associatedDoctor; // For secretaries: ID of the doctor they work for
  final String address; // User's address

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.city,
    required this.userType,
    this.image = '',
    this.specialization = '',
    this.socialMedia = const <String, String>{},
    this.associatedDoctor = '',
    this.address = '',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? gender,
    int? age,
    String? city,
    String? userType,
    String? image,
    String? specialization,
    Map<String, String>? socialMedia,
    String? associatedDoctor,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      userType: userType ?? this.userType,
      image: image ?? this.image,
      specialization: specialization ?? this.specialization,
      socialMedia: socialMedia ?? this.socialMedia,
      associatedDoctor: associatedDoctor ?? this.associatedDoctor,
      address: address ?? this.address,
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
    'image': image,
    'specialization': specialization,
    'socialMedia': socialMedia,
    'associatedDoctor': associatedDoctor,
    'address': address,
  };

  static UserModel fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json; // some APIs wrap in data

    // Parse social media
    final Map<String, String> socialMediaMap = <String, String>{};
    final dynamic socialMediaData = data['socialMedia'];
    if (socialMediaData is Map<String, dynamic>) {
      socialMediaData.forEach((key, value) {
        if (value != null) {
          socialMediaMap[key.toString()] = value.toString();
        }
      });
    }

    // Parse specialization - can be String (ID) or Map (object)
    String specializationId = '';
    final dynamic specializationData = data['specialization'];
    if (specializationData is String) {
      // It's already an ID
      specializationId = specializationData;
      print('🔍 Specialization is String (ID): $specializationId');
    } else if (specializationData is Map) {
      // It's an object, extract the ID
      specializationId =
          (specializationData['_id'] ?? specializationData['id'] ?? '')
              .toString();
      print(
        '🔍 Specialization is Map (object), extracted ID: $specializationId',
      );
    } else if (specializationData != null) {
      print(
        '⚠️ Specialization is unknown type: ${specializationData.runtimeType}',
      );
    }

    // Parse associatedDoctor field (for secretaries)
    final associatedDoctorValue =
        data['associatedDoctor'] ?? data['doctorId'] ?? data['doctor'] ?? '';

    return UserModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      gender: (data['gender'] ?? '').toString(),
      age: int.tryParse((data['age'] ?? '0').toString()) ?? 0,
      city: (data['city'] ?? '').toString(),
      userType: (data['userType'] ?? '').toString(),
      image: (data['image'] ?? data['avatar'] ?? '').toString(),
      specialization: specializationId,
      socialMedia: socialMediaMap,
      associatedDoctor: associatedDoctorValue.toString(),
      address: (data['address'] ?? '').toString(),
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
