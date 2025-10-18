class DoctorPricing {
  final String? id;
  final String doctorId;
  final double defaultPrice;
  final String currency;
  final String? createdAt;
  final String? updatedAt;

  DoctorPricing({
    this.id,
    required this.doctorId,
    required this.defaultPrice,
    this.currency = 'IQ',
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorPricing.fromJson(Map<String, dynamic> json) {
    return DoctorPricing(
      id: json['_id']?.toString(),
      doctorId: json['doctorId']?.toString() ?? '',
      defaultPrice: (json['defaultPrice'] is num)
          ? (json['defaultPrice'] as num).toDouble()
          : 0.0,
      currency: json['currency']?.toString() ?? 'IQ',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'doctorId': doctorId,
      'defaultPrice': defaultPrice,
      'currency': currency,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
