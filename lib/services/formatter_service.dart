import 'package:intl/intl.dart';

class FormatterService {
  /// Format a quantity with up to 2 decimal places.
  /// If the quantity is an integer, it won't display trailing zeros (e.g., 5.00 -> 5 or 5.25 -> 5.25).
  static String formatQuantity(double quantity) {
    if (quantity.isNaN || quantity.isInfinite) return '0';
    
    // Round to 2 decimal places
    double rounded = double.parse(quantity.toStringAsFixed(2));
    
    // Use NumberFormat for French style spacing (e.g., 1 250.5)
    final format = NumberFormat('#,##0.##', 'fr_FR');
    return format.format(rounded).replaceAll('\u00A0', ' ');
  }

  /// Format currency amount based on currency type (FCFA, EUR, USD).
  /// FCFA is formatted with no decimal points. EUR/USD are formatted with 2 decimal points.
  static String formatCurrency(double amount, String currency) {
    if (amount.isNaN || amount.isInfinite) return '0 $currency';
    
    String formattedAmount;
    if (currency.toUpperCase() == 'FCFA' || currency.toUpperCase() == 'MGA' || currency.toUpperCase() == 'AR') {
      // Rounded to integer
      final format = NumberFormat('#,##0', 'fr_FR');
      formattedAmount = format.format(amount.round()).replaceAll('\u00A0', ' ');
    } else {
      // 2 decimals
      final format = NumberFormat('#,##0.00', 'fr_FR');
      formattedAmount = format.format(amount).replaceAll('\u00A0', ' ');
    }
    
    return '$formattedAmount $currency';
  }

  /// Simple date formatting in French (e.g., 24/06/2026)
  static String formatDate(DateTime date) {
    final format = DateFormat('dd/MM/yyyy', 'fr_FR');
    return format.format(date);
  }
}
