import 'package:flutter_test/flutter_test.dart';
import 'package:metre_btp_pro/services/calculation_service.dart';

void main() {
  group('Tests CalculationService - Terrassements', () {
    test('Fouilles pour semelles isolées', () {
      final inputs = {
        'longueur_m': 1.20,
        'largeur_m': 1.20,
        'profondeur_m': 1.50,
        'nombre': 6.0,
        'perte_percent': 5.0,
      };

      final result = CalculationService.calculate('fouilles_semelles', inputs);
      
      // Volume brut: 1.2 * 1.2 * 1.5 * 6 = 12.96 m³
      // Volume final: 12.96 * 1.05 = 13.608 m³
      expect(result.errorMessage, isNull);
      expect(result.quantity, closeTo(13.61, 0.01));
      expect(result.additionalInfo['Volume brut'], closeTo(12.96, 0.01));
    });

    test('Décapage terrain', () {
      final inputs = {
        'longueur_m': 10.0,
        'largeur_m': 10.0,
        'epaisseur_m': 0.20,
      };

      final result = CalculationService.calculate('decapage', inputs);
      // Volume: 10 * 10 * 0.2 = 20.0 m³
      expect(result.quantity, equals(20.0));
      expect(result.additionalInfo['Surface'], equals(100.0));
    });
  });

  group('Tests CalculationService - Béton', () {
    test('Béton de propreté & sacs de ciment', () {
      final inputs = {
        'longueur_m': 5.0,
        'largeur_m': 2.0,
        'epaisseur_m': 0.10,
        'nombre': 1.0,
        'dosage_kg_m3': 150.0,
      };

      final result = CalculationService.calculate('beton_proprete', inputs);
      // Volume: 5 * 2 * 0.1 * 1 = 1.0 m³
      // Ciment sacs: (1 * 150) / 50 = 3.0 sacs
      expect(result.quantity, equals(1.0));
      expect(result.cimentSacs, equals(3.0));
    });

    test('Escalier béton volume total', () {
      final inputs = {
        'largeur_m': 1.0,
        'hauteur_marche_m': 0.17,
        'giron_m': 0.30,
        'nombre_marches': 10.0,
        'epaisseur_paillasse_m': 0.15,
        'prix_m3': 80000.0,
      };

      final result = CalculationService.calculate('escalier_beton', inputs);
      // Vol. Marches: 1.0 * 0.17 * 0.30 * 10 / 2 = 0.255 m³
      // Long. dev: 0.30 * 10 = 3.0 m
      // Vol. Paillasse: 1.0 * 3.0 * 0.15 = 0.45 m³
      // Vol. Total: 0.255 + 0.45 = 0.705 m³
      // Montant: 0.705 * 80000 = 56400.0
      expect(result.quantity, closeTo(0.705, 0.001));
      expect(result.amount, closeTo(56400.0, 0.1));
    });
  });

  group('Tests CalculationService - Ferraillage', () {
    test('Calcul d\'étriers de ferraillage', () {
      final inputs = {
        'largeur_element_m': 0.15,
        'hauteur_element_m': 0.35,
        'recouvrement_m': 0.10,
        'espacement_m': 0.15,
        'longueur_element_m': 3.00,
        'diametre_mm': 6.0,
        'nombre_elements': 1.0,
        'prix_kg': 450.0,
      };

      final result = CalculationService.calculate('etriers', inputs);
      // Longueur étrier: 2*(0.15 + 0.35) + 0.10 = 1.10 m
      // Nombre étriers: (3.0 / 0.15) * 1 = 20 étriers
      // Longueur totale: 1.1 * 20 = 22.0 m
      // Poids linéaire Ø6: (6*6)/162 = 0.2222 kg/m
      // Poids total: 22.0 * 0.2222 = 4.888 kg
      expect(result.errorMessage, isNull);
      expect(result.additionalInfo['Nombre étriers'], equals(20.0));
      expect(result.quantity, closeTo(4.89, 0.05));
    });

    test('Éviter division par zéro sur espacement étriers', () {
      final inputs = {
        'largeur_element_m': 0.15,
        'hauteur_element_m': 0.35,
        'recouvrement_m': 0.10,
        'espacement_m': 0.00, // zero espacement!
        'longueur_element_m': 3.00,
        'diametre_mm': 6.0,
        'nombre_elements': 1.0,
      };

      final result = CalculationService.calculate('etriers', inputs);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains("zéro"));
    });
  });

  group('Tests CalculationService - Maçonnerie & Finitions', () {
    test('Mur parpaings et contrôle ouvertures', () {
      final inputs = {
        'longueur_m': 10.0,
        'hauteur_m': 3.0,
        'surface_ouvertures_m2': 4.0, // ex: porte + fenetre
        'blocs_par_m2': 12.5,
        'perte_percent': 5.0,
        'prix_bloc': 400.0,
        'prix_pose_m2': 1500.0,
      };

      final result = CalculationService.calculate('murs_parpaings', inputs);
      // Surf brute: 10 * 3 = 30.0 m²
      // Surf nette: 30 - 4 = 26.0 m²
      // Blocs bruts: 26 * 12.5 = 325 u
      // Blocs finaux: 325 * 1.05 = 341.25 u
      // Coût blocs: 341.25 * 400 = 136 500
      // Coût pose: 26 * 1500 = 39 000
      // Total: 136 500 + 39 000 = 175 500
      expect(result.errorMessage, isNull);
      expect(result.quantity, equals(341.25));
      expect(result.amount, equals(175500.0));
    });

    test('Erreur si surface ouvertures dépasse la surface brute du mur', () {
      final inputs = {
        'longueur_m': 5.0,
        'hauteur_m': 2.5,
        'surface_ouvertures_m2': 15.0, // 15m² > 12.5m²!
        'blocs_par_m2': 12.5,
        'perte_percent': 5.0,
      };

      final result = CalculationService.calculate('murs_parpaings', inputs);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains("dépasse"));
    });
  });

  group('Tests CalculationService - Validations générales', () {
    test('Erreur si valeurs négatives fournies', () {
      final inputs = {
        'longueur_m': -5.0, // negative!
        'largeur_m': 2.0,
        'epaisseur_m': 0.10,
      };

      final result = CalculationService.calculate('decapage', inputs);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains("positifs"));
    });
  });
}
