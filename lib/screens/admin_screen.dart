import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int? _downloadCount;
  List<dynamic> _usersList = [];
  List<dynamic> _activitiesList = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();
  final _serverIpController = TextEditingController();
  String? _loginError;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _serverIpController.text = appState.serverIp;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _serverIpController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serverIp = Provider.of<AppState>(context, listen: false).serverIp;
      
      // 1. Fetch download stats
      final statsResponse = await http.get(Uri.parse('http://$serverIp:8000/stats?password=mx23fy')).timeout(
        const Duration(seconds: 4),
      );

      if (statsResponse.statusCode == 200) {
        final data = json.decode(statsResponse.body);
        _downloadCount = data['downloads'] ?? 0;
      } else if (statsResponse.statusCode == 401) {
        setState(() {
          _errorMessage = "Non autorisé : Mot de passe refusé par le serveur.";
          _isLoading = false;
        });
        return;
      } else {
        throw Exception("Stats error code: ${statsResponse.statusCode}");
      }

      // 2. Fetch active users list
      final usersResponse = await http.get(Uri.parse('http://$serverIp:8000/users?password=mx23fy')).timeout(
        const Duration(seconds: 4),
      );

      if (usersResponse.statusCode == 200) {
        final List<dynamic> usersData = json.decode(usersResponse.body);
        _usersList = usersData;
      } else {
        throw Exception("Users error code: ${usersResponse.statusCode}");
      }

      // 3. Fetch user activities log
      final activitiesResponse = await http.get(Uri.parse('http://$serverIp:8000/activities?password=mx23fy')).timeout(
        const Duration(seconds: 4),
      );

      if (activitiesResponse.statusCode == 200) {
        final List<dynamic> activitiesData = json.decode(activitiesResponse.body);
        setState(() {
          _activitiesList = activitiesData;
          _isLoading = false;
        });
      } else {
        throw Exception("Activities error code: ${activitiesResponse.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Impossible de se connecter au serveur Python.\n"
            "Vérifiez que le serveur est démarré sur le port 8000 et accessible.";
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateDownload() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serverIp = Provider.of<AppState>(context, listen: false).serverIp;
      final response = await http.get(Uri.parse('http://$serverIp:8000/download')).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Téléchargement simulé avec succès (+1) !"),
              backgroundColor: Color(0xFF1E8E5A),
            ),
          );
        }
        _fetchStats();
      } else {
        setState(() {
          _errorMessage = "Erreur de simulation : Code ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Impossible de joindre le serveur pour la simulation.";
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F2A44),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleLogin() {
    final password = _passwordController.text.trim();
    if (password == "mx23fy") {
      setState(() {
        _isAuthenticated = true;
        _loginError = null;
      });
      _fetchStats();
    } else {
      setState(() {
        _loginError = "Mot de passe incorrect. Réessayez.";
      });
    }
  }

  Widget _buildLoginView(Color cardBgColor, Color textColor, Color textMutedColor, bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: cardBgColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF0F2A44),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "Accès Sécurisé",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Entrez le mot de passe administrateur pour consulter les statistiques.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: textMutedColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: TextStyle(color: textMutedColor),
                    prefixIcon: const Icon(Icons.key, color: Color(0xFF0F2A44)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: textMutedColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0F2A44), width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
                if (_loginError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _loginError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8E5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _handleLogin,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Se connecter",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUsersCard(Color cardBgColor, Color textColor, Color textMutedColor, bool isDarkMode) {
    return Card(
      color: cardBgColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline, color: Color(0xFF1E8E5A), size: 20),
                const SizedBox(width: 8),
                Text(
                  "UTILISATEURS ACTIFS DE L'APK",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading && _usersList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8E5A)),
                  ),
                ),
              )
            else if (_errorMessage != null && _usersList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Données indisponibles",
                    style: TextStyle(color: textMutedColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else if (_usersList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    "Aucun utilisateur actif enregistré pour le moment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usersList.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final user = _usersList[index];
                  final name = user['company_name'] ?? 'Anonyme';
                  final phone = user['phone'] ?? '';
                  final email = user['email'] ?? '';
                  final device = user['device'] ?? 'Inconnu';
                  final projectsCount = user['projects_count'] ?? 0;
                  final lastSeen = user['last_seen'] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E8E5A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$projectsCount projet(s)",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E8E5A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (phone.isNotEmpty || email.isNotEmpty) ...[
                        Row(
                          children: [
                            if (phone.isNotEmpty) ...[
                              Icon(Icons.phone, size: 12, color: textMutedColor),
                              const SizedBox(width: 4),
                              Text(phone, style: TextStyle(fontSize: 12, color: textMutedColor)),
                              const SizedBox(width: 12),
                            ],
                            if (email.isNotEmpty) ...[
                              Icon(Icons.email, size: 12, color: textMutedColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(fontSize: 12, color: textMutedColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.devices, size: 12, color: textMutedColor),
                              const SizedBox(width: 4),
                              Text(device, style: TextStyle(fontSize: 11, color: textMutedColor)),
                            ],
                          ),
                          Text(
                            "Vu le : $lastSeen",
                            style: TextStyle(fontSize: 11, color: textMutedColor, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLogCard(Color cardBgColor, Color textColor, Color textMutedColor, bool isDarkMode) {
    return Card(
      color: cardBgColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Color(0xFF1E8E5A), size: 20),
                const SizedBox(width: 8),
                Text(
                  "JOURNAL D'ACTIVITÉ EN DIRECT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading && _activitiesList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8E5A)),
                  ),
                ),
              )
            else if (_errorMessage != null && _activitiesList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Données indisponibles",
                    style: TextStyle(color: textMutedColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else if (_activitiesList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    "Aucune activité enregistrée pour le moment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activitiesList.length > 25 ? 25 : _activitiesList.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final activity = _activitiesList[index];
                  final time = activity['timestamp'] ?? '';
                  final user = activity['company_name'] ?? 'Anonyme';
                  final action = activity['action'] ?? '';
                  final details = activity['details'] ?? '';
                  final device = activity['device'] ?? 'Inconnu';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2A44).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              action,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2A44),
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 11,
                              color: textMutedColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Par : $user ($device)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          details,
                          style: TextStyle(
                            fontSize: 12,
                            color: textMutedColor,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = appState.themeMode == "Sombre" ||
        (appState.themeMode == "Système" &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B132B) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Console Administrateur",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2A44),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: _isAuthenticated
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: "Se déconnecter",
                  onPressed: () {
                    setState(() {
                      _isAuthenticated = false;
                      _passwordController.clear();
                      _usersList.clear();
                      _activitiesList.clear();
                    });
                  },
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: !_isAuthenticated
            ? _buildLoginView(cardBgColor, textColor, textMutedColor, isDarkMode)
            : RefreshIndicator(
                onRefresh: _fetchStats,
                color: const Color(0xFF1E8E5A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Intro banner
                      Card(
                        color: const Color(0xFF0F2A44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Suivi des Téléchargements APK",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Cette console se connecte au serveur Python local pour suivre la distribution et l'activité de l'application auprès des utilisateurs.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main download statistic card
                      Card(
                        color: cardBgColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
                          child: Column(
                            children: [
                              Text(
                                "TÉLÉCHARGEMENTS ACTUELS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textMutedColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_isLoading && _downloadCount == null)
                                const SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8E5A)),
                                    ),
                                  ),
                                )
                              else if (_errorMessage != null && _downloadCount == null)
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 64,
                                )
                              else
                                Text(
                                  _downloadCount != null ? "$_downloadCount" : "--",
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E8E5A),
                                    letterSpacing: -1,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (_errorMessage != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Server IP Configuration Panel
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.amber.shade50.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade300, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.settings_ethernet, color: Colors.amber, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            "CONFIGURATION DE L'IP DU SERVEUR",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Sur un vrai téléphone, n'utilisez pas 'localhost'. Remplacez par l'adresse IP locale de votre ordinateur (ex: 192.168.1.50) et vérifiez que votre téléphone est sur le même Wi-Fi.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textMutedColor,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 42,
                                              child: TextField(
                                                controller: _serverIpController,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: textColor,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "Ex: 192.168.1.50",
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  filled: true,
                                                  fillColor: isDarkMode
                                                      ? const Color(0xFF0F172A)
                                                      : Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                      color: Color(0xFF1E8E5A),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E8E5A),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 10,
                                              ),
                                              minimumSize: const Size(0, 42),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final newIp = _serverIpController.text.trim();
                                              if (newIp.isNotEmpty) {
                                                await appState.updateSettings(
                                                  currency: appState.defaultCurrency,
                                                  lossPercentage: appState.defaultLossPercentage,
                                                  themeMode: appState.themeMode,
                                                  serverIp: newIp,
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text("Adresse IP du serveur mise à jour !"),
                                                    backgroundColor: Color(0xFF1E8E5A),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                                _fetchStats();
                                              }
                                            },
                                            child: const Text(
                                              "Mettre à jour",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "💡 Tapez 'ipconfig' dans l'invite de commande (cmd) sur votre PC pour trouver son adresse IP locale.",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textMutedColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Server Launch Instructions Card
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Comment lancer le serveur ?",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "1. Ouvrez un terminal dans le dossier du projet.\n"
                                        "2. Exécutez : python server.py\n"
                                        "3. Cliquez sur Rafraîchir ci-dessous.",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textMutedColor,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F2A44),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _isLoading ? null : _fetchStats,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text("Rafraîchir"),
                                  ),
                                  if (_errorMessage == null && _downloadCount != null) ...[
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1E8E5A),
                                        side: const BorderSide(color: Color(0xFF1E8E5A)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: _isLoading ? null : _simulateDownload,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text("Simuler +1"),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Users active card
                      _buildActiveUsersCard(cardBgColor, textColor, textMutedColor, isDarkMode),
                      const SizedBox(height: 16),

                      // User activities log feed
                      _buildActivityLogCard(cardBgColor, textColor, textMutedColor, isDarkMode),
                      const SizedBox(height: 16),

                      // Server Links & Tools Card
                      Card(
                        color: cardBgColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "LIENS UTILES DU SERVEUR LOCAL",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLinkRow(
                                context,
                                title: "Lien de téléchargement APK",
                                url: "http://${appState.serverIp}:8000/download",
                                icon: Icons.download,
                                isDarkMode: isDarkMode,
                              ),
                              const Divider(height: 24),
                              _buildLinkRow(
                                context,
                                title: "Dashboard d'administration Web",
                                url: "http://${appState.serverIp}:8000/admin?password=mx23fy",
                                icon: Icons.web,
                                isDarkMode: isDarkMode,
                              ),
                              const Divider(height: 24),
                              _buildLinkRow(
                                context,
                                title: "API Endpoint (JSON) Stats",
                                url: "http://${appState.serverIp}:8000/stats?password=mx23fy",
                                icon: Icons.api,
                                isDarkMode: isDarkMode,
                              ),
                              const Divider(height: 24),
                              _buildLinkRow(
                                context,
                                title: "API Endpoint (JSON) Users",
                                url: "http://${appState.serverIp}:8000/users?password=mx23fy",
                                icon: Icons.api,
                                isDarkMode: isDarkMode,
                              ),
                              const Divider(height: 24),
                              _buildLinkRow(
                                context,
                                title: "API Endpoint (JSON) Activities",
                                url: "http://${appState.serverIp}:8000/activities?password=mx23fy",
                                icon: Icons.api,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Developer Contacts Info Card
                      Card(
                        color: cardBgColor,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.engineering, color: Color(0xFF1E8E5A), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "DÉVELOPPEUR DE L'APPLICATION",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Issoufou Abdou",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Ingénieur Génie Civil\nSpécialiste en applications métiers du bâtiment",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textMutedColor,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => _copyToClipboard(
                                  "+22796380877",
                                  "Numéro de téléphone copié !",
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E8E5A).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Color(0xFF1E8E5A)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "+227 96 38 08 77",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDarkMode ? Colors.greenAccent : const Color(0xFF1E8E5A),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.copy,
                                        size: 12,
                                        color: isDarkMode ? Colors.greenAccent : const Color(0xFF1E8E5A),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context, {
    required String title,
    required String url,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2A44);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0F2A44), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                url,
                style: TextStyle(
                  fontSize: 12,
                  color: textMutedColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          color: const Color(0xFF1E8E5A),
          tooltip: "Copier le lien",
          onPressed: () => _copyToClipboard(
            url,
            "Lien copié dans le presse-papiers !",
          ),
        ),
      ],
    );
  }
}
