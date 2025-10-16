class ProductModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String name;
  final String category;
  final double price;
  final double quantity;
  final String unit;
  final List<String> images;
  final String description;
  final DateTime harvestDate;
  final String location;
  final bool isOrganic;
  final double farmerRating;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.images,
    required this.description,
    required this.harvestDate,
    required this.location,
    this.isOrganic = false,
    this.farmerRating = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'images': images,
      'description': description,
      'harvestDate': harvestDate.toIso8601String(),
      'location': location,
      'isOrganic': isOrganic,
      'farmerRating': farmerRating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
      description: json['description'] as String? ?? '',
      harvestDate: DateTime.parse(json['harvestDate'] as String),
      location: json['location'] as String? ?? '',
      isOrganic: json['isOrganic'] as bool? ?? false,
      farmerRating: (json['farmerRating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}