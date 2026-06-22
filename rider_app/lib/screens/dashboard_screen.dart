import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OrderModel? _activeOrder;
  bool _isSimulatingRoute = false;
  Timer? _gpsTimer;
  double _simulatedProgress = 0.0;
  double _todayEarnings = 145.80;
  int _completedDeliveries = 9;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Mock incoming order for the rider
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _activeOrder == null) {
        _showIncomingOrderAlert();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gpsTimer?.cancel();
    super.dispose();
  }

  void _showIncomingOrderAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.sports_motorsports, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('New Delivery Job!', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #ORD-84920', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 6),
              Text('Restaurant: Lagoon Chili Crab & Rice', style: TextStyle(color: Colors.white70)),
              Text('Deliver to: Port City Avenue, Colombo', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Est. Payout:', style: TextStyle(color: Colors.white38)),
                  Text('\$18.50', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Decline', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _acceptOrder();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _acceptOrder() {
    setState(() {
      _activeOrder = OrderModel(
        orderId: 'ord_rider_sim_84920',
        customerId: 'usr_cust_demo',
        customerName: 'Alice Silva',
        customerPhone: '+94 77 987 6543',
        items: [],
        status: OrderStatus.accepted,
        type: OrderType.delivery,
        totalAmount: 48.90,
        createdAt: DateTime.now(),
        etaMinutes: 20,
        paymentStatus: PaymentStatus.paid,
      );
    });
  }

  void _startRouteSimulation() {
    final socket = Provider.of<SocketService>(context, listen: false);
    setState(() {
      _isSimulatingRoute = true;
      _simulatedProgress = 0.0;
    });

    // Simulate GPS location sharing along a path
    _gpsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      setState(() {
        _simulatedProgress += 0.1;
      });

      // Path coordinates (interpolation mock)
      double startLat = 6.9271; // Colombo Lat
      double startLng = 79.8612; // Colombo Lng
      double endLat = 6.9400;
      double endLng = 79.8700;

      double currentLat = startLat + (endLat - startLat) * _simulatedProgress;
      double currentLng = startLng + (endLng - startLng) * _simulatedProgress;

      // Stream location via Socket
      socket.emit('rider:location', {
        'orderId': _activeOrder?.orderId,
        'lat': currentLat,
        'lng': currentLng,
        'progress': _simulatedProgress,
      });

      if (_simulatedProgress >= 1.0) {
        timer.cancel();
        _completeDelivery();
      }
    });
  }

  void _completeDelivery() {
    setState(() {
      _todayEarnings += 18.50;
      _completedDeliveries += 1;
      _activeOrder = null;
      _isSimulatingRoute = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery completed! Earnings added to your wallet.'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white30,
          tabs: const [
            Tab(icon: Icon(Icons.delivery_dining), text: 'Active Task'),
            Tab(icon: Icon(Icons.wallet), text: 'My Earnings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTaskTab(),
          _buildEarningsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveTaskTab() {
    if (_activeOrder == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_motorsports_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('No Active Tasks', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Waiting for incoming orders...', style: TextStyle(color: Colors.white30, fontSize: 14)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Delivery Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order #ORD-84920', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isSimulatingRoute ? 'DELIVERING' : 'READY TO PICKUP',
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                const Row(
                  children: [
                    Icon(Icons.store, color: AppTheme.accentColor, size: 18),
                    SizedBox(width: 8),
                    Text('Dragon Pearl Restaurant', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_pin_circle, color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(_activeOrder!.customerName, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!_isSimulatingRoute)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _startRouteSimulation,
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text('Start Delivery Simulation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          else ...[
            const Text('GPS Route Simulation', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _simulatedProgress,
              color: AppTheme.primaryColor,
              backgroundColor: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Streaming mock coordinates to client app...',
                style: TextStyle(color: AppTheme.accentColor, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          borderRadius: 20,
          child: Column(
            children: [
              const Text("Today's Payout", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                '\$${_todayEarnings.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.extrabold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Deliveries', '$_completedDeliveries'),
                  _buildStatColumn('Online Time', '6.5 hrs'),
                  _buildStatColumn('Rider Rating', '4.95 ⭐'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Recent Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          double payout = 12.0 + (index * 2.5);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #ORD-1093${2 - index}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text('Delivered to Port City Ave', style: TextStyle(color: Colors.white30, fontSize: 11)),
                  ],
                ),
                Text(
                  '+\$${payout.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 18, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
