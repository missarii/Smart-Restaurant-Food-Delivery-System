import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _activeTab = 'Dashboard';
  final List<String> _menuCategories = ['Mains', 'Starters', 'Desserts', 'Beverages'];

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Content Container
          Expanded(
            child: Container(
              color: const Color(0xFF0D0E10),
              padding: const EdgeInsets.all(32),
              child: _buildActiveTabContent(api),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: AppTheme.darkSurface,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor, size: 28),
              SizedBox(width: 10),
              Text(
                'DineAdmin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSidebarItem('Dashboard', Icons.dashboard),
          _buildSidebarItem('Menu Manager', Icons.restaurant_menu),
          _buildSidebarItem('Reservations', Icons.calendar_month),
          _buildSidebarItem('Customer Chat', Icons.chat),
          const Spacer(),
          // User profile in sidebar
          Row(
            children: [
              const CircleAvatar(backgroundColor: AppTheme.primaryColor, child: Text('A')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin Owner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('owner@dragonpearl.com', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon) {
    bool isActive = _activeTab == title;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _activeTab = title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.white30, size: 20),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(ApiService api) {
    switch (_activeTab) {
      case 'Dashboard':
        return _buildDashboardContent(api);
      case 'Menu Manager':
        return _buildMenuManagerContent(api);
      case 'Reservations':
        return _buildReservationsContent(api);
      case 'Customer Chat':
        return _buildChatContent();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildDashboardContent(ApiService api) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analytics Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit')),
        const SizedBox(height: 24),
        // Stats Cards Grid
        Row(
          children: [
            _buildStatCard('Total Revenue', '\$12,482.00', '+14.2% since yesterday', Icons.attach_money, AppTheme.secondaryColor),
            const SizedBox(width: 20),
            _buildStatCard('Active Orders', '${api.orders.length + 2}', 'Real-time pipeline', Icons.local_shipping, AppTheme.primaryColor),
            const SizedBox(width: 20),
            _buildStatCard('Table Bookings', '${api.reservations.length + 4}', 'Pending confirmation', Icons.table_restaurant, AppTheme.accentColor),
          ],
        ),
        const SizedBox(height: 32),
        // Custom analytics charts
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GlassCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sales Curve (Weekly)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: SalesChartPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Side promotion status list
              Expanded(
                child: GlassCard(
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Promotional Banners', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 16),
                      _buildPromoRow('20% Midweek Special', 'Active', Colors.green),
                      _buildPromoRow('Free Drink for Loyalty Members', 'Active', Colors.green),
                      _buildPromoRow('Port City Launch Event', 'Draft', Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoRow(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String footer, IconData icon, Color iconColor) {
    return Expanded(
      child: GlassCard(
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                Icon(icon, color: iconColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            Text(footer, style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuManagerContent(ApiService api) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Menu Items Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit')),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Dish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: api.menuItems.length,
            itemBuilder: (context, index) {
              final item = api.menuItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(item.category, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (item.is3dEnabled)
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('3D Preview Enabled', style: TextStyle(color: AppTheme.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReservationsContent(ApiService api) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Table Seating & Bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit')),
        const SizedBox(height: 24),
        Expanded(
          child: api.reservations.isEmpty
              ? Center(
                  child: Text('No active reservations', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                )
              : ListView.builder(
                  itemCount: api.reservations.length,
                  itemBuilder: (context, index) {
                    final res = api.reservations[index];
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
                              Text(res.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('${res.guestCount} guests • Table ${res.tableNumber}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                                child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChatContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Support Tickets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit')),
        SizedBox(height: 24),
        Expanded(
          child: Center(
            child: Text('Select a chat from the active customer pool to respond.', style: TextStyle(color: Colors.white38)),
          ),
        ),
      ],
    );
  }
}

// Vector Line Chart Drawer for Revenue Statistics
class SalesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    int divisions = 5;
    for (int i = 0; i <= divisions; i++) {
      double y = (size.height / divisions) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Weekly sales points representation (scaled to canvas size)
    final points = [
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.95, size.height * 0.15),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var pt in points) {
      path.lineTo(pt.dx, pt.dy);
    }

    final linePaint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw chart line
    canvas.drawPath(path, linePaint);

    // Draw glow dots
    final dotPaint = Paint()..color = Colors.white;
    final dotGlow = Paint()..color = AppTheme.primaryColor.withOpacity(0.4);

    for (var pt in points) {
      canvas.drawCircle(pt, 8, dotGlow);
      canvas.drawCircle(pt, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SalesChartPainter oldDelegate) => false;
}
