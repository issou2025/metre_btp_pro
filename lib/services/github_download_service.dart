import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubDownloadService {
  static const String owner = "issou2025";
  static const String repo = "metre_btp_pro";
  static const String apkFileName = "metre_btp_pro.apk";

  static Future<int> getApkDownloadCount() async {
    final Uri url = Uri.parse(
      "https://api.github.com/repos/$owner/$repo/releases/latest",
    );

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/vnd.github+json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur GitHub : ${response.statusCode}");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> assets = data["assets"] ?? [];

    for (final asset in assets) {
      if (asset["name"] == apkFileName) {
        return asset["download_count"] ?? 0;
      }
    }

    throw Exception("APK ($apkFileName) introuvable dans la dernière Release GitHub.");
  }
}
