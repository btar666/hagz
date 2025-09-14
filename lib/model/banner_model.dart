class BannerModel {
  final int id;
  final String image;
  final String? title;
  final String? description;
  final String? url;
  final bool isActive;
  final String? createdAt;

  BannerModel({
    required this.id,
    required this.image,
    this.title,
    this.description,
    this.url,
    this.isActive = true,
    this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      url: json['url']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'url': url,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  // Factory method لإنشاء banner فارغ للـ skeleton loading
  factory BannerModel.empty() {
    return BannerModel(
      id: 0,
      image: '',
      title: 'Loading...',
      description: 'Loading...',
      url: null,
      isActive: true,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, image: $image, title: $title, isActive: $isActive)';
  }
}
