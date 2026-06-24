import '../models/unit_price_model.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';

class PriceService {
  /// Retrieve all available unit prices (customized or default).
  static List<UnitPrice> getAllPrices() {
    return StorageService.getUnitPrices();
  }

  /// Get the unit price of a designation.
  /// If it doesn't exist, returns a fallback UnitPrice with price = 0.
  static UnitPrice getPriceFor({
    required String designation,
    required String category,
    required String defaultUnit,
    required String currency,
  }) {
    final prices = getAllPrices();
    
    // Find exact match by designation and category
    final match = prices.firstWhere(
      (p) => p.designation.toLowerCase() == designation.toLowerCase() &&
             p.category.toLowerCase() == category.toLowerCase(),
      orElse: () {
        // Find match by designation only
        return prices.firstWhere(
          (p) => p.designation.toLowerCase() == designation.toLowerCase(),
          orElse: () => UnitPrice(
            id: '',
            designation: designation,
            category: category,
            unit: defaultUnit,
            price: 0.0,
            currency: currency,
          ),
        );
      },
    );

    return match;
  }

  /// Save or update a unit price in the database.
  static Future<void> savePrice(UnitPrice price) async {
    String id = price.id;
    if (id.isEmpty) {
      id = const Uuid().v4();
    }
    final toSave = price.copyWith(id: id);
    await StorageService.saveUnitPrice(toSave);
  }

  /// Delete a custom unit price.
  static Future<void> deletePrice(String id) async {
    await StorageService.deleteUnitPrice(id);
  }
  
  /// Reset all unit prices to default.
  static Future<void> resetToDefaults() async {
    final box = StorageService.getUnitPrices();
    for (var p in box) {
      await StorageService.deleteUnitPrice(p.id);
    }
    await StorageService.seedDefaultPricesIfNeeded();
  }
}
