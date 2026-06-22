import 'package:flutter/material.dart';

class TranslationService extends ChangeNotifier {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  void setLocale(String locale) {
    if (locale == 'en' || locale == 'si' || locale == 'ta') {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Smart Dine & Delivery',
      'browse_menu': 'Browse Menu',
      'search_food': 'Search for delicious food...',
      'cart': 'Your Cart',
      'add_to_cart': 'Add to Cart',
      'checkout': 'Proceed to Checkout',
      'stripe_pay': 'Pay with Stripe',
      'order_history': 'Order History',
      'loyalty_points': 'Loyalty Points',
      'reservation': 'Book a Table',
      'qr_order': 'Scan QR / Table Order',
      'live_chat': 'Chat with Host',
      'rider_tracking': 'Live Rider Tracking',
      'eta_prediction': 'Estimated Delivery Time',
      'popular': 'Popular',
      'recommended': 'Recommended',
      'spicy': 'Spicy',
      'preparation_time': 'Prep Time',
      'table_no': 'Table Number',
      'number_of_guests': 'Number of Guests',
      'book_now': 'Book Now',
      'chat_hint': 'Type a message...',
      'order_status': 'Order Status',
      'earnings': 'Earnings Dashboard',
      'accept_order': 'Accept Delivery',
      'ready_to_serve': 'Ready to Serve',
      'kitchen_queue': 'Kitchen Orders',
      'preparing': 'Preparing',
      'ready': 'Ready',
      'completed': 'Completed',
    },
    'si': {
      'app_title': 'ස්මාර්ට් ඩයින් සහ බෙදාහැරීම',
      'browse_menu': 'මෙනුව බලන්න',
      'search_food': 'රසවත් ආහාර සොයන්න...',
      'cart': 'ඔබේ කරත්තය',
      'add_to_cart': 'කරත්තයට එක් කරන්න',
      'checkout': 'පියවීමට යන්න',
      'stripe_pay': 'ස්ට්‍රයිප් මගින් ගෙවන්න',
      'order_history': 'ඇණවුම් ඉතිහාසය',
      'loyalty_points': 'ලෝයල්ටි ලකුණු',
      'reservation': 'මේසයක් වෙන්කරවා ගන්න',
      'qr_order': 'QR පරිලෝකනය කරන්න',
      'live_chat': 'පරිපාලක සමඟ කතාබස්',
      'rider_tracking': 'රයිඩර් සජීවී ලුහුබැඳීම',
      'eta_prediction': 'ඇස්තමේන්තුගත කාලය',
      'popular': 'ජනප්‍රිය',
      'recommended': 'නිර්දේශිත',
      'spicy': 'සැර',
      'preparation_time': 'සූදානම් වීමේ කාලය',
      'table_no': 'මේස අංකය',
      'number_of_guests': 'අමුත්තන් ගණන',
      'book_now': 'දැන් වෙන්කරන්න',
      'chat_hint': 'පණිවිඩයක් ලියන්න...',
      'order_status': 'ඇණවුම් තත්ත්වය',
      'earnings': 'උපයීම් උපකරණ පුවරුව',
      'accept_order': 'භාරගන්න',
      'ready_to_serve': 'පිළිගැන්වීමට සූදානම්',
      'kitchen_queue': 'කුස්සියේ ඇණවුම්',
      'preparing': 'සූදානම් කරමින්',
      'ready': 'සූදානම්',
      'completed': 'සම්පූර්ණයි',
    },
    'ta': {
      'app_title': 'ஸ்மார்ட் டைன் & டெலிவரி',
      'browse_menu': 'மெனுவை உலாவுக',
      'search_food': 'சுவையான உணவைத் தேடுங்கள்...',
      'cart': 'உங்கள் கூடை',
      'add_to_cart': 'கூடையில் சேர்',
      'checkout': 'செக் அவுட் செய்ய தொடரவும்',
      'stripe_pay': 'ஸ்ட்ரைப் மூலம் செலுத்துங்கள்',
      'order_history': 'ஆர்டர் வரலாறு',
      'loyalty_points': 'லாயல்டி புள்ளிகள்',
      'reservation': 'ஒரு மேசையை முன்பதிவு செய்க',
      'qr_order': 'QR ஸ்கேன் / மேசை ஆர்டர்',
      'live_chat': 'நிர்வாகியுடன் அரட்டை',
      'rider_tracking': 'நேரடி ரைடர் கண்காணிப்பு',
      'eta_prediction': 'மதிப்பிடப்பட்ட நேரம்',
      'popular': 'பிரபலமானவை',
      'recommended': 'பரிந்துரைக்கப்பட்டது',
      'spicy': 'காரமான',
      'preparation_time': 'தயாரிப்பு நேரம்',
      'table_no': 'மேசை எண்',
      'number_of_guests': 'விருந்தினர்களின் எண்ணிக்கை',
      'book_now': 'இப்போது முன்பதிவு செய்',
      'chat_hint': 'செய்தியை தட்டச்சு செய்க...',
      'order_status': 'ஆர்டர் நிலை',
      'earnings': 'வருவாய் டாஷ்போர்டு',
      'accept_order': 'ஏற்கவும்',
      'ready_to_serve': 'பரிமாற தயார்',
      'kitchen_queue': 'சமையலறை ஆர்டர்கள்',
      'preparing': 'தயாரிக்கப்படுகிறது',
      'ready': 'தயார்',
      'completed': 'முடிந்தது',
    }
  };

  String translate(String key) {
    return _localizedValues[_currentLocale]?[key] ?? key;
  }
}
