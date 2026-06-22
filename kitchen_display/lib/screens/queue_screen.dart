import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final List<OrderModel> _incomingOrders = [];
  final List<OrderModel> _preparingOrders = [];
  final List<OrderModel> _readyOrders = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMockOrders();

    final socket = Provider.of<SocketService>(context, listen: false);
    socket.on('order:new', _handleNewOrderIncoming);
  }

  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context, listen: false);
    socket.off('order:new');
    super.dispose();
  }

  void _loadInitialMockOrders() {
    // Generate some starter orders for display
    final burgerItem = MenuItem(
      id: 'm_kb1',
      name: 'Lagoon Chili Crab',
      price: 24.50,
      imageUrl: '',
      category: 'Mains',
      rating: 4.8,
      tags: [],
      preparationTimeMinutes: 20,
      calories: 600,
    );

    final drinkItem = MenuItem(
      id: 'm_kb2',
      name: 'Ginger Mojito',
      price: 6.00,
      imageUrl: '',
      category: 'Beverages',
      rating: 4.7,
      tags: [],
      preparationTimeMinutes: 5,
      calories: 140,
    );

    _incomingOrders.add(
      OrderModel(
        orderId: 'ORD-7291',
        customerId: 'c1',
        customerName: 'Saman Perera',
        customerPhone: '+94 77 123 4567',
        items: [OrderItem(menuItem: burgerItem, quantity: 2, notes: 'Extra spicy please')],
        status: OrderStatus.placed,
        type: OrderType.delivery,
        totalAmount: 55.00,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        etaMinutes: 25,
        paymentStatus: PaymentStatus.paid,
      ),
    );

    _preparingOrders.add(
      OrderModel(
        orderId: 'ORD-7290',
        customerId: 'c2',
        customerName: 'Nilanthi De Silva',
        customerPhone: '+94 77 765 4321',
        items: [OrderItem(menuItem: burgerItem, quantity: 1), OrderItem(menuItem: drinkItem, quantity: 2)],
        status: OrderStatus.preparing,
        type: OrderType.dineIn,
        tableNumber: 'Table 3',
        totalAmount: 36.50,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        etaMinutes: 15,
        paymentStatus: PaymentStatus.paid,
      ),
    );
  }

  void _handleNewOrderIncoming(dynamic data) {
    if (data is Map<String, dynamic> && mounted) {
      final newOrder = OrderModel.fromMap(data);
      setState(() {
        _incomingOrders.add(newOrder);
      });
      _playChimeAndAlert(newOrder.orderId);
    }
  }

  void _playChimeAndAlert(String orderId) {
    // Show a beautiful visual notification flash
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppTheme.accentColor),
            const SizedBox(width: 8),
            Text('New incoming order: #$orderId'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _moveToPreparing(OrderModel order) {
    final socket = Provider.of<SocketService>(context, listen: false);
    setState(() {
      _incomingOrders.removeWhere((o) => o.orderId == order.orderId);
      final updated = _copyOrderWithStatus(order, OrderStatus.preparing);
      _preparingOrders.add(updated);
    });
    socket.emit('order:update_status', {'orderId': order.orderId, 'status': 'preparing'});
  }

  void _moveToReady(OrderModel order) {
    final socket = Provider.of<SocketService>(context, listen: false);
    setState(() {
      _preparingOrders.removeWhere((o) => o.orderId == order.orderId);
      final updated = _copyOrderWithStatus(order, OrderStatus.ready);
      _readyOrders.add(updated);
    });
    socket.emit('order:update_status', {'orderId': order.orderId, 'status': 'ready'});
  }

  void _completeOrder(OrderModel order) {
    final socket = Provider.of<SocketService>(context, listen: false);
    setState(() {
      _readyOrders.removeWhere((o) => o.orderId == order.orderId);
    });
    socket.emit('order:update_status', {'orderId': order.orderId, 'status': 'completed'});
  }

  OrderModel _copyOrderWithStatus(OrderModel order, OrderStatus newStatus) {
    return OrderModel(
      orderId: order.orderId,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      items: order.items,
      status: newStatus,
      type: order.type,
      tableNumber: order.tableNumber,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      etaMinutes: order.etaMinutes,
      paymentStatus: order.paymentStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display System (KDS)', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, color: AppTheme.accentColor),
            onPressed: () {
              // Simulate order arriving
              _handleNewOrderIncoming({
                'orderId': 'ORD-${1000 + DateTime.now().second}',
                'customerId': 'cust_sim',
                'customerName': 'Port City Guest',
                'customerPhone': '+94 77 111 2222',
                'items': [
                  {
                    'menuItem': {
                      'id': 'm1',
                      'name': 'Lagoon Chili Crab',
                      'description': 'Delicious crab',
                      'price': 24.50,
                      'imageUrl': '',
                      'category': 'Mains',
                      'rating': 4.9,
                      'tags': [],
                      'preparationTimeMinutes': 25,
                      'calories': 680
                    },
                    'quantity': 1,
                    'notes': 'No salt'
                  }
                ],
                'status': 'placed',
                'type': 'dineIn',
                'tableNumber': 'Table 7',
                'totalAmount': 24.50,
                'createdAt': DateTime.now().toIso8601String(),
                'etaMinutes': 25,
                'paymentStatus': 'paid'
              });
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          _buildColumn('INCOMING', _incomingOrders, Colors.orange, _buildIncomingCard),
          _buildColumn('PREPARING', _preparingOrders, Colors.blue, _buildPreparingCard),
          _buildColumn('READY', _readyOrders, AppTheme.secondaryColor, _buildReadyCard),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<OrderModel> orders, Color color, Widget Function(OrderModel) cardBuilder) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  '$title (${orders.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return cardBuilder(orders[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCard(OrderModel order) {
    return _buildBaseOrderCard(
      order,
      [
        ElevatedButton(
          onPressed: () => _moveToPreparing(order),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 36)),
          child: const Text('Start Cook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPreparingCard(OrderModel order) {
    return _buildBaseOrderCard(
      order,
      [
        ElevatedButton(
          onPressed: () => _moveToReady(order),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 36)),
          child: const Text('Mark Ready', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildReadyCard(OrderModel order) {
    return _buildBaseOrderCard(
      order,
      [
        ElevatedButton(
          onPressed: () => _completeOrder(order),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor, minimumSize: const Size(double.infinity, 36)),
          child: const Text('Serve / Dispatched', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBaseOrderCard(OrderModel order, List<Widget> actions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                Text(
                  order.type == OrderType.dineIn ? 'Dine-In (${order.tableNumber})' : 'Delivery',
                  style: const TextStyle(color: AppTheme.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.menuItem.name}', style: const TextStyle(color: Colors.white70)),
                      if (item.notes.isNotEmpty)
                        Text('(${item.notes})', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            ...actions,
          ],
        ),
      ),
    );
  }
}
