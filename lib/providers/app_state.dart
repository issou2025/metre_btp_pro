import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/measurement_item_model.dart';
import '../models/unit_price_model.dart';
import '../models/company_model.dart';
import '../services/storage_service.dart';
import '../services/price_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class AppState extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _currentProject;
  List<UnitPrice> _unitPrices = [];
  CompanyInfo _companyInfo = CompanyInfo();
  String _defaultCurrency = 'FCFA';
  double _defaultLossPercentage = 5.0;
  String _themeMode = 'Système';
  String _serverIp = 'localhost';

  // Getters
  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  List<UnitPrice> get unitPrices => _unitPrices;
  CompanyInfo get companyInfo => _companyInfo;
  String get defaultCurrency => _defaultCurrency;
  double get defaultLossPercentage => _defaultLossPercentage;
  String get themeMode => _themeMode;
  String get serverIp => _serverIp;

  /// Load all data from StorageService into the provider's state.
  void loadAllData() {
    _projects = StorageService.getProjects();
    _unitPrices = StorageService.getUnitPrices();
    _companyInfo = StorageService.getCompanyInfo();
    _defaultCurrency = StorageService.getDefaultCurrency();
    _defaultLossPercentage = StorageService.getDefaultLossPercentage();
    _themeMode = StorageService.getThemeMode();
    _serverIp = StorageService.getServerIp();

    if (_currentProject != null) {
      // Refresh current project from local storage list if it changed
      final match = _projects.firstWhere(
        (p) => p.id == _currentProject!.id,
        orElse: () => _currentProject!,
      );
      _currentProject = match;
    }
    
    notifyListeners();
    sendTelemetry();
  }

  // ==========================================
  // PROJECT OPERATIONS
  // ==========================================

  Future<void> createProject({
    required String name,
    required String client,
    required String location,
    required DateTime date,
    required String type,
    required String currency,
    required String observations,
  }) async {
    final newProj = Project(
      id: const Uuid().v4(),
      name: name,
      client: client,
      location: location,
      date: date,
      type: type,
      currency: currency,
      observations: observations,
      items: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await StorageService.saveProject(newProj);
    loadAllData();
    logActivity("Création de projet", "Nom: $name, Client: $client, Localisation: $location");
  }

  Future<void> updateProject(Project project) async {
    final updated = project.copyWith(updatedAt: DateTime.now());
    await StorageService.saveProject(updated);
    if (_currentProject?.id == project.id) {
      _currentProject = updated;
    }
    loadAllData();
    logActivity("Mise à jour de projet", "Nom: ${project.name}");
  }

  Future<void> deleteProject(String projectId) async {
    final pName = _projects.firstWhere((p) => p.id == projectId, orElse: () => Project(id: '', name: 'Inconnu', client: '', location: '', date: DateTime.now(), type: '', currency: '', observations: '', items: [], createdAt: DateTime.now(), updatedAt: DateTime.now())).name;
    await StorageService.deleteProject(projectId);
    if (_currentProject?.id == projectId) {
      _currentProject = null;
    }
    loadAllData();
    logActivity("Suppression de projet", "Nom: $pName (ID: $projectId)");
  }

  void selectProject(Project? project) {
    _currentProject = project;
    notifyListeners();
  }

  Future<void> duplicateProject(Project project) async {
    final duplicated = Project(
      id: const Uuid().v4(),
      name: "${project.name} (Copie)",
      client: project.client,
      location: project.location,
      date: project.date,
      type: project.type,
      currency: project.currency,
      observations: project.observations,
      items: project.items.map((item) => item.copyWith(id: const Uuid().v4())).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await StorageService.saveProject(duplicated);
    loadAllData();
    logActivity("Duplication de projet", "Dupliqué: ${project.name} -> ${duplicated.name}");
  }

  // ==========================================
  // MEASUREMENT ITEMS OPERATIONS (PROJECT SPECIFIC)
  // ==========================================

  Future<void> addMeasurementItem(String projectId, MeasurementItem item) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final updatedItems = List<MeasurementItem>.from(project.items)..add(item);
    final updatedProj = project.copyWith(items: updatedItems, updatedAt: DateTime.now());
    await StorageService.saveProject(updatedProj);
    loadAllData();
    logActivity("Calcul enregistré", "Projet: ${project.name}, Tâche: ${item.designation}, Qté: ${item.quantity.toStringAsFixed(2)} ${item.unit}");
  }

  Future<void> updateMeasurementItem(String projectId, MeasurementItem item) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final updatedItems = project.items.map((i) => i.id == item.id ? item : i).toList();
    final updatedProj = project.copyWith(items: updatedItems, updatedAt: DateTime.now());
    await StorageService.saveProject(updatedProj);
    loadAllData();
  }

  Future<void> deleteMeasurementItem(String projectId, String itemId) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final deletedItem = project.items.firstWhere((i) => i.id == itemId);
    final updatedItems = project.items.where((i) => i.id != itemId).toList();
    final updatedProj = project.copyWith(items: updatedItems, updatedAt: DateTime.now());
    await StorageService.saveProject(updatedProj);
    loadAllData();
    logActivity("Ligne de quantité supprimée", "Projet: ${project.name}, Tâche: ${deletedItem.designation}");
  }

  Future<void> duplicateMeasurementItem(String projectId, MeasurementItem item) async {
    final project = _projects.firstWhere((p) => p.id == projectId);
    final duplicatedItem = item.copyWith(
      id: const Uuid().v4(),
      designation: "${item.designation} (Copie)",
    );
    final updatedItems = List<MeasurementItem>.from(project.items)..add(duplicatedItem);
    final updatedProj = project.copyWith(items: updatedItems, updatedAt: DateTime.now());
    await StorageService.saveProject(updatedProj);
    loadAllData();
    logActivity("Ligne de quantité dupliquée", "Projet: ${project.name}, Tâche: ${item.designation}");
  }

  // ==========================================
  // UNIT PRICE OPERATIONS
  // ==========================================

  Future<void> updateUnitPrice(UnitPrice price) async {
    await PriceService.savePrice(price);
    loadAllData();
  }

  Future<void> deleteUnitPrice(String id) async {
    await PriceService.deletePrice(id);
    loadAllData();
  }

  Future<void> resetPricesToDefaults() async {
    await PriceService.resetToDefaults();
    loadAllData();
  }

  // ==========================================
  // SETTINGS & COMPANY INFO OPERATIONS
  // ==========================================

  Future<void> updateCompanyInfo(CompanyInfo info) async {
    await StorageService.saveCompanyInfo(info);
    loadAllData();
  }

  Future<void> updateSettings({
    required String currency,
    required double lossPercentage,
    required String themeMode,
    required String serverIp,
  }) async {
    await StorageService.saveDefaultCurrency(currency);
    await StorageService.saveDefaultLossPercentage(lossPercentage);
    await StorageService.saveThemeMode(themeMode);
    await StorageService.saveServerIp(serverIp);
    loadAllData();
  }

  Future<void> sendTelemetry() async {
    try {
      final url = Uri.parse('http://$_serverIp:8000/ping');
      String platformName = "Web Browser";
      if (!kIsWeb) {
        try {
          if (io.Platform.isAndroid) {
            platformName = "Android APK";
          } else if (io.Platform.isIOS) {
            platformName = "iOS App";
          } else {
            platformName = "${io.Platform.operatingSystem} App";
          }
        } catch (_) {
          platformName = "Application native";
        }
      }
      
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'company_name': _companyInfo.name,
          'phone': _companyInfo.phone,
          'email': _companyInfo.email,
          'device': platformName,
          'projects_count': _projects.length,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Fail silently
    }
  }

  Future<void> logActivity(String action, String details) async {
    try {
      final url = Uri.parse('http://$_serverIp:8000/log_activity');
      String platformName = "Web Browser";
      if (!kIsWeb) {
        try {
          if (io.Platform.isAndroid) {
            platformName = "Android APK";
          } else if (io.Platform.isIOS) {
            platformName = "iOS App";
          } else {
            platformName = "${io.Platform.operatingSystem} App";
          }
        } catch (_) {}
      }

      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'company_name': _companyInfo.name,
          'phone': _companyInfo.phone,
          'email': _companyInfo.email,
          'device': platformName,
          'action': action,
          'details': details,
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Fail silently
    }
  }
}
