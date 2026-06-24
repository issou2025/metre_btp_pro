import 'dart:async';
import 'package:flutter/material.dart';
import '../services/github_download_service.dart';

class AdminDownloadCountCard extends StatefulWidget {
  const AdminDownloadCountCard({super.key});

  @override
  State<AdminDownloadCountCard> createState() => _AdminDownloadCountCardState();
}

class _AdminDownloadCountCardState extends State<AdminDownloadCountCard> {
  int? downloadCount;
  bool loading = true;
  String? error;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadDownloads();

    timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadDownloads(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadDownloads() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final int count = await GithubDownloadService.getApkDownloadCount();

      if (!mounted) return;

      setState(() {
        downloadCount = count;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF12324F);
    final textMutedColor = isDarkMode ? Colors.grey.shade400 : Colors.black54;

    return Card(
      elevation: 2,
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "TÉLÉCHARGEMENTS APK",
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 28),

            if (loading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E8E5A)),
              ),

            if (error != null)
              Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 58,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: loadDownloads,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Réessayer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2A44),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

            if (!loading && error == null && downloadCount != null)
              Column(
                children: [
                  const Icon(
                    Icons.download_done_rounded,
                    color: Color(0xFF1E8E5A),
                    size: 72,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "$downloadCount",
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Téléchargements depuis GitHub",
                    style: TextStyle(
                      fontSize: 16,
                      color: textMutedColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: loadDownloads,
                    icon: const Icon(Icons.sync),
                    label: const Text("Synchroniser GitHub"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2A44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
