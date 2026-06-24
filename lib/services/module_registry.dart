class ModuleInputDef {
  final String id;
  final String name;
  final String unit;
  final double defaultValue;

  const ModuleInputDef({
    required this.id,
    required this.name,
    required this.unit,
    required this.defaultValue,
  });
}

class ModuleDef {
  final String id;
  final String name;
  final String category;
  final String unit;
  final List<ModuleInputDef> inputs;
  final String description;

  const ModuleDef({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.inputs,
    this.description = '',
  });
}

class ModuleRegistry {
  // Category French translations and IDs
  static const Map<String, String> categories = {
    'earthworks': 'Terrassements',
    'concrete': 'Béton',
    'reinforcement': 'Ferraillage',
    'formwork': 'Coffrage',
    'masonry': 'Maçonnerie',
    'finishes': 'Finitions',
    'roofing': 'Toiture',
    'doors_windows': 'Menuiseries',
    'plumbing': 'Plomberie',
    'electricity': 'Électricité',
    'vrd': 'VRD',
    'miscellaneous': 'Divers',
  };

  /// Get modules belonging to a specific category.
  static List<ModuleDef> getModulesByCategory(String categoryId) {
    final catName = categories[categoryId] ?? categoryId;
    return allModules.where((m) => m.category == catName).toList();
  }

  /// Find a module by ID.
  static ModuleDef? getModuleById(String id) {
    try {
      return allModules.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<ModuleDef> allModules = [
    // ==========================================
    // TERRASSEMENTS (earthworks)
    // ==========================================
    ModuleDef(
      id: 'fouilles_semelles',
      name: 'Fouilles pour semelles isolées',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'profondeur_m', name: 'Profondeur', unit: 'm', defaultValue: 1.20),
        ModuleInputDef(id: 'nombre', name: 'Nombre de semelles', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'fouilles_rigoles',
      name: 'Fouilles en rigoles',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'profondeur_m', name: 'Profondeur', unit: 'm', defaultValue: 0.60),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'fouilles_tranchees',
      name: 'Fouilles en tranchées',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.60),
        ModuleInputDef(id: 'profondeur_m', name: 'Profondeur', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'decapage',
      name: 'Décapage du terrain',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 15.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur décapage', unit: 'm', defaultValue: 0.20),
      ],
    ),
    ModuleDef(
      id: 'deblais',
      name: 'Déblais',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur moyenne', unit: 'm', defaultValue: 0.80),
        ModuleInputDef(id: 'coefficient_foisonnement', name: 'Coeff. foisonnement', unit: 'ratio', defaultValue: 1.20),
      ],
    ),
    ModuleDef(
      id: 'remblais',
      name: 'Remblais compactés',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur moyenne', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'coefficient_compactage', name: 'Coeff. compactage', unit: 'ratio', defaultValue: 1.10),
      ],
    ),
    ModuleDef(
      id: 'nivellement',
      name: 'Nivellement de plateforme',
      category: 'Terrassements',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 10.00),
      ],
    ),
    ModuleDef(
      id: 'excavation_generale',
      name: 'Excavation générale',
      category: 'Terrassements',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 6.00),
        ModuleInputDef(id: 'profondeur_m', name: 'Profondeur', unit: 'm', defaultValue: 1.50),
      ],
    ),

    // ==========================================
    // BETON (concrete)
    // ==========================================
    ModuleDef(
      id: 'beton_proprete',
      name: 'Béton de propreté',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.50),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur', unit: 'm', defaultValue: 0.10),
        ModuleInputDef(id: 'nombre', name: 'Nombre d\'éléments', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 150.00),
      ],
    ),
    ModuleDef(
      id: 'semelles_isolees',
      name: 'Semelles isolées',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 0.30),
        ModuleInputDef(id: 'nombre', name: 'Nombre', unit: 'u', defaultValue: 6.00),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'semelles_filantes',
      name: 'Semelles filantes',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 25.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.50),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 0.25),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'longrines',
      name: 'Longrines',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 25.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'poteaux',
      name: 'Poteaux béton armé',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'section_x_m', name: 'Section X (largeur)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'section_y_m', name: 'Section Y (longueur)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'nombre', name: 'Nombre de poteaux', unit: 'u', defaultValue: 6.00),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'poutres',
      name: 'Poutres béton armé',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur (base)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur (totale)', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'chainages',
      name: 'Chaînages béton',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 30.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 0.15),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'dalles',
      name: 'Dalle pleine béton',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 6.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur', unit: 'm', defaultValue: 0.15),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'dallage',
      name: 'Dallage au sol',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur', unit: 'm', defaultValue: 0.10),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'radier',
      name: 'Radier général',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur', unit: 'm', defaultValue: 0.30),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'voiles',
      name: 'Voiles béton',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 2.80),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur', unit: 'm', defaultValue: 0.15),
        ModuleInputDef(id: 'nombre', name: 'Nombre d\'éléments', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'dosage_kg_m3', name: 'Dosage ciment', unit: 'kg/m³', defaultValue: 350.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 3.00),
      ],
    ),
    ModuleDef(
      id: 'escalier_beton',
      name: 'Escalier béton',
      category: 'Béton',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'largeur_m', name: 'Largeur escalier', unit: 'm', defaultValue: 1.20),
        ModuleInputDef(id: 'hauteur_marche_m', name: 'Hauteur marche (h)', unit: 'm', defaultValue: 0.17),
        ModuleInputDef(id: 'giron_m', name: 'Giron (g)', unit: 'm', defaultValue: 0.30),
        ModuleInputDef(id: 'nombre_marches', name: 'Nombre de marches', unit: 'u', defaultValue: 17.00),
        ModuleInputDef(id: 'epaisseur_paillasse_m', name: 'Épaisseur paillasse', unit: 'm', defaultValue: 0.15),
      ],
    ),

    // ==========================================
    // FERRAILLAGE (reinforcement)
    // ==========================================
    ModuleDef(
      id: 'acier_par_poids',
      name: 'Acier par poids direct',
      category: 'Ferraillage',
      unit: 'kg',
      inputs: [
        ModuleInputDef(id: 'poids_kg', name: 'Poids nominal', unit: 'kg', defaultValue: 100.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'acier_par_barres',
      name: 'Acier par nombre de barres',
      category: 'Ferraillage',
      unit: 'kg',
      inputs: [
        ModuleInputDef(id: 'diametre_mm', name: 'Diamètre des barres', unit: 'mm', defaultValue: 10.00),
        ModuleInputDef(id: 'longueur_barre_m', name: 'Longueur d\'une barre', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'nombre_barres', name: 'Nombre de barres', unit: 'u', defaultValue: 10.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'etriers',
      name: 'Calcul d\'étriers de ferraillage',
      category: 'Ferraillage',
      unit: 'kg',
      inputs: [
        ModuleInputDef(id: 'largeur_element_m', name: 'Largeur étrier fini', unit: 'm', defaultValue: 0.15),
        ModuleInputDef(id: 'hauteur_element_m', name: 'Hauteur étrier fini', unit: 'm', defaultValue: 0.35),
        ModuleInputDef(id: 'recouvrement_m', name: 'Recouvrement crochets', unit: 'm', defaultValue: 0.08),
        ModuleInputDef(id: 'espacement_m', name: 'Espacement', unit: 'm', defaultValue: 0.15),
        ModuleInputDef(id: 'longueur_element_m', name: 'Longueur de l\'élément armé', unit: 'm', defaultValue: 4.00),
        ModuleInputDef(id: 'diametre_mm', name: 'Diamètre étrier', unit: 'mm', defaultValue: 6.00),
        ModuleInputDef(id: 'nombre_elements', name: 'Nombre d\'éléments', unit: 'u', defaultValue: 1.00),
      ],
    ),
    ModuleDef(
      id: 'treillis_soude',
      name: 'Treillis soudé',
      category: 'Ferraillage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur dalle', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur dalle', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'recouvrement_percent', name: 'Pourcentage recouvrement', unit: '%', defaultValue: 10.00),
      ],
    ),

    // ==========================================
    // COFFRAGE (formwork)
    // ==========================================
    ModuleDef(
      id: 'coffrage_semelles',
      name: 'Coffrage semelles',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur semelle', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur semelle', unit: 'm', defaultValue: 1.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur semelle', unit: 'm', defaultValue: 0.30),
        ModuleInputDef(id: 'nombre', name: 'Nombre', unit: 'u', defaultValue: 6.00),
      ],
    ),
    ModuleDef(
      id: 'coffrage_longrines',
      name: 'Coffrage longrines',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 25.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur (fond option)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur (joue)', unit: 'm', defaultValue: 0.40),
      ],
    ),
    ModuleDef(
      id: 'coffrage_poteaux',
      name: 'Coffrage poteaux',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'largeur_m', name: 'Section X (largeur)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'longueur_m', name: 'Section Y (longueur)', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'nombre', name: 'Nombre de poteaux', unit: 'u', defaultValue: 6.00),
      ],
    ),
    ModuleDef(
      id: 'coffrage_poutres',
      name: 'Coffrage poutres',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_m', name: 'Longueur totale', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur base', unit: 'm', defaultValue: 0.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur joues', unit: 'm', defaultValue: 0.40),
      ],
    ),
    ModuleDef(
      id: 'coffrage_dalles',
      name: 'Coffrage dalle de compression',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 6.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'coffrage_voiles',
      name: 'Coffrage voiles',
      category: 'Coffrage',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur voile', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur voile', unit: 'm', defaultValue: 2.80),
        ModuleInputDef(id: 'nombre_faces', name: 'Nombre de faces coffrées', unit: 'u', defaultValue: 2.00),
        ModuleInputDef(id: 'nombre', name: 'Nombre d\'éléments', unit: 'u', defaultValue: 1.00),
      ],
    ),

    // ==========================================
    // MAÇONNERIE (masonry)
    // ==========================================
    ModuleDef(
      id: 'murs_parpaings',
      name: 'Murs en parpaings',
      category: 'Maçonnerie',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur du mur', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur du mur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'surface_ouvertures_m2', name: 'Surface ouvertures', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'blocs_par_m2', name: 'Nombre blocs / m²', unit: 'u/m²', defaultValue: 12.50),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
        ModuleInputDef(id: 'prix_bloc', name: 'Prix unitaire du bloc', unit: 'FCFA', defaultValue: 400.00),
        ModuleInputDef(id: 'prix_pose_m2', name: 'Prix pose par m²', unit: 'FCFA', defaultValue: 1500.00),
      ],
    ),
    ModuleDef(
      id: 'murs_briques',
      name: 'Murs en briques',
      category: 'Maçonnerie',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur du mur', unit: 'm', defaultValue: 12.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur du mur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'surface_ouvertures_m2', name: 'Surface ouvertures', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'briques_par_m2', name: 'Nombre briques / m²', unit: 'u/m²', defaultValue: 25.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
        ModuleInputDef(id: 'prix_brique', name: 'Prix unitaire brique', unit: 'FCFA', defaultValue: 150.00),
      ],
    ),
    ModuleDef(
      id: 'soubassement',
      name: 'Mur de soubassement',
      category: 'Maçonnerie',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur totale', unit: 'm', defaultValue: 30.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur moyenne', unit: 'm', defaultValue: 0.60),
        ModuleInputDef(id: 'blocs_par_m2', name: 'Nombre blocs / m²', unit: 'u/m²', defaultValue: 12.50),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
        ModuleInputDef(id: 'prix_bloc', name: 'Prix unitaire du bloc', unit: 'FCFA', defaultValue: 400.00),
      ],
    ),
    ModuleDef(
      id: 'mortier_maconnerie',
      name: 'Mortier de maçonnerie',
      category: 'Maçonnerie',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'surface_mur_m2', name: 'Surface du mur', unit: 'm²', defaultValue: 36.00),
        ModuleInputDef(id: 'consommation_m3_m2', name: 'Mortier par m²', unit: 'm³/m²', defaultValue: 0.025),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),

    // ==========================================
    // FINITIONS (finishes)
    // ==========================================
    ModuleDef(
      id: 'enduit_interieur',
      name: 'Enduit intérieur',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur du mur', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur du mur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'nombre_faces', name: 'Nombre de faces', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'surface_ouvertures_m2', name: 'Surface ouvertures', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 0.00),
      ],
    ),
    ModuleDef(
      id: 'enduit_exterieur',
      name: 'Enduit extérieur',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'perimetre_batiment_m', name: 'Périmètre extérieur', unit: 'm', defaultValue: 40.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur du mur', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'surface_ouvertures_m2', name: 'Surface ouvertures', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 0.00),
      ],
    ),
    ModuleDef(
      id: 'chape',
      name: 'Chape de lissage',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur pièce', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur pièce', unit: 'm', defaultValue: 4.00),
        ModuleInputDef(id: 'epaisseur_m', name: 'Épaisseur chape', unit: 'm', defaultValue: 0.05),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'carrelage_sol',
      name: 'Carrelage sol',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_piece_m', name: 'Longueur pièce', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'largeur_piece_m', name: 'Largeur pièce', unit: 'm', defaultValue: 4.00),
        ModuleInputDef(id: 'surface_deduction_m2', name: 'Surface déduite', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'longueur_carreau_m', name: 'Longueur carreau', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'largeur_carreau_m', name: 'Largeur carreau', unit: 'm', defaultValue: 0.40),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 10.00),
      ],
    ),
    ModuleDef(
      id: 'carrelage_mur',
      name: 'Faïence murale',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur murs', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur faïence', unit: 'm', defaultValue: 2.00),
        ModuleInputDef(id: 'nombre_faces', name: 'Nombre de faces', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'surface_ouvertures_m2', name: 'Surface ouvertures', unit: 'm²', defaultValue: 0.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 10.00),
      ],
    ),
    ModuleDef(
      id: 'peinture_interieure',
      name: 'Peinture intérieure',
      category: 'Finitions',
      unit: 'L',
      inputs: [
        ModuleInputDef(id: 'surface_m2', name: 'Surface murs/plafond', unit: 'm²', defaultValue: 60.00),
        ModuleInputDef(id: 'nombre_couches', name: 'Nombre de couches', unit: 'u', defaultValue: 2.00),
        ModuleInputDef(id: 'rendement_m2_litre', name: 'Rendement (m²/Litre)', unit: 'm²/L', defaultValue: 8.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'peinture_exterieure',
      name: 'Peinture extérieure',
      category: 'Finitions',
      unit: 'L',
      inputs: [
        ModuleInputDef(id: 'surface_m2', name: 'Surface façade nette', unit: 'm²', defaultValue: 100.00),
        ModuleInputDef(id: 'nombre_couches', name: 'Nombre de couches', unit: 'u', defaultValue: 2.00),
        ModuleInputDef(id: 'rendement_m2_litre', name: 'Rendement (m²/L)', unit: 'm²/L', defaultValue: 8.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'faux_plafond',
      name: 'Faux plafond suspendu',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur', unit: 'm', defaultValue: 6.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur', unit: 'm', defaultValue: 5.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'etancheite',
      name: 'Étanchéité toiture terrasse',
      category: 'Finitions',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur terrasse', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur terrasse', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'remontee_acrotere_m2', name: 'Surface relevés acrotères', unit: 'm²', defaultValue: 5.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),

    // ==========================================
    // TOITURE (roofing)
    // ==========================================
    ModuleDef(
      id: 'toiture_simple_pente',
      name: 'Toiture simple pente',
      category: 'Toiture',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_batiment_m', name: 'Longueur bâtiment', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_batiment_m', name: 'Largeur bâtiment', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'debord_m', name: 'Débord toiture (égouts/riv)', unit: 'm', defaultValue: 0.50),
        ModuleInputDef(id: 'coefficient_pente', name: 'Coeff. pente (inclinaison)', unit: 'ratio', defaultValue: 1.10),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'toiture_double_pente',
      name: 'Toiture double pente',
      category: 'Toiture',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_batiment_m', name: 'Longueur bâtiment', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_batiment_m', name: 'Largeur bâtiment', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'debord_m', name: 'Débord toiture', unit: 'm', defaultValue: 0.50),
        ModuleInputDef(id: 'coefficient_pente', name: 'Coeff. pente', unit: 'ratio', defaultValue: 1.15),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'gouttieres',
      name: 'Gouttières',
      category: 'Toiture',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_totale_ml', name: 'Longueur totale linéaire', unit: 'ml', defaultValue: 16.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),

    // ==========================================
    // MENUISERIES (doors_windows)
    // ==========================================
    ModuleDef(
      id: 'portes',
      name: 'Portes',
      category: 'Menuiseries',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'nombre', name: 'Nombre de portes', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'prix_unitaire', name: 'Prix fourniture', unit: 'FCFA', defaultValue: 75000.00),
        ModuleInputDef(id: 'prix_pose', name: 'Prix pose par porte', unit: 'FCFA', defaultValue: 5000.00),
      ],
    ),
    ModuleDef(
      id: 'fenetres',
      name: 'Fenêtres',
      category: 'Menuiseries',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'largeur_m', name: 'Largeur fenêtre', unit: 'm', defaultValue: 1.20),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur fenêtre', unit: 'm', defaultValue: 1.20),
        ModuleInputDef(id: 'nombre', name: 'Nombre d\'unités', unit: 'u', defaultValue: 4.00),
        ModuleInputDef(id: 'prix_m2', name: 'Prix fourniture par m²', unit: 'FCFA/m²', defaultValue: 45000.00),
        ModuleInputDef(id: 'prix_pose_unitaire', name: 'Prix pose par fenêtre', unit: 'FCFA/u', defaultValue: 3000.00),
      ],
    ),

    // ==========================================
    // PLOMBERIE (plumbing)
    // ==========================================
    ModuleDef(
      id: 'tuyauterie_eau_froide',
      name: 'Tuyauterie eau froide',
      category: 'Plomberie',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_ml', name: 'Longueur canalisation', unit: 'ml', defaultValue: 20.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'evacuation_eaux_usees',
      name: 'Évacuation des eaux usées',
      category: 'Plomberie',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_ml', name: 'Longueur tuyauterie PVC', unit: 'ml', defaultValue: 15.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'appareils_sanitaires',
      name: 'Appareils sanitaires',
      category: 'Plomberie',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'nombre', name: 'Nombre d\'appareils', unit: 'u', defaultValue: 1.00),
        ModuleInputDef(id: 'prix_unitaire', name: 'Prix d\'achat unitaire', unit: 'FCFA', defaultValue: 50000.00),
        ModuleInputDef(id: 'prix_pose', name: 'Prix de pose unitaire', unit: 'FCFA', defaultValue: 10000.00),
      ],
    ),
    ModuleDef(
      id: 'fosse_septique',
      name: 'Fosse septique maçonné',
      category: 'Plomberie',
      unit: 'm³',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur intérieure', unit: 'm', defaultValue: 3.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur intérieure', unit: 'm', defaultValue: 2.00),
        ModuleInputDef(id: 'profondeur_m', name: 'Profondeur active', unit: 'm', defaultValue: 2.00),
      ],
    ),

    // ==========================================
    // ÉLECTRICITÉ (electricity)
    // ==========================================
    ModuleDef(
      id: 'points_lumineux',
      name: 'Points lumineux',
      category: 'Électricité',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'nombre', name: 'Nombre de foyers', unit: 'u', defaultValue: 10.00),
        ModuleInputDef(id: 'prix_unitaire', name: 'Prix équipement unitaire', unit: 'FCFA', defaultValue: 5000.00),
        ModuleInputDef(id: 'prix_pose', name: 'Prix de pose unitaire', unit: 'FCFA', defaultValue: 7000.00),
      ],
    ),
    ModuleDef(
      id: 'prises',
      name: 'Prises électriques',
      category: 'Électricité',
      unit: 'u',
      inputs: [
        ModuleInputDef(id: 'nombre', name: 'Nombre de prises', unit: 'u', defaultValue: 8.00),
        ModuleInputDef(id: 'prix_unitaire', name: 'Prix appareillage unitaire', unit: 'FCFA', defaultValue: 4000.00),
        ModuleInputDef(id: 'prix_pose', name: 'Prix de pose unitaire', unit: 'FCFA', defaultValue: 6000.00),
      ],
    ),
    ModuleDef(
      id: 'cables',
      name: 'Câbles électriques',
      category: 'Électricité',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_ml', name: 'Longueur totale linéaire', unit: 'ml', defaultValue: 50.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),

    // ==========================================
    // VRD (vrd)
    // ==========================================
    ModuleDef(
      id: 'caniveaux',
      name: 'Caniveaux béton',
      category: 'VRD',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_ml', name: 'Longueur caniveau', unit: 'ml', defaultValue: 10.00),
      ],
    ),
    ModuleDef(
      id: 'bordures',
      name: 'Bordures de trottoir',
      category: 'VRD',
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_ml', name: 'Longueur bordure', unit: 'ml', defaultValue: 20.00),
      ],
    ),
    ModuleDef(
      id: 'pavage',
      name: 'Pavage de cour',
      category: 'VRD',
      unit: 'm²',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur cour', unit: 'm', defaultValue: 10.00),
        ModuleInputDef(id: 'largeur_m', name: 'Largeur cour', unit: 'm', defaultValue: 8.00),
        ModuleInputDef(id: 'perte_percent', name: 'Pourcentage de perte', unit: '%', defaultValue: 5.00),
      ],
    ),
    ModuleDef(
      id: 'mur_cloture',
      name: 'Mur de clôture complet',
      category: 'Maçonnerie', // Wait, this belongs to VRD or masonry? Let's display under VRD / Clôture module
      unit: 'ml',
      inputs: [
        ModuleInputDef(id: 'longueur_m', name: 'Longueur clôture', unit: 'm', defaultValue: 40.00),
        ModuleInputDef(id: 'hauteur_m', name: 'Hauteur clôture', unit: 'm', defaultValue: 2.00),
        ModuleInputDef(id: 'surface_portail_m2', name: 'Surface portail déduite', unit: 'm²', defaultValue: 6.00),
        ModuleInputDef(id: 'blocs_par_m2', name: 'Blocs / m²', unit: 'u/m²', defaultValue: 12.50),
        ModuleInputDef(id: 'prix_bloc', name: 'Prix unitaire du bloc', unit: 'FCFA', defaultValue: 400.00),
        ModuleInputDef(id: 'prix_enduit_m2', name: 'Enduit par face (m²)', unit: 'FCFA/m²', defaultValue: 2000.00),
        ModuleInputDef(id: 'prix_peinture_m2', name: 'Peinture par face (m²)', unit: 'FCFA/m²', defaultValue: 1500.00),
      ],
    ),

    // ==========================================
    // DIVERS (miscellaneous)
    // ==========================================
    ModuleDef(
      id: 'installation_chantier',
      name: 'Installation de chantier',
      category: 'Divers',
      unit: 'FF',
      inputs: [
        ModuleInputDef(id: 'montant_forfaitaire', name: 'Montant forfaitaire', unit: 'FCFA', defaultValue: 150000.00),
      ],
    ),
    ModuleDef(
      id: 'nettoyage_chantier',
      name: 'Nettoyage final de chantier',
      category: 'Divers',
      unit: 'FF',
      inputs: [
        ModuleInputDef(id: 'montant_forfaitaire', name: 'Montant forfaitaire', unit: 'FCFA', defaultValue: 50000.00),
      ],
    ),
    ModuleDef(
      id: 'transport_materiaux',
      name: 'Transport de matériaux',
      category: 'Divers',
      unit: 'voyage',
      inputs: [
        ModuleInputDef(id: 'nombre_voyages', name: 'Nombre de voyages', unit: 'u', defaultValue: 5.00),
        ModuleInputDef(id: 'prix_voyage', name: 'Prix par voyage', unit: 'FCFA', defaultValue: 25000.00),
      ],
    ),
    ModuleDef(
      id: 'main_oeuvre',
      name: 'Main-d\'œuvre temporaire',
      category: 'Divers',
      unit: 'jour',
      inputs: [
        ModuleInputDef(id: 'nombre_ouvriers', name: 'Nombre d\'ouvriers', unit: 'u', defaultValue: 4.00),
        ModuleInputDef(id: 'nombre_jours', name: 'Nombre de jours', unit: 'u', defaultValue: 5.00),
        ModuleInputDef(id: 'prix_jour', name: 'Tarif journalier par ouvrier', unit: 'FCFA', defaultValue: 5000.00),
      ],
    ),
    ModuleDef(
      id: 'marge_imprevus',
      name: 'Marge pour imprévus',
      category: 'Divers',
      unit: '%',
      inputs: [
        ModuleInputDef(id: 'total_travaux', name: 'Total travaux de base', unit: 'FCFA', defaultValue: 1000000.00),
        ModuleInputDef(id: 'pourcentage_imprevus', name: 'Pourcentage marge', unit: '%', defaultValue: 10.00),
      ],
    ),
  ];
}
