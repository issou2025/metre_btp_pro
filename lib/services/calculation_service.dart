class CalculationResult {
  final double quantity;
  final double amount;
  final String formulaUsed;
  final double? cimentSacs;
  final Map<String, double> additionalInfo;
  final String? errorMessage;

  CalculationResult({
    required this.quantity,
    required this.amount,
    required this.formulaUsed,
    this.cimentSacs,
    this.additionalInfo = const {},
    this.errorMessage,
  });

  factory CalculationResult.error(String message) {
    return CalculationResult(
      quantity: 0.0,
      amount: 0.0,
      formulaUsed: '',
      errorMessage: message,
    );
  }
}

class CalculationService {
  /// General gateway to run calculations based on the module ID and a map of inputs.
  /// Inputs map is expected to contain all necessary double values.
  static CalculationResult calculate(String moduleId, Map<String, double> inputs) {
    // Basic verification: all inputs must be positive or zero
    for (var entry in inputs.entries) {
      if (entry.key != 'surface_deduction_m2' && 
          entry.key != 'surface_ouvertures_m2' && 
          entry.key != 'surface_portail_m2' &&
          entry.value < 0) {
        return CalculationResult.error("Tous les champs numériques doivent être positifs.");
      }
    }

    try {
      switch (moduleId) {
        // ==========================================
        // TERRASSEMENTS
        // ==========================================
        case 'fouilles_semelles':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['profondeur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * l * h * n;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $h m × $n unités + $p% perte",
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal},
          );

        case 'fouilles_rigoles':
          final L = inputs['longueur_totale_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['profondeur_m'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * l * h;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $h m + $p% perte",
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal},
          );

        case 'fouilles_tranchees': // same formula as rigoles
          final L = inputs['longueur_totale_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['profondeur_m'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * l * h;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $h m + $p% perte",
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal},
          );

        case 'decapage':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final e = inputs['epaisseur_m'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final surface = L * l;
          final volume = surface * e;
          final total = volume * pu;

          return CalculationResult(
            quantity: volume,
            amount: total,
            formulaUsed: "$L m × $l m × $e m d'épaisseur",
            additionalInfo: {'Surface': surface, 'Volume': volume},
          );

        case 'deblais':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final coeff = inputs['coefficient_foisonnement'] ?? 1.20;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volPlace = L * l * h;
          final volFoisonne = volPlace * coeff;
          final total = volFoisonne * pu;

          return CalculationResult(
            quantity: volFoisonne,
            amount: total,
            formulaUsed: "$L m × $l m × $h m × $coeff (foisonnement)",
            additionalInfo: {'Volume en place': volPlace, 'Volume foisonné': volFoisonne},
          );

        case 'remblais':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final coeff = inputs['coefficient_compactage'] ?? 1.10;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volNet = L * l * h;
          final volComp = volNet * coeff;
          final total = volComp * pu;

          return CalculationResult(
            quantity: volComp,
            amount: total,
            formulaUsed: "$L m × $l m × $h m × $coeff (compactage)",
            additionalInfo: {'Volume net': volNet, 'Volume compacté': volComp},
          );

        case 'nivellement':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final surface = L * l;
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "$L m × $l m",
            additionalInfo: {'Surface': surface},
          );

        case 'excavation_generale':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['profondeur_m'] ?? 0.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volume = L * l * h;
          final total = volume * pu;

          return CalculationResult(
            quantity: volume,
            amount: total,
            formulaUsed: "$L m × $l m × $h m",
            additionalInfo: {'Volume': volume},
          );

        // ==========================================
        // BETON
        // ==========================================
        case 'beton_proprete':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final e = inputs['epaisseur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final dosage = inputs['dosage_kg_m3'] ?? 150.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volume = L * l * e * n;
          final sacs = (volume * dosage) / 50.0;
          final total = volume * pu;

          return CalculationResult(
            quantity: volume,
            amount: total,
            formulaUsed: "$L m × $l m × $e m × $n unités",
            cimentSacs: sacs,
            additionalInfo: {'Volume': volume, 'Ciment (sacs de 50kg)': sacs},
          );

        case 'semelles_isolees':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final dosage = inputs['dosage_kg_m3'] ?? 350.0;
          final p = inputs['perte_percent'] ?? 3.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * l * h * n;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final sacs = (volumeFinal * dosage) / 50.0;
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $h m × $n unités + $p% perte",
            cimentSacs: sacs,
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal, 'Ciment (sacs)': sacs},
          );

        case 'semelles_filantes':
        case 'longrines':
        case 'poutres':
        case 'chainages':
          final L = inputs['longueur_totale_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final dosage = inputs['dosage_kg_m3'] ?? 350.0;
          final p = inputs['perte_percent'] ?? 3.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * l * h;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final sacs = (volumeFinal * dosage) / 50.0;
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $h m + $p% perte",
            cimentSacs: sacs,
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal, 'Ciment (sacs)': sacs},
          );

        case 'poteaux':
          final sx = inputs['section_x_m'] ?? 0.0;
          final sy = inputs['section_y_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final dosage = inputs['dosage_kg_m3'] ?? 350.0;
          final p = inputs['perte_percent'] ?? 3.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = sx * sy * h * n;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final sacs = (volumeFinal * dosage) / 50.0;
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$sx m × $sy m × $h m × $n unités + $p% perte",
            cimentSacs: sacs,
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal, 'Ciment (sacs)': sacs},
          );

        case 'dalles':
        case 'dallage':
        case 'radier':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final e = inputs['epaisseur_m'] ?? 0.0;
          final dosage = inputs['dosage_kg_m3'] ?? 350.0;
          final p = inputs['perte_percent'] ?? 3.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final surface = L * l;
          final volumeBrut = surface * e;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final sacs = (volumeFinal * dosage) / 50.0;
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $l m × $e m + $p% perte",
            cimentSacs: sacs,
            additionalInfo: {'Surface': surface, 'Volume brut': volumeBrut, 'Volume final': volumeFinal, 'Ciment (sacs)': sacs},
          );

        case 'voiles':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final e = inputs['epaisseur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final dosage = inputs['dosage_kg_m3'] ?? 350.0;
          final p = inputs['perte_percent'] ?? 3.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;

          final volumeBrut = L * h * e * n;
          final volumeFinal = volumeBrut * (1 + p / 100);
          final sacs = (volumeFinal * dosage) / 50.0;
          final total = volumeFinal * pu;

          return CalculationResult(
            quantity: volumeFinal,
            amount: total,
            formulaUsed: "$L m × $h m × $e m × $n unités + $p% perte",
            cimentSacs: sacs,
            additionalInfo: {'Volume brut': volumeBrut, 'Volume final': volumeFinal, 'Ciment (sacs)': sacs},
          );

        case 'escaliers_beton':
        case 'escalier_beton':
          final l = inputs['largeur_m'] ?? 0.0;
          final hm = inputs['hauteur_marche_m'] ?? 0.0;
          final g = inputs['giron_m'] ?? 0.0;
          final n = inputs['nombre_marches'] ?? 0.0;
          final ep = inputs['epaisseur_paillasse_m'] ?? 0.0;
          final pu = inputs['prix_m3'] ?? 0.0;

          final volMarches = l * hm * g * n / 2.0;
          final longDev = g * n;
          final volPaillasse = l * longDev * ep;
          final volumeTotal = volMarches + volPaillasse;
          final total = volumeTotal * pu;

          return CalculationResult(
            quantity: volumeTotal,
            amount: total,
            formulaUsed: "Vol. Marches ($volMarches m³) + Vol. Paillasse ($volPaillasse m³)",
            additionalInfo: {
              'Volume marches': volMarches,
              'Longueur développée': longDev,
              'Volume paillasse': volPaillasse,
              'Volume total': volumeTotal
            },
          );

        // ==========================================
        // FERRAILLAGE
        // ==========================================
        case 'acier_par_poids':
          final poids = inputs['poids_kg'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_kg'] ?? 0.0;

          final poidsFinal = poids * (1 + p / 100);
          final total = poidsFinal * pu;

          return CalculationResult(
            quantity: poidsFinal,
            amount: total,
            formulaUsed: "$poids kg + $p% perte",
            additionalInfo: {'Poids net': poids, 'Poids final': poidsFinal},
          );

        case 'acier_par_barres':
          final d = inputs['diametre_mm'] ?? 0.0;
          final L = inputs['longueur_barre_m'] ?? 12.0;
          final n = inputs['nombre_barres'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_kg'] ?? 0.0;

          final poidsLineaire = (d * d) / 162.0;
          final poidsBrut = poidsLineaire * L * n;
          final poidsFinal = poidsBrut * (1 + p / 100);
          final total = poidsFinal * pu;

          return CalculationResult(
            quantity: poidsFinal,
            amount: total,
            formulaUsed: "Ø$d mm ($poidsLineaire kg/m) × $L m × $n barres + $p% perte",
            additionalInfo: {'Poids linéaire (kg/m)': poidsLineaire, 'Poids brut': poidsBrut, 'Poids final': poidsFinal},
          );

        case 'etriers':
          final le = inputs['largeur_element_m'] ?? 0.0;
          final he = inputs['hauteur_element_m'] ?? 0.0;
          final rec = inputs['recouvrement_m'] ?? 0.10;
          final esp = inputs['espacement_m'] ?? 0.15;
          final Le = inputs['longueur_element_m'] ?? 0.0;
          final d = inputs['diametre_mm'] ?? 6.0;
          final ne = inputs['nombre_elements'] ?? 1.0;
          final pu = inputs['prix_kg'] ?? 0.0;

          if (esp == 0) return CalculationResult.error("L'espacement ne peut pas être égal à zéro.");

          final longUnEtrier = 2 * (le + he) + rec;
          final nEtriers = (Le / esp) * ne;
          final longTotale = longUnEtrier * nEtriers;
          final poidsLineaire = (d * d) / 162.0;
          final poidsTotal = longTotale * poidsLineaire;
          final total = poidsTotal * pu;

          return CalculationResult(
            quantity: poidsTotal,
            amount: total,
            formulaUsed: "Long. étrier ($longUnEtrier m) × $nEtriers étriers × Ø$d mm ($poidsLineaire kg/m)",
            additionalInfo: {
              'Longueur unitaire': longUnEtrier,
              'Nombre étriers': nEtriers,
              'Longueur totale': longTotale,
              'Poids total': poidsTotal
            },
          );

        case 'treillis_soude':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final rec = inputs['recouvrement_percent'] ?? 10.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * l;
          final surfFinale = surfBrute * (1 + rec / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "$L m × $l m + $rec% recouvrement",
            additionalInfo: {'Surface brute': surfBrute, 'Surface finale': surfFinale},
          );

        // ==========================================
        // COFFRAGE
        // ==========================================
        case 'coffrage_semelles':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final perimetre = 2 * (L + l);
          final surface = perimetre * h * n;
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "Périmètre ($perimetre m) × $h m × $n unités",
            additionalInfo: {'Surface': surface},
          );

        case 'coffrage_longrines':
        case 'coffrage_poutres':
          final L = inputs['longueur_totale_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surface = L * (l + 2 * h);
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "$L m × ($l m + 2 × $h m de joues)",
            additionalInfo: {'Surface': surface},
          );

        case 'coffrage_poteaux':
          final lx = inputs['largeur_m'] ?? 0.0;
          final ly = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final perimetre = 2 * (lx + ly);
          final surface = perimetre * h * n;
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "Périmètre ($perimetre m) × $h m × $n unités",
            additionalInfo: {'Surface': surface},
          );

        case 'coffrage_dalles':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surface = L * l;
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "$L m × $l m",
            additionalInfo: {'Surface': surface},
          );

        case 'coffrage_voiles':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final faces = inputs['nombre_faces'] ?? 2.0;
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surface = L * h * faces * n;
          final total = surface * pu;

          return CalculationResult(
            quantity: surface,
            amount: total,
            formulaUsed: "$L m × $h m × $faces faces × $n unités",
            additionalInfo: {'Surface': surface},
          );

        // ==========================================
        // MACONNERIE
        // ==========================================
        case 'murs_parpaings':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final openings = inputs['surface_ouvertures_m2'] ?? 0.0;
          final blocsm2 = inputs['blocs_par_m2'] ?? 12.5;
          final p = inputs['perte_percent'] ?? 5.0;
          final puBloc = inputs['prix_bloc'] ?? 0.0;
          final puPose = inputs['prix_pose_m2'] ?? 0.0;

          final surfBrute = L * h;
          if (openings > surfBrute) {
            return CalculationResult.error("La surface d'ouverture ($openings m²) dépasse la surface brute du mur ($surfBrute m²).");
          }

          final surfNette = surfBrute - openings;
          final blocsBruts = surfNette * blocsm2;
          final blocsFinaux = blocsBruts * (1 + p / 100);
          final costBlocs = blocsFinaux * puBloc;
          final costPose = surfNette * puPose;
          final total = costBlocs + costPose;

          return CalculationResult(
            quantity: blocsFinaux,
            amount: total,
            formulaUsed: "Blocs: $blocsFinaux u ($surfNette m² nette × $blocsm2 blocs/m² + $p% perte)",
            additionalInfo: {
              'Surface brute': surfBrute,
              'Surface nette': surfNette,
              'Nombre blocs': blocsFinaux,
              'Coût matériaux': costBlocs,
              'Coût pose': costPose
            },
          );

        case 'murs_briques':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final openings = inputs['surface_ouvertures_m2'] ?? 0.0;
          final briquesm2 = inputs['briques_par_m2'] ?? 25.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final puBrique = inputs['prix_brique'] ?? 0.0;

          final surfBrute = L * h;
          if (openings > surfBrute) {
            return CalculationResult.error("La surface d'ouverture ($openings m²) dépasse la surface brute du mur ($surfBrute m²).");
          }

          final surfNette = surfBrute - openings;
          final briquesBrutes = surfNette * briquesm2;
          final briquesFinales = briquesBrutes * (1 + p / 100);
          final total = briquesFinales * puBrique;

          return CalculationResult(
            quantity: briquesFinales,
            amount: total,
            formulaUsed: "Briques: $briquesFinales u ($surfNette m² nette × $briquesm2 briques/m² + $p% perte)",
            additionalInfo: {
              'Surface brute': surfBrute,
              'Surface nette': surfNette,
              'Nombre briques': briquesFinales
            },
          );

        case 'mortier_maconnerie':
          final surf = inputs['surface_mur_m2'] ?? 0.0;
          final cons = inputs['consommation_m3_m2'] ?? 0.025;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_m3'] ?? 0.0;

          final volBrut = surf * cons;
          final volFinal = volBrut * (1 + p / 100);
          final total = volFinal * pu;

          return CalculationResult(
            quantity: volFinal,
            amount: total,
            formulaUsed: "$surf m² × $cons m³/m² + $p% perte",
            additionalInfo: {'Volume brut': volBrut, 'Volume final': volFinal},
          );

        case 'soubassement': // Similar to walls but often without openings
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final blocsm2 = inputs['blocs_par_m2'] ?? 12.5;
          final p = inputs['perte_percent'] ?? 5.0;
          final puBloc = inputs['prix_bloc'] ?? 0.0;

          final surface = L * h;
          final blocs = surface * blocsm2 * (1 + p / 100);
          final total = blocs * puBloc;

          return CalculationResult(
            quantity: blocs,
            amount: total,
            formulaUsed: "$L m × $h m × $blocsm2 blocs/m² + $p% perte",
            additionalInfo: {'Surface': surface, 'Nombre blocs': blocs},
          );

        // ==========================================
        // FINITIONS
        // ==========================================
        case 'enduit_interieur':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final faces = inputs['nombre_faces'] ?? 1.0;
          final openings = inputs['surface_ouvertures_m2'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * h * faces;
          if (openings > surfBrute) {
            return CalculationResult.error("La surface d'ouverture ($openings m²) dépasse la surface brute d'enduit ($surfBrute m²).");
          }

          final surfNette = surfBrute - openings;
          final surfFinale = surfNette * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "($L m × $h m × $faces faces - $openings m² ouvertures) + $p% perte",
            additionalInfo: {'Surface brute': surfBrute, 'Surface nette': surfNette, 'Surface finale': surfFinale},
          );

        case 'enduit_exterieur':
          final pb = inputs['perimetre_batiment_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final openings = inputs['surface_ouvertures_m2'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = pb * h;
          if (openings > surfBrute) {
            return CalculationResult.error("La surface d'ouverture ($openings m²) dépasse la surface brute d'enduit ($surfBrute m²).");
          }

          final surfNette = surfBrute - openings;
          final surfFinale = surfNette * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "($pb m de périmètre × $h m - $openings m² ouvertures) + $p% perte",
            additionalInfo: {'Surface brute': surfBrute, 'Surface nette': surfNette, 'Surface finale': surfFinale},
          );

        case 'chape':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final e = inputs['epaisseur_m'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final puM2 = inputs['prix_m2'] ?? 0.0;
          final puM3 = inputs['prix_m3'] ?? 0.0;

          final surface = L * l;
          final volume = surface * e;
          final volumeFinal = volume * (1 + p / 100);

          double total = 0.0;
          String formula = '';
          if (puM3 > 0) {
            total = volumeFinal * puM3;
            formula = "Volume: $volumeFinal m³ ($L m × $l m × $e m + $p% perte)";
          } else {
            total = surface * puM2;
            formula = "Surface: $surface m² ($L m × $l m)";
          }

          return CalculationResult(
            quantity: puM3 > 0 ? volumeFinal : surface,
            amount: total,
            formulaUsed: formula,
            additionalInfo: {'Surface': surface, 'Volume brut': volume, 'Volume final': volumeFinal},
          );

        case 'carrelage_sol':
          final L = inputs['longueur_piece_m'] ?? 0.0;
          final l = inputs['largeur_piece_m'] ?? 0.0;
          final ded = inputs['surface_deduction_m2'] ?? 0.0;
          final lc = inputs['longueur_carreau_m'] ?? 0.40;
          final lwc = inputs['largeur_carreau_m'] ?? 0.40;
          final p = inputs['perte_percent'] ?? 10.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * l;
          if (ded > surfBrute) {
            return CalculationResult.error("La surface de déduction ($ded m²) dépasse la surface brute de la pièce ($surfBrute m²).");
          }

          final surfNette = surfBrute - ded;
          final surfFinale = surfNette * (1 + p / 100);
          final surfCarreau = lc * lwc;
          
          double count = 0.0;
          if (surfCarreau > 0) {
            count = surfFinale / surfCarreau;
          }
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "($L m × $l m - $ded m²) + $p% perte. Carreaux: ${count.ceil()} u (${lc}m×${lwc}m)",
            additionalInfo: {
              'Surface brute': surfBrute,
              'Surface nette': surfNette,
              'Surface finale': surfFinale,
              'Nombre de carreaux': count
            },
          );

        case 'carrelage_mur':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final faces = inputs['nombre_faces'] ?? 1.0;
          final openings = inputs['surface_ouvertures_m2'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 10.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * h * faces;
          if (openings > surfBrute) {
            return CalculationResult.error("La surface d'ouverture ($openings m²) dépasse la surface brute murale ($surfBrute m²).");
          }

          final surfNette = surfBrute - openings;
          final surfFinale = surfNette * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "($L m × $h m × $faces - $openings m² ouvertures) + $p% perte",
            additionalInfo: {'Surface brute': surfBrute, 'Surface nette': surfNette, 'Surface finale': surfFinale},
          );

        case 'peinture_interieure':
        case 'peinture_exterieure':
          final surf = inputs['surface_m2'] ?? 0.0;
          final couches = inputs['nombre_couches'] ?? 2.0;
          final rendement = inputs['rendement_m2_litre'] ?? 8.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_litre'] ?? 0.0;

          if (rendement == 0) return CalculationResult.error("Le rendement ne peut pas être égal à zéro.");

          final surfTotCouches = surf * couches;
          final litBruts = surfTotCouches / rendement;
          final litFinaux = litBruts * (1 + p / 100);
          final total = litFinaux * pu;

          return CalculationResult(
            quantity: litFinaux,
            amount: total,
            formulaUsed: "$surf m² × $couches couches / $rendement m²/L + $p% perte",
            additionalInfo: {
              'Surface cumulée': surfTotCouches,
              'Litres bruts': litBruts,
              'Litres finaux (quantité)': litFinaux
            },
          );

        case 'faux_plafond':
        case 'plafond_platre':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * l;
          final surfFinale = surfBrute * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "$L m × $l m + $p% perte",
            additionalInfo: {'Surface brute': surfBrute, 'Surface finale': surfFinale},
          );

        case 'etancheite':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final acro = inputs['remontee_acrotere_m2'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfTerrasse = L * l;
          final surfTot = surfTerrasse + acro;
          final surfFinale = surfTot * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "($L m × $l m terrasse + $acro m² acrotères) + $p% perte",
            additionalInfo: {'Surface terrasse': surfTerrasse, 'Surface totale': surfTot, 'Surface finale': surfFinale},
          );

        // ==========================================
        // TOITURE
        // ==========================================
        case 'toiture_simple_pente':
        case 'toiture_double_pente':
          final L = inputs['longueur_batiment_m'] ?? 0.0;
          final l = inputs['largeur_batiment_m'] ?? 0.0;
          final deb = inputs['debord_m'] ?? 0.50;
          final coeff = inputs['coefficient_pente'] ?? 1.10;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final Ltot = L + 2 * deb;
          final ltot = l + 2 * deb;
          final surfProj = Ltot * ltot;
          final surfToiture = surfProj * coeff;
          final surfFinale = surfToiture * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "Projetée ($Ltot m × $ltot m) × $coeff pente + $p% perte",
            additionalInfo: {
              'Longueur totale': Ltot,
              'Largeur totale': ltot,
              'Surface projection': surfProj,
              'Surface toiture': surfToiture,
              'Surface finale': surfFinale
            },
          );

        case 'gouttieres':
        case 'descentes_eaux_pluviales':
          final L = inputs['longueur_totale_ml'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_ml'] ?? 0.0;

          final longFinale = L * (1 + p / 100);
          final total = longFinale * pu;

          return CalculationResult(
            quantity: longFinale,
            amount: total,
            formulaUsed: "$L ml + $p% perte",
            additionalInfo: {'Longueur finale': longFinale},
          );

        // ==========================================
        // MENUISERIES
        // ==========================================
        case 'portes':
        case 'portails':
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;
          final pose = inputs['prix_pose'] ?? 0.0;

          final costFourniture = n * pu;
          final costPose = n * pose;
          final total = costFourniture + costPose;

          return CalculationResult(
            quantity: n,
            amount: total,
            formulaUsed: "$n unités (Fourniture: $pu, Pose: $pose)",
            additionalInfo: {'Fourniture': costFourniture, 'Pose': costPose, 'Quantité': n},
          );

        case 'fenetres':
        case 'baies_vitrees':
          final w = inputs['largeur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final n = inputs['nombre'] ?? 1.0;
          final puM2 = inputs['prix_m2'] ?? 0.0;
          final puPose = inputs['prix_pose_unitaire'] ?? 0.0;

          final surfU = w * h;
          final surfTot = surfU * n;
          final costFourniture = surfTot * puM2;
          final costPose = n * puPose;
          final total = costFourniture + costPose;

          return CalculationResult(
            quantity: n,
            amount: total,
            formulaUsed: "$n u de ${w}m×${h}m ($surfTot m²) (Fourniture: $puM2/m², Pose: $puPose/u)",
            additionalInfo: {
              'Surface unitaire': surfU,
              'Surface totale': surfTot,
              'Fourniture': costFourniture,
              'Pose': costPose
            },
          );

        // ==========================================
        // PLOMBERIE / ASSAINISSEMENT
        // ==========================================
        case 'tuyauterie_eau_froide':
        case 'tuyauterie_eau_chaude':
        case 'evacuation_eaux_usees':
          final L = inputs['longueur_ml'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_ml'] ?? 0.0;

          final longFinale = L * (1 + p / 100);
          final total = longFinale * pu;

          return CalculationResult(
            quantity: longFinale,
            amount: total,
            formulaUsed: "$L ml + $p% perte",
            additionalInfo: {'Longueur finale': longFinale},
          );

        case 'appareils_sanitaires':
        case 'robinetterie':
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;
          final pose = inputs['prix_pose'] ?? 0.0;

          final costFourniture = n * pu;
          final costPose = n * pose;
          final total = costFourniture + costPose;

          return CalculationResult(
            quantity: n,
            amount: total,
            formulaUsed: "$n unités (Fourniture: $pu, Pose: $pose)",
            additionalInfo: {'Fourniture': costFourniture, 'Pose': costPose},
          );

        case 'fosse_septique':
        case 'puisard':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final h = inputs['profondeur_m'] ?? 0.0;
          final pu = inputs['prix_m3'] ?? 0.0;

          final volume = L * l * h;
          final total = volume * pu;

          return CalculationResult(
            quantity: volume,
            amount: total,
            formulaUsed: "$L m × $l m × $h m",
            additionalInfo: {'Volume': volume},
          );

        // ==========================================
        // ELECTRICITE
        // ==========================================
        case 'points_lumineux':
        case 'prises':
        case 'interrupteurs':
          final n = inputs['nombre'] ?? 1.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;
          final pose = inputs['prix_pose'] ?? 0.0;

          final costFourniture = n * pu;
          final costPose = n * pose;
          final total = costFourniture + costPose;

          return CalculationResult(
            quantity: n,
            amount: total,
            formulaUsed: "$n unités (Fourniture: $pu, Pose: $pose)",
            additionalInfo: {'Fourniture': costFourniture, 'Pose': costPose},
          );

        case 'cables':
        case 'gaines':
          final L = inputs['longueur_ml'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 0.0;
          final pu = inputs['prix_ml'] ?? 0.0;

          final longFinale = L * (1 + p / 100);
          final total = longFinale * pu;

          return CalculationResult(
            quantity: longFinale,
            amount: total,
            formulaUsed: "$L ml + $p% perte",
            additionalInfo: {'Longueur finale': longFinale},
          );

        // ==========================================
        // VRD
        // ==========================================
        case 'caniveaux':
        case 'bordures':
        case 'canalisation':
          final L = inputs['longueur_ml'] ?? 0.0;
          final pu = inputs['prix_ml'] ?? 0.0;

          final total = L * pu;

          return CalculationResult(
            quantity: L,
            amount: total,
            formulaUsed: "$L ml",
            additionalInfo: {'Longueur': L},
          );

        case 'pavage':
          final L = inputs['longueur_m'] ?? 0.0;
          final l = inputs['largeur_m'] ?? 0.0;
          final p = inputs['perte_percent'] ?? 5.0;
          final pu = inputs['prix_m2'] ?? 0.0;

          final surfBrute = L * l;
          final surfFinale = surfBrute * (1 + p / 100);
          final total = surfFinale * pu;

          return CalculationResult(
            quantity: surfFinale,
            amount: total,
            formulaUsed: "$L m × $l m + $p% perte",
            additionalInfo: {'Surface brute': surfBrute, 'Surface finale': surfFinale},
          );

        // ==========================================
        // CLÔTURE
        // ==========================================
        case 'mur_cloture':
          final L = inputs['longueur_m'] ?? 0.0;
          final h = inputs['hauteur_m'] ?? 0.0;
          final portail = inputs['surface_portail_m2'] ?? 0.0;
          final blocsm2 = inputs['blocs_par_m2'] ?? 12.5;
          final puBloc = inputs['prix_bloc'] ?? 0.0;
          final puEnduit = inputs['prix_enduit_m2'] ?? 0.0;
          final puPeinture = inputs['prix_peinture_m2'] ?? 0.0;

          final surfBrute = L * h;
          if (portail > surfBrute) {
            return CalculationResult.error("La surface du portail ($portail m²) dépasse la surface de clôture ($surfBrute m²).");
          }

          final surfNette = surfBrute - portail;
          final nBlocs = surfNette * blocsm2;
          
          final costBlocs = nBlocs * puBloc;
          final costEnduit = surfNette * 2 * puEnduit; // 2 faces
          final costPeinture = surfNette * 2 * puPeinture; // 2 faces
          final total = costBlocs + costEnduit + costPeinture;

          return CalculationResult(
            quantity: L, // ml of fence
            amount: total,
            formulaUsed: "Long. $L m. Blocs: ${nBlocs.round()} u, Enduit: ${surfNette*2} m², Peinture: ${surfNette*2} m²",
            additionalInfo: {
              'Longueur': L,
              'Surface nette (une face)': surfNette,
              'Nombre blocs': nBlocs,
              'Coût blocs': costBlocs,
              'Coût enduit': costEnduit,
              'Coût peinture': costPeinture
            },
          );

        // ==========================================
        // DIVERS
        // ==========================================
        case 'installation_chantier':
        case 'nettoyage_chantier':
          final forfait = inputs['montant_forfaitaire'] ?? 0.0;
          return CalculationResult(
            quantity: 1.0,
            amount: forfait,
            formulaUsed: "Forfait global",
            additionalInfo: {'Forfait': forfait},
          );

        case 'transport_materiaux':
          final voyages = inputs['nombre_voyages'] ?? 0.0;
          final pu = inputs['prix_voyage'] ?? 0.0;
          final total = voyages * pu;

          return CalculationResult(
            quantity: voyages,
            amount: total,
            formulaUsed: "$voyages voyages × $pu",
            additionalInfo: {'Voyages': voyages},
          );

        case 'main_oeuvre':
          final ouvriers = inputs['nombre_ouvriers'] ?? 0.0;
          final jours = inputs['nombre_jours'] ?? 0.0;
          final pu = inputs['prix_jour'] ?? 0.0;
          final total = ouvriers * jours * pu;

          return CalculationResult(
            quantity: ouvriers * jours,
            amount: total,
            formulaUsed: "$ouvriers ouvriers × $jours jours × $pu/jour",
            additionalInfo: {'Total homme-jours': ouvriers * jours},
          );

        case 'marge_imprevus':
          final totalTravaux = inputs['total_travaux'] ?? 0.0;
          final percent = inputs['pourcentage_imprevus'] ?? 10.0;
          final total = totalTravaux * percent / 100.0;

          return CalculationResult(
            quantity: percent,
            amount: total,
            formulaUsed: "$percent% de $totalTravaux",
            additionalInfo: {'Total travaux': totalTravaux, 'Pourcentage': percent},
          );

        default:
          // Fallback generic calculation: generic quantity * unit price
          final qty = inputs['quantite'] ?? inputs['quantité'] ?? 1.0;
          final pu = inputs['prix_unitaire'] ?? 0.0;
          final total = qty * pu;
          return CalculationResult(
            quantity: qty,
            amount: total,
            formulaUsed: "Saisie directe: $qty",
          );
      }
    } catch (e) {
      return CalculationResult.error("Erreur de calcul : ${e.toString()}");
    }
  }
}
