import 'dart:convert';

enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  delivering,
  delivered,
  completed,
  cancelled
}

enum OrderType {
  takeaway,
  delivery,
  dineIn
}

enum PaymentStatus {
  pending,
  paid,
  failed
}

enum UserRole {
  customer,
  rider,
  admin,
  kitchen
}

class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final int loyaltyPoints;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.loyaltyPoints = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final bool is3dEnabled;
  final String model3dUrl;
  final List<String> tags;
  final int preparationTimeMinutes;
  final int calories;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.is3dEnabled = false,
    this.model3dUrl = '',
    required this.tags,
    required this.preparationTimeMinutes,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'is3dEnabled': is3dEnabled,
      'model3dUrl': model3dUrl,
      'tags': tags,
      'preparationTimeMinutes': preparationTimeMinutes,
      'calories': calories,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      is3dEnabled: map['is3dEnabled'] ?? false,
      model3dUrl: map['model3dUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      preparationTimeMinutes: map['preparationTimeMinutes'] ?? 15,
      calories: map['calories'] ?? 350,
    );
  }
}

class OrderItem {
  final MenuItem menuItem;
  final int quantity;
  final String notes;

  OrderItem({
    required this.menuItem,
    required this.quantity,
    this.notes = '',
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItem: MenuItem.fromMap(map['menuItem']),
      quantity: map['quantity'] ?? 1,
      notes: map['notes'] ?? '',
    );
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? riderId;
  final List<OrderItem> items;
  final OrderStatus status;
  final OrderType type;
  final String? tableNumber;
  final double totalAmount;
  final double? riderLat;
  final double? riderLng;
  final DateTime createdAt;
  final int etaMinutes;
  final PaymentStatus paymentStatus;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.riderId,
    required this.items,
    required this.status,
    required this.type,
    this.tableNumber,
    required this.totalAmount,
    this.riderLat,
    this.riderLng,
    required this.createdAt,
    required this.etaMinutes,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'riderId': riderId,
      'items': items.map((x) => x.toMap()).toList(),
      'status': status.name,
      'type': type.name,
      'tableNumber': tableNumber,
      'totalAmount': totalAmount,
      'riderLat': riderLat,
      'riderLng': riderLng,
      'createdAt': createdAt.toIso8601String(),
      'etaMinutes': etaMinutes,
      'paymentStatus': paymentStatus.name,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      riderId: map['riderId'],
      items: List<OrderItem>.from(
          (map['items'] as List).map((x) => OrderItem.fromMap(x))),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.placed,
      ),
      type: OrderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => OrderType.delivery,
      ),
      tableNumber: map['tableNumber'],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      riderLat: (map['riderLat'] as num?)?.toDouble(),
      riderLng: (map['riderLng'] as num?)?.toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      etaMinutes: map['etaMinutes'] ?? 20,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
    );
  }
}

class ReservationModel {
  final String reservationId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final int guestCount;
  final String tableNumber;
  final DateTime dateTime;
  final String status; // pending, confirmed, cancelled

  ReservationModel({
    required this.reservationId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.guestCount,
    required this.tableNumber,
    required this.dateTime,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'guestCount': guestCount,
      'tableNumber': tableNumber,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      reservationId: map['reservationId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      guestCount: map['guestCount'] ?? 1,
      tableNumber: map['tableNumber'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      status: map['status'] ?? 'pending',
    );
  }
}

class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String messageText;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.messageText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      messageText: map['messageText'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
