class HospitalModel {
  final String id;
  final String name;
  final String image;
  final String address;
  final String phone;
  final String facebook;
  final String instagram;
  final String whatsapp;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.phone,
    required this.facebook,
    required this.instagram,
    required this.whatsapp,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      facebook: (json['facebook'] ?? '').toString(),
      instagram: (json['instagram'] ?? '').toString(),
      whatsapp: (json['whatsapp'] ?? '').toString(),
    );
  }
}
