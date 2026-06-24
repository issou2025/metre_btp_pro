import 'package:flutter/material.dart';
import 'modules/earthwork_screen.dart';
import 'modules/concrete_screen.dart';
import 'modules/reinforcement_screen.dart';
import 'modules/formwork_screen.dart';
import 'modules/masonry_screen.dart';
import 'modules/plaster_screen.dart';
import 'modules/painting_screen.dart';
import 'modules/tile_screen.dart';
import 'modules/flooring_screen.dart';
import 'modules/roofing_screen.dart';
import 'modules/carpentry_screen.dart';
import 'modules/doors_windows_screen.dart';
import 'modules/plumbing_screen.dart';
import 'modules/electricity_screen.dart';
import 'modules/sanitation_screen.dart';
import 'modules/vrd_screen.dart';
import 'modules/fence_screen.dart';
import 'modules/staircase_screen.dart';
import 'modules/ceiling_screen.dart';
import 'modules/waterproofing_screen.dart';
import 'modules/steel_structure_screen.dart';
import 'modules/miscellaneous_screen.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final Widget screen;
  final String subtitle;

  const CategoryItem({
    required this.title,
    required this.icon,
    required this.screen,
    required this.subtitle,
  });
}

class ModuleCategoryScreen extends StatelessWidget {
  final bool isStandalone;

  const ModuleCategoryScreen({
    super.key,
    required this.isStandalone,
  });

  @override
  Widget build(BuildContext context) {
    // 22 categories corresponding to all required screens
    final List<CategoryItem> categories = [
      const CategoryItem(title: "Terrassements", subtitle: "Fouilles, déblais, remblais...", icon: Icons.terrain, screen: const EarthworkScreen()),
      const CategoryItem(title: "Béton", subtitle: "Semelles, dalles, poteaux...", icon: Icons.layers, screen: const ConcreteScreen()),
      const CategoryItem(title: "Ferraillage", subtitle: "Aciers, étriers, treillis...", icon: Icons.grid_4x4, screen: const ReinforcementScreen()),
      const CategoryItem(title: "Coffrage", subtitle: "Coffrage poteaux, poutres...", icon: Icons.view_quilt, screen: const FormworkScreen()),
      const CategoryItem(title: "Maçonnerie", subtitle: "Murs parpaings, briques...", icon: Icons.domain, screen: const MasonryScreen()),
      const CategoryItem(title: "Enduits", subtitle: "Enduits intérieur & extérieur", icon: Icons.format_paint, screen: const PlasterScreen()),
      const CategoryItem(title: "Peinture", subtitle: "Couches, litres, rendement...", icon: Icons.brush, screen: const PaintingScreen()),
      const CategoryItem(title: "Carrelage", subtitle: "Sols et faïence murale", icon: Icons.grid_on, screen: const TileScreen()),
      const CategoryItem(title: "Chape et Sols", subtitle: "Chape ciment, lissage...", icon: Icons.border_inner, screen: const FlooringScreen()),
      const CategoryItem(title: "Toiture", subtitle: "Simple/double pente, tôle...", icon: Icons.home, screen: const RoofingScreen()),
      const CategoryItem(title: "Charpente Bois", subtitle: "Fermes, pannes, chevrons...", icon: Icons.carpenter, screen: const CarpentryScreen()),
      const CategoryItem(title: "Charpente Métallique", subtitle: "Treillis, structures acier...", icon: Icons.construction, screen: const SteelStructureScreen()),
      const CategoryItem(title: "Menuiseries", subtitle: "Portes, fenêtres, vitrages...", icon: Icons.door_front_door, screen: const DoorsWindowsScreen()),
      const CategoryItem(title: "Plomberie", subtitle: "Canalisations, sanitaires...", icon: Icons.water_drop, screen: const PlumbingScreen()),
      const CategoryItem(title: "Assainissement", subtitle: "Fosse septique, puisards...", icon: Icons.clean_hands, screen: const SanitationScreen()),
      const CategoryItem(title: "Électricité", subtitle: "Câbles, gaines, prises...", icon: Icons.electrical_services, screen: const ElectricityScreen()),
      const CategoryItem(title: "VRD", subtitle: "Caniveaux, bordures, pavage...", icon: Icons.add_road, screen: const VrdScreen()),
      const CategoryItem(title: "Clôture", subtitle: "Mur de clôture complet...", icon: Icons.fence, screen: const FenceScreen()),
      const CategoryItem(title: "Escaliers", subtitle: "Calcul d'escalier béton...", icon: Icons.stairs, screen: const StaircaseScreen()),
      const CategoryItem(title: "Faux Plafonds", subtitle: "Suspendus, plaques...", icon: Icons.aspect_ratio, screen: const CeilingScreen()),
      const CategoryItem(title: "Étanchéité", subtitle: "Toiture terrasse, relevés...", icon: Icons.umbrella, screen: const WaterproofingScreen()),
      const CategoryItem(title: "Divers", subtitle: "Main d'œuvre, imprévus, logistique...", icon: Icons.more_horiz, screen: const MiscellaneousScreen()),
    ];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode ? const Color(0xFF0A1929) : const Color(0xFFF7F8FA);
    final cardBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          isStandalone ? "Calcul Rapide" : "Sélectionner une catégorie",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmallScreen = width < 360;
            final isTablet = width >= 600;
            
            final crossAxisCount = isTablet ? 4 : (isSmallScreen ? 1 : 2);
            final childAspectRatio = isSmallScreen ? 2.8 : (isTablet ? 1.25 : 1.35);

            return Column(
              children: [
                // Informational header banner
                Container(
                  color: const Color(0xFF0F2A44),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  width: double.infinity,
                  child: Text(
                    isStandalone 
                        ? "Choisissez un module pour effectuer un calcul rapide sans enregistrer dans un projet."
                        : "Choisissez une catégorie de travaux pour calculer et ajouter des lignes à votre devis.",
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ),
                
                // Grid of categories
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.015),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => cat.screen),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E8E5A).withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(cat.icon, color: const Color(0xFF1E8E5A), size: 18),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: titleColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cat.subtitle,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: subtitleColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
