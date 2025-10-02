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
    final String stringId = (json['_id'] ?? json['id'] ?? '').toString();
    final int safeId = stringId.isNotEmpty
        ? stringId.hashCode
        : (json['id'] is int ? json['id'] as int : 0);

    return BannerModel(
      id: safeId,
      image: (json['image'] ?? '').toString(),
      title: (json['name'] ?? json['title'])?.toString(),
      description: json['description']?.toString(),
      url: json['url']?.toString(),
      isActive: true,
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
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
