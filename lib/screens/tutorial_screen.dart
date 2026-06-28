import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Guide d'utilisation & Contact",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. WELCOME BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2A44), Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenue sur Métré BTP Pro !",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Ce guide vous explique rapidement comment tirer le meilleur parti de l'application pour vos estimations de chantier.",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. TUTORIAL STEPS
              const Text(
                "COMMENT UTILISER L'APPLICATION ?",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 10),
              _buildStepTile(
                stepNumber: "1",
                title: "Configurez votre entreprise",
                description: "Allez dans 'Paramètres' pour saisir le nom de votre entreprise, son téléphone, son adresse et son NIF. Ces informations s'afficheront automatiquement sur l'en-tête de vos devis PDF.",
                icon: Icons.business,
              ),
              _buildStepTile(
                stepNumber: "2",
                title: "Créez un projet de métré",
                description: "Cliquez sur 'Nouveau Projet' sur la page d'accueil. Renseignez le nom (ex: Villa F4 R+0), le client, la ville, et choisissez la devise de travail (FCFA, EUR, USD).",
                icon: Icons.create_new_folder,
              ),
              _buildStepTile(
                stepNumber: "3",
                title: "Effectuez vos calculs de quantité",
                description: "Ouvrez le projet créé et cliquez sur 'Ajouter Métré'. Choisissez une catégorie (ex: Béton) puis un module (ex: Semelles isolées). Saisissez les dimensions de votre plan : les calculs de volume, de surface, d'acier et de sacs de ciment s'effectuent en temps réel !",
                icon: Icons.calculate,
              ),
              _buildStepTile(
                stepNumber: "4",
                title: "Appliquez vos prix unitaires",
                description: "Le système charge automatiquement le prix unitaire par défaut configuré dans l'application. Vous pouvez le modifier pour chaque ligne de calcul ou changer les tarifs de référence globaux dans l'écran 'Prix Unitaires'.",
                icon: Icons.payments,
              ),
              _buildStepTile(
                stepNumber: "5",
                title: "Ajustez le récapitulatif financier",
                description: "Dans l'écran 'Récapitulatif', vous visualisez vos lignes de devis regroupées par catégorie avec des sous-totaux. Vous pouvez appliquer des pourcentages d'imprévus (contingences) ou une remise globale.",
                icon: Icons.summarize,
              ),
              _buildStepTile(
                stepNumber: "6",
                title: "Générez et partagez le devis PDF",
                description: "Cliquez sur 'Exporter PDF'. L'application génère un Devis Quantitatif Estimatif (DQE) officiel, prêt à être imprimé ou partagé par e-mail ou WhatsApp avec votre client.",
                icon: Icons.picture_as_pdf,
              ),
              const SizedBox(height: 24),

              // 3. DEVELOPER PROFILE CARD
              const Text(
                "DÉVELOPPEUR DE L'APPLICATION",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E8E5A), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E8E5A).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.engineering, color: Color(0xFF1E8E5A), size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Issoufou Abdou",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2A44),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Ingénieur Génie Civil & Développeur",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E8E5A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      "Besoin d'une application sur-mesure de génie civil (calcul de structure, gestion de chantier, planification, etc.) ou d'une adaptation spécifique de ce logiciel ?",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, color: Color(0xFF0F2A44), size: 18),
                        const SizedBox(width: 6),
                        SelectableText(
                          "+227 96 38 08 77",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2A44),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF0F2A44).withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Contactez-moi directement pour toute collaboration.",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF0F2A44),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFF1E8E5A)),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F2A44)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
