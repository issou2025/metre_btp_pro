import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project_model.dart';
import '../models/unit_price_model.dart';
import '../models/company_model.dart';

class StorageService {
  static const String _projectsBoxName = 'projects_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _unitPricesBoxName = 'unit_prices_box';

  /// Initialize Hive and open necessary boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_projectsBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox(_unitPricesBoxName);
    
    // Seed default prices if empty
    await seedDefaultPricesIfNeeded();
  }

  // ==========================================
  // PROJECTS CRUD
  // ==========================================

  static List<Project> getProjects() {
    final box = Hive.box(_projectsBoxName);
    final List<Project> projects = [];
    
    for (var key in box.keys) {
      final rawValue = box.get(key);
      if (rawValue != null) {
        try {
          final Map<dynamic, dynamic> map = rawValue is String 
              ? jsonDecode(rawValue) 
              : Map<dynamic, dynamic>.from(rawValue);
          projects.add(Project.fromMap(map));
        } catch (e) {
          print("Error parsing project $key: $e");
        }
      }
    }
    
    // Sort projects: newest updated first
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  static Future<void> saveProject(Project project) async {
    final box = Hive.box(_projectsBoxName);
    final map = project.toMap();
    await box.put(project.id, map);
  }

  static Future<void> deleteProject(String id) async {
    final box = Hive.box(_projectsBoxName);
    await box.delete(id);
  }

  // ==========================================
  // COMPANY INFO & SETTINGS
  // ==========================================

  static CompanyInfo getCompanyInfo() {
    final box = Hive.box(_settingsBoxName);
    final raw = box.get('company_info');
    if (raw == null) {
      return CompanyInfo(
        name: 'Mon Entreprise BTP',
        phone: '+226 00 00 00 00',
        email: 'contact@entreprise.com',
        address: 'Ouagadougou, Burkina Faso',
        nif: 'NIF123456789',
      );
    }
    final map = Map<dynamic, dynamic>.from(raw);
    return CompanyInfo.fromMap(map);
  }

  static Future<void> saveCompanyInfo(CompanyInfo info) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('company_info', info.toMap());
  }

  static String getDefaultCurrency() {
    final box = Hive.box(_settingsBoxName);
    return box.get('default_currency', defaultValue: 'FCFA').toString();
  }

  static Future<void> saveDefaultCurrency(String currency) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('default_currency', currency);
  }

  static double getDefaultLossPercentage() {
    final box = Hive.box(_settingsBoxName);
    return (box.get('default_loss_percentage', defaultValue: 5.0) as num).toDouble();
  }

  static Future<void> saveDefaultLossPercentage(double percentage) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('default_loss_percentage', percentage);
  }

  static String getThemeMode() {
    final box = Hive.box(_settingsBoxName);
    return box.get('theme_mode', defaultValue: 'Système').toString();
  }

  static Future<void> saveThemeMode(String mode) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('theme_mode', mode);
  }

  static String getServerIp() {
    final box = Hive.box(_settingsBoxName);
    return box.get('server_ip', defaultValue: 'localhost').toString();
  }

  static Future<void> saveServerIp(String ip) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('server_ip', ip);
  }

  // ==========================================
  // UNIT PRICES CRUD
  // ==========================================

  static List<UnitPrice> getUnitPrices() {
    final box = Hive.box(_unitPricesBoxName);
    final List<UnitPrice> prices = [];
    
    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final map = Map<dynamic, dynamic>.from(raw);
        prices.add(UnitPrice.fromMap(map));
      }
    }
    
    return prices;
  }

  static Future<void> saveUnitPrice(UnitPrice price) async {
    final box = Hive.box(_unitPricesBoxName);
    await box.put(price.id, price.toMap());
  }

  static Future<void> saveUnitPrices(List<UnitPrice> prices) async {
    final box = Hive.box(_unitPricesBoxName);
    final Map<String, dynamic> entries = {};
    for (var price in prices) {
      entries[price.id] = price.toMap();
    }
    await box.putAll(entries);
  }

  static Future<void> deleteUnitPrice(String id) async {
    final box = Hive.box(_unitPricesBoxName);
    await box.delete(id);
  }

  // ==========================================
  // INITIAL SEEDING
  // ==========================================

  static Future<void> seedDefaultPricesIfNeeded() async {
    final box = Hive.box(_unitPricesBoxName);
    if (box.isEmpty) {
      final List<UnitPrice> defaults = [
        UnitPrice(id: 'p_fouille', designation: 'Fouille', category: 'Terrassements', unit: 'm³', price: 2500, currency: 'FCFA'),
        UnitPrice(id: 'p_remblai', designation: 'Remblai', category: 'Terrassements', unit: 'm³', price: 3000, currency: 'FCFA'),
        UnitPrice(id: 'p_beton_prop', designation: 'Béton de propreté', category: 'Béton', unit: 'm³', price: 60000, currency: 'FCFA'),
        UnitPrice(id: 'p_beton_arme', designation: 'Béton armé', category: 'Béton', unit: 'm³', price: 80000, currency: 'FCFA'),
        UnitPrice(id: 'p_coffrage', designation: 'Coffrage', category: 'Coffrage', unit: 'm²', price: 3500, currency: 'FCFA'),
        UnitPrice(id: 'p_acier', designation: 'Acier', category: 'Ferraillage', unit: 'kg', price: 450, currency: 'FCFA'),
        UnitPrice(id: 'p_parpaing_15', designation: 'Parpaing 15', category: 'Maçonnerie', unit: 'u', price: 400, currency: 'FCFA'),
        UnitPrice(id: 'p_maconnerie', designation: 'Maçonnerie', category: 'Maçonnerie', unit: 'm²', price: 7500, currency: 'FCFA'),
        UnitPrice(id: 'p_enduit', designation: 'Enduit', category: 'Finitions', unit: 'm²', price: 2500, currency: 'FCFA'),
        UnitPrice(id: 'p_chape', designation: 'Chape', category: 'Finitions', unit: 'm²', price: 2500, currency: 'FCFA'),
        UnitPrice(id: 'p_carrelage', designation: 'Carrelage', category: 'Finitions', unit: 'm²', price: 7000, currency: 'FCFA'),
        UnitPrice(id: 'p_peinture', designation: 'Peinture', category: 'Finitions', unit: 'm²', price: 1500, currency: 'FCFA'),
        UnitPrice(id: 'p_faux_plafond', designation: 'Faux plafond', category: 'Finitions', unit: 'm²', price: 9000, currency: 'FCFA'),
        UnitPrice(id: 'p_toiture_tole', designation: 'Toiture tôle', category: 'Toiture', unit: 'm²', price: 12000, currency: 'FCFA'),
        UnitPrice(id: 'p_porte_met', designation: 'Porte métallique', category: 'Menuiseries', unit: 'u', price: 75000, currency: 'FCFA'),
        UnitPrice(id: 'p_fenetre_alu', designation: 'Fenêtre aluminium', category: 'Menuiseries', unit: 'm²', price: 45000, currency: 'FCFA'),
        UnitPrice(id: 'p_point_lum', designation: 'Point lumineux', category: 'Électricité', unit: 'u', price: 12000, currency: 'FCFA'),
        UnitPrice(id: 'p_prise', designation: 'Prise', category: 'Électricité', unit: 'u', price: 10000, currency: 'FCFA'),
        UnitPrice(id: 'p_sanitaire', designation: 'Appareil sanitaire', category: 'Plomberie', unit: 'u', price: 50000, currency: 'FCFA'),
      ];
      await saveUnitPrices(defaults);
    }
  }
}
