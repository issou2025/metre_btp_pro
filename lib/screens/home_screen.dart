import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'project_create_screen.dart';
import 'project_list_screen.dart';
import 'module_category_screen.dart';
import 'unit_price_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tabs: 0 = Dallage, 1 = Maçonnerie, 2 = Enduits/Peinture
  int _activeTab = 0;

  // Controllers for Concrete Dallage
  final _lenController = TextEditingController(text: "4.0");
  final _widController = TextEditingController(text: "3.0");
  final _thkController = TextEditingController(text: "0.15");
  double _volume = 1.80;
  double _ciment = 12.6;

  // Controllers for Masonry
  final _masLenController = TextEditingController(text: "10.0");
  final _masHeiController = TextEditingController(text: "3.0");
  double _masBlocks = 375.0; // 10 * 3 * 12.5 blocks/m2
  double _masCement = 11.25; // 375 * 1.5kg / 50kg bag

  // Controllers for Finishes
  final _finLenController = TextEditingController(text: "10.0");
  final _finHeiController = TextEditingController(text: "3.0");
  double _finFaces = 2.0;
  double _finArea = 60.0;
  double _finPaint = 20.0; // 60 * 2 / 6 L

  @override
  void initState() {
    super.initState();
    _lenController.addListener(_calculateConcrete);
    _widController.addListener(_calculateConcrete);
    _thkController.addListener(_calculateConcrete);
    
    _masLenController.addListener(_calculateMasonry);
    _masHeiController.addListener(_calculateMasonry);
    
    _finLenController.addListener(_calculateFinishes);
    _finHeiController.addListener(_calculateFinishes);
  }

  @override
  void dispose() {
    _lenController.dispose();
    _widController.dispose();
    _thkController.dispose();
    
    _masLenController.dispose();
    _masHeiController.dispose();
    
    _finLenController.dispose();
    _finHeiController.dispose();
    super.dispose();
  }

  void _calculateConcrete() {
    final l = double.tryParse(_lenController.text) ?? 0.0;
    final w = double.tryParse(_widController.text) ?? 0.0;
    final t = double.tryParse(_thkController.text) ?? 0.0;
    setState(() {
      _volume = l * w * t;
      _ciment = _volume * 350 / 50; // standard dosage: 350 kg/m3 ciment, bags of 50kg -> 7 bags per m3
    });
  }

  void _calculateMasonry() {
    final l = double.tryParse(_masLenController.text) ?? 0.0;
    final h = double.tryParse(_masHeiController.text) ?? 0.0;
    setState(() {
      _masBlocks = l * h * 12.5; // standard block density: 12.5 blocks per m2
      _masCement = _masBlocks * 1.5 / 50; // standard mortar density: 1.5kg cement per block
    });
  }

  void _calculateFinishes() {
    final l = double.tryParse(_finLenController.text) ?? 0.0;
    final h = double.tryParse(_finHeiController.text) ?? 0.0;
    setState(() {
      _finArea = l * h * _finFaces;
      _finPaint = _finArea * 2 / 6; // 2 layers, standard coverage: 6m2 per liter per coat
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final projectsCount = appState.projects.length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1929) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            
            // Responsive grid adjustments
            final isSmallScreen = width < 360;
            final isTablet = width >= 600;
            
            final crossAxisCount = isTablet ? 4 : (isSmallScreen ? 1 : 2);
            final childAspectRatio = isSmallScreen ? 2.8 : (isTablet ? 1.2 : 1.3);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Gradient Header Banner
                  _buildHeader(context, projectsCount),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Calculateur Express Béton Card
                        _buildCalculateurExpress(isDarkMode),
                        const SizedBox(height: 24),

                        Text(
                          "ACTIONS DE CHANTIER",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDarkMode ? Colors.grey.shade400 : const Color(0xFF8E9AA8),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Nouveau Projet Card (Primary Action - Green accent)
                        _buildPrimaryActionCard(
                          context: context,
                          title: "Nouveau Projet",
                          subtitle: "Démarrer un nouveau devis quantitatif",
                          icon: Icons.add_circle,
                          color: const Color(0xFF1E8E5A), // Forest Green
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProjectCreateScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Grid for other actions (Adaptive columns)
                        GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildGridActionCard(
                              context: context,
                              title: "Mes Projets",
                              subtitle: "$projectsCount projet(s) actif(s)",
                              icon: Icons.folder,
                              iconColor: const Color(0xFF0F2A44),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProjectListScreen()),
                                );
                              },
                            ),
                            _buildGridActionCard(
                              context: context,
                              title: "Calcul Rapide",
                              subtitle: "Calculateur sans projet",
                              icon: Icons.calculate,
                              iconColor: const Color(0xFF0F2A44),
                              onTap: () {
                                final state = Provider.of<AppState>(context, listen: false);
                                state.selectProject(null);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ModuleCategoryScreen(isStandalone: true)),
                                );
                              },
                            ),
                            _buildGridActionCard(
                              context: context,
                              title: "Prix Unitaires",
                              subtitle: "Tarifs de référence",
                              icon: Icons.payments,
                              iconColor: const Color(0xFF0F2A44),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UnitPriceScreen()),
                                );
                              },
                            ),
                            _buildGridActionCard(
                              context: context,
                              title: "Paramètres",
                              subtitle: "Profil entreprise & devise",
                              icon: Icons.settings,
                              iconColor: const Color(0xFF0F2A44),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Guide & Développeur Card
                        _buildPrimaryActionCard(
                          context: context,
                          title: "Guide & Développeur",
                          subtitle: "Tutoriel d'utilisation & Contacts d'assistance BTP",
                          icon: Icons.help_outline,
                          color: const Color(0xFF0F2A44),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TutorialScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int projectsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2A44), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Métré BTP Pro",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Outil intelligent d'estimation de chantier",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade200,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.engineering,
                  size: 28,
                  color: Color(0xFF1E8E5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Row with glassmorphism layout
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("PROJETS", "$projectsCount", Icons.business),
                Container(width: 1, height: 24, color: Colors.white.withOpacity(0.15)),
                _buildStatItem("MODE STOCKAGE", "100% Local", Icons.storage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E8E5A), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.blueGrey.shade200, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildCalculateurExpress(bool isDarkMode) {
    final cardBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E8E5A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calculate, color: Color(0xFF1E8E5A), size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  "CALCULATEUR RAPIDE DE CHANTIER",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Tab Selector Row
            Row(
              children: [
                _buildTabButton(0, "Dallage", Icons.layers, isDarkMode),
                const SizedBox(width: 6),
                _buildTabButton(1, "Maçonnerie", Icons.widgets, isDarkMode),
                const SizedBox(width: 6),
                _buildTabButton(2, "Enduit/Peint.", Icons.format_paint, isDarkMode),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_activeTab == 0) ...[
              // Dallage Inputs
              Row(
                children: [
                  Expanded(child: _buildExpressInputField(controller: _lenController, label: "Longueur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildExpressInputField(controller: _widController, label: "Largeur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildExpressInputField(controller: _thkController, label: "Épaisseur", suffix: "m", isDarkMode: isDarkMode)),
                ],
              ),
              const SizedBox(height: 16),
              _buildExpressResults(
                label1: "BÉTON REQUIS",
                value1: "${_volume.toStringAsFixed(2)} m³",
                label2: "SAC(S) DE CIMENT (50KG)",
                value2: "${_ciment.round()} sacs",
                note: "Dosage béton standard estimé à 350 kg/m³",
                isDarkMode: isDarkMode,
              ),
            ] else if (_activeTab == 1) ...[
              // Masonry Inputs
              Row(
                children: [
                  Expanded(child: _buildExpressInputField(controller: _masLenController, label: "Longueur mur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildExpressInputField(controller: _masHeiController, label: "Hauteur mur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Type de bloc",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMutedColor),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "15x20x40 cm",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExpressResults(
                label1: "PARPAINGS REQUIS",
                value1: "${_masBlocks.round()} blocs",
                label2: "CIMENT (MORTIER)",
                value2: "${_masCement.round()} sacs",
                note: "Est. 1.5 kg ciment par bloc (12.5 blocs/m²)",
                isDarkMode: isDarkMode,
              ),
            ] else ...[
              // Finishes Inputs
              Row(
                children: [
                  Expanded(child: _buildExpressInputField(controller: _finLenController, label: "Longueur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildExpressInputField(controller: _finHeiController, label: "Hauteur", suffix: "m", isDarkMode: isDarkMode)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nombre faces",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMutedColor),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _finFaces = 1.0;
                                    _calculateFinishes();
                                  });
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _finFaces == 1.0 ? const Color(0xFF1E8E5A) : (isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                    border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "1",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _finFaces == 1.0 ? Colors.white : textColor),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _finFaces = 2.0;
                                    _calculateFinishes();
                                  });
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _finFaces == 2.0 ? const Color(0xFF1E8E5A) : (isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50),
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                    border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "2",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _finFaces == 2.0 ? Colors.white : textColor),
                                  ),
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
              const SizedBox(height: 16),
              _buildExpressResults(
                label1: "SURFACE TOTALE",
                value1: "${_finArea.toStringAsFixed(1)} m²",
                label2: "PEINTURE ESTIMÉE",
                value2: "${_finPaint.toStringAsFixed(1)} L",
                note: "Rendement moyen de 6 m²/L pour 2 couches",
                isDarkMode: isDarkMode,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon, bool isDarkMode) {
    final isSelected = _activeTab == index;
    final selectedColor = const Color(0xFF1E8E5A);
    final unselectedBg = isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? selectedColor : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpressResults({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
    required String note,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E8E5A).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E8E5A).withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label1,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textMutedColor, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value1,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E8E5A)),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFF1E8E5A).withOpacity(0.2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label2,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textMutedColor, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value2,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            note,
            style: TextStyle(fontSize: 9, color: textMutedColor, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildExpressInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required bool isDarkMode,
  }) {
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputBg = isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textMutedColor),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : const Color(0xFF0F2A44), fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              suffixText: suffix,
              suffixStyle: TextStyle(fontSize: 10, color: textMutedColor),
              filled: true,
              fillColor: inputBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1E8E5A), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withRed((color.red + 15).clamp(0, 255))],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? const Color(0xFF0E2238) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
  }
}
