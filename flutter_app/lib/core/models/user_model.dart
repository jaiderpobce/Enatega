class AddressModel {
  AddressModel({
    required this.id,
    required this.label,
    required this.deliveryAddress,
    this.details,
    this.longitude,
    this.latitude,
    this.selected = false,
  });

  final String id;
  final String label;
  final String deliveryAddress;
  final String? details;
  final double? longitude;
  final double? latitude;
  final bool selected;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      deliveryAddress: (json['delivery_address'] ?? json['deliveryAddress'] ?? '').toString(),
      details: json['details']?.toString(),
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      selected: json['selected'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'delivery_address': deliveryAddress,
      'details': details,
      'longitude': longitude,
      'latitude': latitude,
      'selected': selected,
    };
  }
}

class UserModel {
  UserModel({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.token,
    this.isActive = true,
    this.notificationToken,
    this.isOrderNotification = true,
    this.isOfferNotification = true,
    this.addresses = const [],
  });

  final String userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? token;
  final bool isActive;
  final String? notificationToken;
  final bool isOrderNotification;
  final bool isOfferNotification;
  final List<AddressModel> addresses;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAddresses = json['addresses'] as List<dynamic>? ?? [];
    return UserModel(
      userId: (json['userId'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      token: json['token']?.toString(),
      isActive: json['is_active'] ?? true,
      notificationToken: json['notificationToken']?.toString(),
      isOrderNotification: json['is_order_notification'] ?? true,
      isOfferNotification: json['is_offer_notification'] ?? true,
      addresses: rawAddresses
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'is_active': isActive,
      'notificationToken': notificationToken,
      'is_order_notification': isOrderNotification,
      'is_offer_notification': isOfferNotification,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? token,
    bool? isActive,
    String? notificationToken,
    bool? isOrderNotification,
    bool? isOfferNotification,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      notificationToken: notificationToken ?? this.notificationToken,
      isOrderNotification: isOrderNotification ?? this.isOrderNotification,
      isOfferNotification: isOfferNotification ?? this.isOfferNotification,
      addresses: addresses ?? this.addresses,
    );
  }
}
