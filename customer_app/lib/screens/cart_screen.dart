import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  OrderType _selectedOrderType = OrderType.delivery;
  final TextEditingController _tableController = TextEditingController();
  bool _isProcessingPayment = false;

  // Reservation Form State
  int _guestCount = 2;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    if (api.selectedTable != null) {
      _selectedOrderType = OrderType.dineIn;
      _tableController.text = api.selectedTable!;
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentAndCheckout() async {
    final api = Provider.of<ApiService>(context, listen: false);
    if (api.cart.isEmpty) return;

    setState(() {
      _isProcessingPayment = true;
    });

    // 1. Process Stripe Payment Simulation
    bool paymentSuccess = await api.processStripePayment(api.cartTotal);

    if (paymentSuccess) {
      // 2. Submit order to server
      if (_selectedOrderType == OrderType.dineIn) {
        api.setTable(_tableController.text);
      }
      final submittedOrder = await api.placeOrder(_selectedOrderType);

      setState(() {
        _isProcessingPayment = false;
      });

      if (mounted && submittedOrder != null) {
        // Show success animation/dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 28),
                SizedBox(width: 10),
                Text('Payment Success', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
              ],
            ),
            content: Text(
              'Your order of \$${submittedOrder.totalAmount.toStringAsFixed(2)} was successfully processed via Stripe. Preparing food now!',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close cart
                  if (_selectedOrderType == OrderType.delivery) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackingScreen(orderId: submittedOrder.orderId),
                      ),
                    );
                  }
                },
                child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        _isProcessingPayment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    }
  }

  Future<void> _handleTableBooking() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final success = await api.bookTable(_guestCount, _selectedDate);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table reservation confirmed for $_guestCount guests!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final trans = Provider.of<TranslationService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(trans.translate('cart'), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
        elevation: 0,
      ),
      body: api.cart.isEmpty
          ? _buildEmptyCartView(trans)
          : Column(
              children: [
                // Cart list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...api.cart.map((item) => _buildCartItemRow(item, api)),
                      const Divider(color: Colors.white10, height: 32),
                      
                      // Order Type selector
                      const Text(
                        'Order Mode',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOrderTypeButton(OrderType.delivery, 'Delivery', Icons.delivery_dining),
                          const SizedBox(width: 8),
                          _buildOrderTypeButton(OrderType.takeaway, 'Takeaway', Icons.shopping_bag),
                          const SizedBox(width: 8),
                          _buildOrderTypeButton(OrderType.dineIn, 'Dine-In', Icons.restaurant),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Conditional inputs
                      if (_selectedOrderType == OrderType.dineIn) ...[
                        const Text(
                          'Table Selection',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _tableController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter Table Number (e.g. Table 4)',
                            hintStyle: const TextStyle(color: Colors.white30),
                            fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Loyalty Summary
                      GlassCard(
                        borderRadius: 16,
                        child: Row(
                          children: [
                            const Icon(Icons.card_membership, color: AppTheme.accentColor, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Earn Loyalty Points: +${(api.cartTotal * 0.1).toInt()} pts',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                  Text(
                                    'Your balance: ${api.loyaltyPoints} pts',
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Optional Table Reservation Option
                      OutlinedButton.icon(
                        onPressed: () => _showReservationSheet(trans),
                        icon: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                        label: Text(trans.translate('reservation'), style: const TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer Checkout Card
                _buildCheckoutFooter(api, trans),
              ],
            ),
    );
  }

  Widget _buildEmptyCartView(TranslationService trans) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add items from the menu to get started', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(OrderItem item, ApiService api) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.menuItem.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('\$${item.menuItem.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryColor)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white60),
                onPressed: () => api.updateCartQuantity(item.menuItem, item.quantity - 1),
              ),
              Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white60),
                onPressed: () => api.updateCartQuantity(item.menuItem, item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeButton(OrderType type, String title, IconData icon) {
    bool isSelected = _selectedOrderType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOrderType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutFooter(ApiService api, TranslationService trans) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 20),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.white54, fontSize: 14)),
              Text('\$${api.cartTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax & Services', style: TextStyle(color: Colors.white54, fontSize: 14)),
              Text('Free', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text(
                '\$${api.cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 22, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessingPayment ? null : _handlePaymentAndCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isProcessingPayment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(trans.translate('stripe_pay'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReservationSheet(TranslationService trans) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Online Table Reservation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Guest Selector
                  const Text('Number of Guests', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      int val = index + 1;
                      bool isSel = _guestCount == val;
                      return ChoiceChip(
                        label: Text('$val'),
                        selected: isSel,
                        onSelected: (_) {
                          setSheetState(() => _guestCount = val);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // DateTime Picker Simulator
                  const Text('Date & Time', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setSheetState(() => _selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at 7:00 PM',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleTableBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: Text(
                        trans.translate('book_now'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
