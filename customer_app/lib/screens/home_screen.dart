import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'details_screen.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _simulateQrScan() {
    final api = Provider.of<ApiService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Simulate Table QR Scan', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pointing camera at table QR...', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 16),
            Center(
              child: Icon(Icons.qr_code_scanner, size: 80, color: AppTheme.primaryColor),
            ),
          ],
        ),
        actions: List.generate(3, (index) {
          int tableNum = index + 1;
          return TextButton(
            onPressed: () {
              api.setTable('Table $tableNum');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scanned successfully! Connected to Table $tableNum'),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              );
            },
            child: Text('Table $tableNum', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final socket = Provider.of<SocketService>(context);
    final translation = Provider.of<TranslationService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtered menu logic
    final filteredMenu = api.menuItems.where((item) {
      bool matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
      bool matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    // AI recommendation fetching
    final aiRecommendations = api.getAiRecommendations();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // Top Header + Language Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        Text(
                          translation.translate('app_title'),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                        ),
                      ],
                    ),
                    _buildLanguageDropdown(translation),
                  ],
                ),
                const SizedBox(height: 20),

                // Loyalty Dashboard Card
                _buildLoyaltyCard(api, translation),
                const SizedBox(height: 20),

                // Search Bar + QR Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.premiumShadow,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: translation.translate('search_food'),
                            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: Colors.white30),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _simulateQrScan,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.neonGlowShadow(AppTheme.primaryColor),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // AI Food Recommendations Slider
                if (aiRecommendations.isNotEmpty && _searchQuery.isEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: AppTheme.primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        translation.translate('recommended'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: aiRecommendations.length,
                      itemBuilder: (context, index) {
                        final rec = aiRecommendations[index];
                        return _buildRecommendationCard(rec);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Categories Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translation.translate('browse_menu'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                    ),
                    if (api.selectedTable != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Dine-in: ${api.selectedTable}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Mains', 'Starters', 'Desserts', 'Beverages'].map((cat) {
                      bool isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Menu List
                ...filteredMenu.map(
                  (item) => MenuItemTile(
                    item: item,
                    onAdd: () {
                      api.addToCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(item: item),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80), // bottom spacing for FAB
              ],
            ),
          ),
          // Floating Cart + Chat Action Buttons
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  heroTag: 'chat_fab',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  backgroundColor: AppTheme.secondaryColor,
                  child: const Icon(Icons.chat_bubble, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FloatingActionButton(
                      heroTag: 'cart_fab',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    if (api.cart.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.white,
                          child: Text(
                            '${api.cart.length}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(TranslationService trans) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButton<String>(
        value: trans.currentLocale,
        dropdownColor: AppTheme.darkSurface,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English 🇬🇧', style: TextStyle(fontSize: 12, color: Colors.white))),
          DropdownMenuItem(value: 'si', child: Text('Sinhala 🇱🇰', style: TextStyle(fontSize: 12, color: Colors.white))),
          DropdownMenuItem(value: 'ta', child: Text('Tamil 🇮🇳', style: TextStyle(fontSize: 12, color: Colors.white))),
        ],
        onChanged: (lang) {
          if (lang != null) trans.setLocale(lang);
        },
      ),
    );
  }

  Widget _buildLoyaltyCard(ApiService api, TranslationService trans) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: AppTheme.accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trans.translate('loyalty_points'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    '${api.loyaltyPoints} PTS',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.extrabold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Gold Status', style: TextStyle(color: AppTheme.accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
