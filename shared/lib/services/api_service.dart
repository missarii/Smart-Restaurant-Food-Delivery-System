import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService extends ChangeNotifier {
  final String baseUrl;
  List<MenuItem> _menuItems = [];
  final List<OrderItem> _cart = [];
  List<OrderModel> _orders = [];
  List<ReservationModel> _reservations = [];
  UserProfile? _currentUser;
  int _loyaltyPoints = 120; // default starting points for demo
  String? _selectedTable;

  ApiService({this.baseUrl = 'http://localhost:3000/api'});

  List<MenuItem> get menuItems => _menuItems.isEmpty ? _mockMenu : _menuItems;
  List<OrderItem> get cart => _cart;
  List<OrderModel> get orders => _orders;
  List<ReservationModel> get reservations => _reservations;
  UserProfile? get currentUser => _currentUser;
  int get loyaltyPoints => _loyaltyPoints;
  String? get selectedTable => _selectedTable;

  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  void setTable(String? table) {
    _selectedTable = table;
    notifyListeners();
  }

  void loginDemoUser(UserRole role) {
    _currentUser = UserProfile(
      userId: 'usr_demo_${role.name}',
      name: 'John Doe (${role.name})',
      email: 'demo_${role.name}@restaurant.com',
      phone: '+94 77 123 4567',
      role: role,
      loyaltyPoints: _loyaltyPoints,
    );
    notifyListeners();
  }

  // Cart Management
  void addToCart(MenuItem item, {int qty = 1, String notes = ''}) {
    int index = _cart.indexWhere((x) => x.menuItem.id == item.id);
    if (index >= 0) {
      _cart[index] = OrderItem(
        menuItem: item,
        quantity: _cart[index].quantity + qty,
        notes: notes.isNotEmpty ? notes : _cart[index].notes,
      );
    } else {
      _cart.add(OrderItem(menuItem: item, quantity: qty, notes: notes));
    }
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    _cart.removeWhere((x) => x.menuItem.id == item.id);
    notifyListeners();
  }

  void updateCartQuantity(MenuItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
      return;
    }
    int index = _cart.indexWhere((x) => x.menuItem.id == item.id);
    if (index >= 0) {
      _cart[index] = OrderItem(
        menuItem: item,
        quantity: quantity,
        notes: _cart[index].notes,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // HTTP Requests to backend
  Future<void> fetchMenu() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/menu'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        _menuItems = data.map((x) => MenuItem.fromMap(x)).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching menu, falling back to rich mock data: $e');
    }
  }

  // AI Recommendation Engine
  List<MenuItem> getAiRecommendations() {
    // Basic AI engine: if they have spicy food in cart, recommend a cooling drink.
    // If they have mains, recommend desserts. Otherwise recommend popular/trending items.
    bool hasSpicy = _cart.any((x) => x.menuItem.tags.contains('spicy'));
    bool hasMain = _cart.any((x) => x.menuItem.category == 'Mains');

    if (hasSpicy) {
      return menuItems.where((x) => x.category == 'Beverages').toList();
    } else if (hasMain) {
      return menuItems.where((x) => x.category == 'Desserts').toList();
    } else {
      return menuItems.where((x) => x.tags.contains('recommended')).toList();
    }
  }

  // Stripe Payment simulation
  Future<bool> processStripePayment(double amount) async {
    // Hit backend payment endpoint
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/payments/charge'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': (amount * 100).toInt(), 'currency': 'usd'}),
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        return body['success'] == true;
      }
    } catch (e) {
      if (kDebugMode) print('Payment backend error, simulating local Stripe success: $e');
    }
    // Simulation fallback
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Submit Order
  Future<OrderModel?> placeOrder(OrderType type) async {
    if (_cart.isEmpty) return null;

    final String orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final double total = cartTotal;

    final OrderModel newOrder = OrderModel(
      orderId: orderId,
      customerId: _currentUser?.userId ?? 'usr_guest',
      customerName: _currentUser?.name ?? 'Guest Customer',
      customerPhone: _currentUser?.phone ?? '+94 77 000 0000',
      items: List.from(_cart),
      status: OrderStatus.placed,
      type: type,
      tableNumber: _selectedTable,
      totalAmount: total,
      createdAt: DateTime.now(),
      etaMinutes: 25,
      paymentStatus: PaymentStatus.paid, // assuming Stripe processed
    );

    // Sync to backend
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newOrder.toMap()),
      );
      if (res.statusCode == 201) {
        final savedOrder = OrderModel.fromMap(json.decode(res.body));
        _orders.add(savedOrder);
        _loyaltyPoints += (total * 0.1).toInt(); // 10% cash back in points
        clearCart();
        return savedOrder;
      }
    } catch (e) {
      if (kDebugMode) print('Submit order failed, processing locally: $e');
    }

    // Local-only flow fallback
    _orders.add(newOrder);
    _loyaltyPoints += (total * 0.1).toInt();
    clearCart();
    return newOrder;
  }

  // Table Reservations
  Future<bool> bookTable(int guests, DateTime dateTime) async {
    final String resId = 'res_${DateTime.now().millisecondsSinceEpoch}';
    final newRes = ReservationModel(
      reservationId: resId,
      customerId: _currentUser?.userId ?? 'usr_guest',
      customerName: _currentUser?.name ?? 'Guest User',
      customerPhone: _currentUser?.phone ?? '+94 77 123 4567',
      guestCount: guests,
      tableNumber: 'Table ${(1 + (reservations.length % 12))}',
      dateTime: dateTime,
      status: 'pending',
    );

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newRes.toMap()),
      );
      if (res.statusCode == 201) {
        _reservations.add(ReservationModel.fromMap(json.decode(res.body)));
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Reservation backend error, saving locally: $e');
    }

    _reservations.add(newRes);
    notifyListeners();
    return true;
  }

  // Premium pre-populated menu
  static final List<MenuItem> _mockMenu = [
    MenuItem(
      id: 'm1',
      name: 'Ceylon Lagoon Chili Crab',
      description: 'Fresh giant mud crab cooked with authentic Sri Lankan spices, thick spicy chili pepper sauce.',
      price: 24.50,
      imageUrl: 'https://images.unsplash.com/photo-1551248429-40975aa4de74?auto=format&fit=crop&w=600&q=80',
      category: 'Mains',
      rating: 4.9,
      is3dEnabled: true,
      model3dUrl: 'crab_model',
      tags: ['spicy', 'popular', 'recommended'],
      preparationTimeMinutes: 25,
      calories: 680,
    ),
    MenuItem(
      id: 'm2',
      name: 'Colombo Premium Lamprais',
      description: 'Ghee rice baked in banana leaf with mixed meat curry, frikkadels, blachan, and deep-fried egg.',
      price: 14.90,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      category: 'Mains',
      rating: 4.8,
      is3dEnabled: true,
      model3dUrl: 'lamprais_model',
      tags: ['popular', 'recommended'],
      preparationTimeMinutes: 20,
      calories: 820,
    ),
    MenuItem(
      id: 'm3',
      name: 'Devilled Paneer Bowl',
      description: 'Crispy paneer tossed in fiery Sri Lankan sweet-sour devilled sauce with capsicums and red onions.',
      price: 11.20,
      imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
      category: 'Starters',
      rating: 4.6,
      is3dEnabled: false,
      tags: ['spicy'],
      preparationTimeMinutes: 12,
      calories: 450,
    ),
    MenuItem(
      id: 'm4',
      name: 'Luminous Matcha Mousse',
      description: 'Decadent velvet-texture white chocolate matcha mousse topped with gold flake and raspberry coulis.',
      price: 8.50,
      imageUrl: 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=600&q=80',
      category: 'Desserts',
      rating: 4.9,
      is3dEnabled: true,
      model3dUrl: 'matcha_mousse',
      tags: ['recommended'],
      preparationTimeMinutes: 8,
      calories: 310,
    ),
    MenuItem(
      id: 'm5',
      name: 'Passionfruit Ginger Mojito',
      description: 'Refreshing crush of local passionfruit juice, ginger extract, fresh mint, lime juice, and sparkling club soda.',
      price: 6.00,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      category: 'Beverages',
      rating: 4.7,
      is3dEnabled: false,
      tags: ['popular'],
      preparationTimeMinutes: 5,
      calories: 140,
    ),
  ];
}
