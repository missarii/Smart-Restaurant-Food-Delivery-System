import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class DetailsScreen extends StatefulWidget {
  final MenuItem item;

  const DetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  double _rotationX = -0.6;
  double _rotationY = 0.5;
  late AnimationController _autoRotationController;

  @override
  void initState() {
    super.initState();
    _autoRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(() {
        setState(() {
          _rotationY += 0.01;
        });
      });
    _autoRotationController.repeat();
  }

  @override
  void dispose() {
    _autoRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    final trans = Provider.of<TranslationService>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1115), Color(0xFF1E222B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // 3D Canvas / Drag Area
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            height: 380,
            child: GestureDetector(
              onPanUpdate: (details) {
                _autoRotationController.stop();
                setState(() {
                  _rotationY += details.delta.dx * 0.01;
                  _rotationX += details.delta.dy * 0.01;
                });
              },
              onPanEnd: (_) {
                _autoRotationController.repeat();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: Food3dPainter(
                      rotationX: _rotationX,
                      rotationY: _rotationY,
                      color: widget.item.category == 'Mains' 
                          ? const Color(0xFFFF5A36) 
                          : widget.item.category == 'Beverages' 
                              ? Colors.cyanAccent 
                              : Colors.greenAccent,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.swipe, color: Colors.white70, size: 14),
                          SizedBox(width: 8),
                          Text('Drag to rotate 3D view', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Details Card (Slide from bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 360,
            child: GlassCard(
              borderRadius: 32,
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.accentColor, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.item.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetailBadge(Icons.timer, '${widget.item.preparationTimeMinutes} mins'),
                      const SizedBox(width: 12),
                      _buildDetailBadge(Icons.local_fire_department, '${widget.item.calories} kcal'),
                      const SizedBox(width: 12),
                      _buildDetailBadge(Icons.category, widget.item.category),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.item.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Price', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          Text(
                            '\$${widget.item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.extrabold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.neonGlowShadow(AppTheme.primaryColor),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              api.addToCart(widget.item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.item.name} added to cart!'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              trans.translate('add_to_cart'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// Custom 3D Projection Painter
class Food3dPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final Color color;

  Food3dPainter({required this.rotationX, required this.rotationY, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw bottom plate ellipse (3D projection)
    final platePoints = <Offset>[];
    const numPlatePoints = 40;
    const plateRadiusX = 110.0;
    const plateRadiusZ = 50.0;

    for (int i = 0; i <= numPlatePoints; i++) {
      double theta = (i * 2 * math.pi) / numPlatePoints;
      // 3D coordinates
      double x = plateRadiusX * math.cos(theta);
      double y = 40.0; // Y offset downwards
      double z = plateRadiusZ * math.sin(theta);

      // Rotate around X axis
      double rx1 = x;
      double ry1 = y * math.cos(rotationX) - z * math.sin(rotationX);
      double rz1 = y * math.sin(rotationX) + z * math.cos(rotationX);

      // Rotate around Y axis
      double rx2 = rx1 * math.cos(rotationY) + rz1 * math.sin(rotationY);
      double ry2 = ry1;

      platePoints.add(center + Offset(rx2, ry2));
    }

    final platePath = Path()..moveTo(platePoints.first.dx, platePoints.first.dy);
    for (var pt in platePoints) {
      platePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(platePath, paint);

    // Draw stylized dish / food mesh (nested glowing circles)
    final foodPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final foodOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // We represent food as stacked rings (creating a dome shape)
    for (double h = -20; h < 40; h += 12) {
      final ringPoints = <Offset>[];
      final radius = 70.0 * math.cos((h / 40.0) * (math.pi / 2));
      const ringSegs = 20;

      for (int i = 0; i <= ringSegs; i++) {
        double theta = (i * 2 * math.pi) / ringSegs;
        double x = radius * math.cos(theta);
        double y = h;
        double z = radius * math.sin(theta);

        // Rotate X
        double rx1 = x;
        double ry1 = y * math.cos(rotationX) - z * math.sin(rotationX);
        double rz1 = y * math.sin(rotationX) + z * math.cos(rotationX);

        // Rotate Y
        double rx2 = rx1 * math.cos(rotationY) + rz1 * math.sin(rotationY);
        double ry2 = ry1;

        ringPoints.add(center + Offset(rx2, ry2));
      }

      final ringPath = Path()..moveTo(ringPoints.first.dx, ringPoints.first.dy);
      for (var pt in ringPoints) {
        ringPath.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(ringPath, foodOutline);
      if (h % 24 == 0) {
        canvas.drawPath(ringPath, foodPaint);
      }
    }

    // Draw rising steam particles
    final steamPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int s = 0; s < 4; s++) {
      double t = (DateTime.now().millisecondsSinceEpoch / 1000.0 + s * 1.5) % 3.0;
      double h = -20 - (t * 30);
      double offsetVal = math.sin(t * 4 + s) * 10;
      double x = offsetVal;
      double z = 0.0;

      double rx1 = x;
      double ry1 = h * math.cos(rotationX) - rz(z, rotationX);
      double rx2 = rx1 * math.cos(rotationY);

      canvas.drawCircle(center + Offset(rx2, ry1), 2.0 + t, steamPaint);
    }
  }

  double rz(double z, double angle) => z * math.cos(angle);

  @override
  bool shouldRepaint(covariant Food3dPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX || oldDelegate.rotationY != rotationY;
  }
}
