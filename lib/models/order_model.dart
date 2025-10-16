import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class OrderModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String buyerId;
  
  @HiveField(2)
  final String buyerName;
  
  @HiveField(3)
  final String farmerId;
  
  @HiveField(4)
  final String farmerName;
  
  @HiveField(5)
  final List<OrderItem> items;
  
  @HiveField(6)
  final double totalAmount;
  
  @HiveField(7)
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  
  @HiveField(8)
  final String paymentStatus; // 'pending', 'completed', 'failed'
  
  @HiveField(9)
  final String deliveryAddress;
  
  @HiveField(10)
  final DateTime orderDate;
  
  @HiveField(11)
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    required this.deliveryAddress,
    required this.orderDate,
    this.deliveryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: json['totalAmount'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
    );
  }
}

@HiveType(typeId: 3)
class OrderItem {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String productName;
  
  @HiveField(2)
  final double quantity;
  
  @HiveField(3)
  final double unitPrice;
  
  @HiveField(4)
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      totalPrice: json['totalPrice'],
    );
  }
}