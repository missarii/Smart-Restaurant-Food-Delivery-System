import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;

  const TrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _riderMovementController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    // Simulate rider taking 30 seconds to arrive in demo mode
    _riderMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_riderMovementController)
      ..addListener(() {
        setState(() {});
      });
    _riderMovementController.forward();
  }

  @override
  void dispose() {
    _riderMovementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trans = Provider.of<TranslationService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Predefined path coordinates for vector map
    final pathPoints = [
      const Offset(60, 240),   // Restaurant
      const Offset(120, 240),
      const Offset(120, 120),
      const Offset(220, 120),
      const Offset(220, 50),    // Customer Home
    ];

    // Compute current rider position along the path segment
    Offset riderPos = _getPositionAlongPath(pathPoints, _progressAnimation.value);
    int remainingMinutes = (10 * (1.0 - _progressAnimation.value)).ceil();

    return Scaffold(
      body: Stack(
        children: [
          // Custom Map Painter Background
          Positioned.fill(
            child: CustomPaint(
              painter: VectorMapPainter(
                pathPoints: pathPoints,
                riderPosition: riderPos,
                isDark: isDark,
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Heading / Status
          Positioned(
            top: 50,
            left: 80,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black80,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                'Order Status: ${remainingMinutes > 0 ? "On The Way" : "Delivered"}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          // Rider Bottom Info Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=120&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kamal Silva',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              'Delivery Partner • Rating 4.9',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppTheme.secondaryColor),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, color: AppTheme.accentColor, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trans.translate('eta_prediction'), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                              Text(
                                remainingMinutes > 0 ? '$remainingMinutes Mins' : 'Rider Arrived',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '#${widget.orderId.substring(0, math.min(10, widget.orderId.length))}',
                        style: const TextStyle(color: Colors.white30, fontSize: 12),
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

  Offset _getPositionAlongPath(List<Offset> path, double progress) {
    if (path.isEmpty) return Offset.zero;
    if (progress <= 0.0) return path.first;
    if (progress >= 1.0) return path.last;

    double totalLength = 0.0;
    List<double> segmentLengths = [];
    for (int i = 0; i < path.length - 1; i++) {
      double len = (path[i + 1] - path[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    double targetDist = totalLength * progress;
    double currentDist = 0.0;

    for (int i = 0; i < segmentLengths.length; i++) {
      if (currentDist + segmentLengths[i] >= targetDist) {
        double segProgress = (targetDist - currentDist) / segmentLengths[i];
        return Offset.lerp(path[i], path[i + 1], segProgress)!;
      }
      currentDist += segmentLengths[i];
    }
    return path.last;
  }
}

class VectorMapPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final Offset riderPosition;
  final bool isDark;

  VectorMapPainter({
    required this.pathPoints,
    required this.riderPosition,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background (sleek dark mode grid/map or light mode map)
    final bgPaint = Paint()..color = isDark ? const Color(0xFF14161C) : const Color(0xFFF5F7FA);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2129) : const Color(0xFFE2E8F0)
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadCenterPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3241) : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw Map Roads
    final roadPath = Path()..moveTo(pathPoints.first.dx, pathPoints.first.dy);
    for (var pt in pathPoints) {
      roadPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(roadPath, roadPaint);
    canvas.drawPath(roadPath, roadCenterPaint);

    // Draw route path traveled so far
    final routePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.5)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final traveledPath = Path()..moveTo(pathPoints.first.dx, pathPoints.first.dy);
    traveledPath.lineTo(riderPosition.dx, riderPosition.dy);
    canvas.drawPath(traveledPath, routePaint);

    // Draw Restaurant Pin
    final restPaint = Paint()..color = AppTheme.secondaryColor;
    canvas.drawCircle(pathPoints.first, 12, restPaint);
    canvas.drawCircle(pathPoints.first, 6, Paint()..color = Colors.white);

    // Draw Destination Pin (Customer Home)
    final homePaint = Paint()..color = AppTheme.primaryColor;
    canvas.drawCircle(pathPoints.last, 12, homePaint);
    canvas.drawCircle(pathPoints.last, 6, Paint()..color = Colors.white);

    // Draw Rider bike pin
    final riderPaint = Paint()..color = AppTheme.accentColor;
    canvas.drawCircle(riderPosition, 14, riderPaint);
    canvas.drawCircle(riderPosition, 12, Paint()..color = Colors.black);
    // Bike icon mock
    final iconPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawCircle(riderPosition, 4, iconPaint);
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) {
    return oldDelegate.riderPosition != riderPosition || oldDelegate.isDark != isDark;
  }
}
