import http.server
import socketserver
import json
import os
from urllib.parse import urlparse, parse_qs
from datetime import datetime

PORT = 8000
DB_FILE = "downloads.txt"
USERS_FILE = "users.json"
ACTIVITIES_FILE = "activities.json"

def get_download_count():
    if not os.path.exists(DB_FILE):
        return 0
    try:
        with open(DB_FILE, "r") as f:
            content = f.read().strip()
            return int(content) if content else 0
    except Exception:
        return 0

def increment_download_count():
    count = get_download_count() + 1
    try:
        with open(DB_FILE, "w") as f:
            f.write(str(count))
    except Exception as e:
        print(f"Error saving download count: {e}")
    return count

def get_active_users():
    if not os.path.exists(USERS_FILE):
        return []
    try:
        with open(USERS_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return []

def save_active_user(data):
    users = get_active_users()
    
    phone = data.get('phone', '').strip()
    email = data.get('email', '').strip()
    name = data.get('company_name', '').strip()
    
    if not phone and not email and not name:
        name = "Utilisateur Anonyme"
        
    unique_key = phone if phone else (email if email else name)
    now_str = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    
    found = False
    for user in users:
        u_key = user.get('phone', '').strip() if user.get('phone') else (user.get('email', '').strip() if user.get('email') else user.get('company_name', '').strip())
        if u_key == unique_key:
            user['company_name'] = name if name else user.get('company_name')
            user['phone'] = phone if phone else user.get('phone')
            user['email'] = email if email else user.get('email')
            user['device'] = data.get('device', 'Inconnu')
            user['projects_count'] = data.get('projects_count', user.get('projects_count', 0))
            user['last_seen'] = now_str
            found = True
            break
            
    if not found:
        new_user = {
            'company_name': name if name else "Utilisateur Anonyme",
            'phone': phone,
            'email': email,
            'device': data.get('device', 'Inconnu'),
            'projects_count': data.get('projects_count', 0),
            'first_seen': now_str,
            'last_seen': now_str
        }
        users.append(new_user)
        
    try:
        with open(USERS_FILE, "w") as f:
            json.dump(users, f, indent=4)
    except Exception as e:
        print(f"Error saving active users: {e}")
        
    return users

def get_activities():
    if not os.path.exists(ACTIVITIES_FILE):
        return []
    try:
        with open(ACTIVITIES_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return []

def save_activity(data):
    activities = get_activities()
    
    now_str = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    entry = {
        'company_name': data.get('company_name', '').strip() or 'Utilisateur Anonyme',
        'phone': data.get('phone', '').strip(),
        'email': data.get('email', '').strip(),
        'device': data.get('device', 'Inconnu'),
        'action': data.get('action', '').strip() or 'Activite inconnue',
        'details': data.get('details', '').strip() or '',
        'timestamp': now_str
    }
    
    # Insert at the beginning of the feed
    activities.insert(0, entry)
    
    # Cap at 500 entries to prevent memory overflow
    activities = activities[:500]
    
    try:
        with open(ACTIVITIES_FILE, "w") as f:
            json.dump(activities, f, indent=4)
    except Exception as e:
        print(f"Error saving activity: {e}")
        
    return activities

class APKTrackerHandler(http.server.BaseHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS, POST')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        parsed_url = urlparse(self.path)
        path = parsed_url.path

        if path in ['/ping', '/log_activity']:
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                if path == '/ping':
                    save_active_user(data)
                else:
                    save_activity(data)
                    # Also update user stats in active users on any activity
                    save_active_user(data)
                
                response_data = {"status": "success"}
                response_bytes = json.dumps(response_data).encode('utf-8')
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(response_bytes)))
                self.end_headers()
                self.wfile.write(response_bytes)
            except Exception as e:
                response_data = {"status": "error", "message": str(e)}
                response_bytes = json.dumps(response_data).encode('utf-8')
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(response_bytes)))
                self.end_headers()
                self.wfile.write(response_bytes)
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"404 Not Found")

    def do_GET(self):
        parsed_url = urlparse(self.path)
        path = parsed_url.path
        query_params = parse_qs(parsed_url.query)
        password = query_params.get('password', [None])[0]

        if path == '/download':
            count = increment_download_count()
            print(f"[APKTracker] Download triggered. New count: {count}")

            # Check query parameter for architecture preference
            arch = query_params.get('arch', [None])[0]
            if not arch:
                # Try to auto-detect architecture from User-Agent
                ua = self.headers.get('User-Agent', '').lower()
                if 'arm64' in ua or 'aarch64' in ua:
                    arch = '64'
                elif 'armeabi' in ua or 'armv7' in ua:
                    arch = '32'
                else:
                    # Default to 64-bit for modern devices
                    arch = '64'

            if arch == '32':
                apk_filename = "app-armeabi-v7a-release.apk"
                download_name = "metre_btp_pro_32bit.apk"
            else:
                apk_filename = "app-arm64-v8a-release.apk"
                download_name = "metre_btp_pro_64bit.apk"

            apk_path = os.path.join("build", "app", "outputs", "flutter-apk", apk_filename)
            if not os.path.exists(apk_path):
                # Check local workspace root
                if os.path.exists(apk_filename):
                    apk_path = apk_filename
                elif os.path.exists(download_name):
                    apk_path = download_name
                # Check build/app/outputs/flutter-apk/app-release.apk
                else:
                    apk_path = os.path.join("build", "app", "outputs", "flutter-apk", "app-release.apk")
                    if not os.path.exists(apk_path):
                        apk_path = "app-release.apk"

            if not os.path.exists(apk_path):
                dummy_content = f"Mete BTP Pro APK File Content Simulation for {arch}-bit. This is a dummy file for local testing.".encode('utf-8')
                self.send_response(200)
                self.send_header('Content-Type', 'application/vnd.android.package-archive')
                self.send_header('Content-Disposition', f'attachment; filename="{download_name}"')
                self.send_header('Content-Length', str(len(dummy_content)))
                self.end_headers()
                self.wfile.write(dummy_content)
            else:
                try:
                    file_size = os.path.getsize(apk_path)
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/vnd.android.package-archive')
                    self.send_header('Content-Disposition', f'attachment; filename="{download_name}"')
                    self.send_header('Content-Length', str(file_size))
                    self.end_headers()
                    with open(apk_path, 'rb') as f:
                        while True:
                            chunk = f.read(1024 * 64)
                            if not chunk:
                                break
                            self.wfile.write(chunk)
                except Exception as e:
                    self.send_error(500, f"Error serving file: {e}")

        elif path == '/stats':
            if password != 'mx23fy':
                response_data = {"error": "Non autorise"}
                response_bytes = json.dumps(response_data).encode('utf-8')
                self.send_response(401)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(response_bytes)))
                self.end_headers()
                self.wfile.write(response_bytes)
                return

            count = get_download_count()
            response_data = {"downloads": count}
            response_bytes = json.dumps(response_data).encode('utf-8')
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(response_bytes)))
            self.end_headers()
            self.wfile.write(response_bytes)

        elif path == '/users':
            if password != 'mx23fy':
                response_data = {"error": "Non autorise"}
                response_bytes = json.dumps(response_data).encode('utf-8')
                self.send_response(401)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(response_bytes)))
                self.end_headers()
                self.wfile.write(response_bytes)
                return

            users = get_active_users()
            response_bytes = json.dumps(users).encode('utf-8')
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(response_bytes)))
            self.end_headers()
            self.wfile.write(response_bytes)

        elif path == '/activities':
            if password != 'mx23fy':
                response_data = {"error": "Non autorise"}
                response_bytes = json.dumps(response_data).encode('utf-8')
                self.send_response(401)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Content-Length', str(len(response_bytes)))
                self.end_headers()
                self.wfile.write(response_bytes)
                return

            activities = get_activities()
            response_bytes = json.dumps(activities).encode('utf-8')
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(response_bytes)))
            self.end_headers()
            self.wfile.write(response_bytes)

        elif path == '/admin':
            if password != 'mx23fy':
                error_msg = ""
                if password is not None:
                    error_msg = '<div class="error">Mot de passe incorrect. Reessayez.</div>'

                login_html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Métré BTP Pro - Connexion</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {{
            --primary: #0F2A44;
            --secondary: #1E8E5A;
            --bg: #F7F8FA;
            --card-bg: #ffffff;
            --text-main: #1A2530;
            --text-muted: #64748B;
            --border: #E2E8F0;
        }}
        @media (prefers-color-scheme: dark) {{
            :root {{
                --primary: #1E3A5F;
                --secondary: #22C55E;
                --bg: #0B0F19;
                --card-bg: #111827;
                --text-main: #F9FAFB;
                --text-muted: #9CA3AF;
                --border: #1F2937;
            }}
        }}
        * {{ margin: 0; padding: 0; box-sizing: border-box; font-family: 'Outfit', sans-serif; }}
        body {{
            background-color: var(--bg);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }}
        .login-card {{
            background-color: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 2.5rem 2rem;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            text-align: center;
        }}
        .logo-icon {{
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1.75rem;
            margin: 0 auto 1.5rem auto;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }}
        h2 {{ font-size: 1.5rem; font-weight: 800; margin-bottom: 0.5rem; }}
        p {{ font-size: 0.875rem; color: var(--text-muted); margin-bottom: 2rem; }}
        input[type="password"] {{
            width: 100%;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            border: 1px solid var(--border);
            background-color: var(--bg);
            color: var(--text-main);
            font-size: 1rem;
            margin-bottom: 1.5rem;
            outline: none;
            text-align: center;
        }}
        input[type="password"]:focus {{ border-color: var(--primary); }}
        button {{
            width: 100%;
            padding: 0.75rem;
            border-radius: 8px;
            background-color: var(--secondary);
            color: white;
            border: none;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
        }}
        button:hover {{ opacity: 0.9; }}
        .error {{ color: #EF4444; font-size: 0.875rem; margin-top: 1rem; font-weight: 600; }}
    </style>
</head>
<body>
    <div class="login-card">
        <div class="logo-icon">M</div>
        <h2>Accès Restreint</h2>
        <p>Veuillez entrer le mot de passe administrateur pour accéder à la console.</p>
        <form method="GET" action="/admin">
            <input type="password" name="password" placeholder="Mot de passe" required autofocus>
            <button type="submit">Se connecter</button>
        </form>
        {error_msg}
    </div>
</body>
</html>"""
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.send_header('Content-Length', str(len(login_html.encode('utf-8'))))
                self.end_headers()
                self.wfile.write(login_html.encode('utf-8'))
                return

            count = get_download_count()
            html_content = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Métré BTP Pro - Console Administration</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {{
            --primary: #0F2A44;
            --secondary: #1E8E5A;
            --bg: #F7F8FA;
            --card-bg: #ffffff;
            --text-main: #1A2530;
            --text-muted: #64748B;
            --white: #ffffff;
            --border: #E2E8F0;
        }}

        @media (prefers-color-scheme: dark) {{
            :root {{
                --primary: #1E3A5F;
                --secondary: #22C55E;
                --bg: #0B0F19;
                --card-bg: #111827;
                --text-main: #F9FAFB;
                --text-muted: #9CA3AF;
                --white: #ffffff;
                --border: #1F2937;
            }}
        }}

        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
        }}

        body {{
            background-color: var(--bg);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem 1rem;
            transition: background-color 0.3s ease, color 0.3s ease;
        }}

        .container {{
            width: 100%;
            max-width: 800px;
            display: flex;
            flex-direction: column;
            gap: 2rem;
        }}

        header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            padding-bottom: 1.5rem;
        }}

        .logo-section {{
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }}

        .logo-icon {{
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1.5rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }}

        h1 {{
            font-size: 1.75rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }}

        .subtitle {{
            font-size: 0.875rem;
            color: var(--text-muted);
        }}

        .badge {{
            background-color: var(--secondary);
            color: white;
            padding: 0.35rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
        }}

        /* Grid stats */
        .stats-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 1.5rem;
        }}

        .card {{
            background-color: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }}

        .card:hover {{
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }}

        .card-title {{
            font-size: 0.875rem;
            text-transform: uppercase;
            font-weight: 600;
            color: var(--text-muted);
            letter-spacing: 0.05em;
            margin-bottom: 0.5rem;
        }}

        .card-value {{
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--secondary);
            line-height: 1.1;
        }}

        .card-desc {{
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-top: 0.5rem;
        }}

        /* Action Panel */
        .actions-card {{
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }}

        .btn-group {{
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }}

        .btn {{
            flex: 1;
            min-width: 150px;
            padding: 0.875rem 1.5rem;
            border-radius: 10px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: center;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }}

        .btn-primary {{
            background-color: var(--primary);
            color: white;
        }}

        .btn-primary:hover {{
            opacity: 0.9;
        }}

        .btn-success {{
            background-color: var(--secondary);
            color: white;
        }}

        .btn-success:hover {{
            opacity: 0.9;
        }}

        .btn-outline {{
            background-color: transparent;
            border: 2px solid var(--border);
            color: var(--text-main);
        }}

        .btn-outline:hover {{
            background-color: var(--border);
        }}

        /* Table */
        .table-responsive {{
            overflow-x: auto;
            margin-top: 1rem;
        }}

        table {{
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.875rem;
        }}

        th {{
            background-color: var(--primary);
            color: white;
            padding: 0.75rem 1rem;
            font-weight: 600;
        }}

        th:first-child {{ border-top-left-radius: 8px; }}
        th:last-child {{ border-top-right-radius: 8px; }}

        td {{
            padding: 0.875rem 1rem;
            border-bottom: 1px solid var(--border);
            color: var(--text-main);
        }}

        tr:last-child td {{ border-bottom: none; }}

        .no-data {{
            text-align: center;
            color: var(--text-muted);
            padding: 2rem;
            font-style: italic;
        }}

        .badge-action {{
            background-color: var(--primary);
            color: white;
            padding: 0.15rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }}

        .dev-info {{
            text-align: center;
            font-size: 0.875rem;
            color: var(--text-muted);
            border-top: 1px solid var(--border);
            padding-top: 1.5rem;
            margin-top: 1rem;
        }}

        .dev-info a {{
            color: var(--secondary);
            text-decoration: none;
            font-weight: 600;
        }}

        .dev-info a:hover {{ text-decoration: underline; }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo-section">
                <div class="logo-icon">M</div>
                <div>
                    <h1>Métré BTP Pro</h1>
                    <div class="subtitle">Console d'administration & Suivi de Téléchargements</div>
                </div>
            </div>
            <div style="display: flex; gap: 0.5rem; align-items: center;">
                <span class="badge">Serveur Actif</span>
                <a href="/admin" style="font-size: 0.875rem; color: var(--text-muted); text-decoration: none; border: 1px solid var(--border); padding: 0.35rem 0.75rem; border-radius: 9999px; background: var(--card-bg)">Se déconnecter</a>
            </div>
        </header>

        <div class="stats-grid">
            <div class="card">
                <div class="card-title">Téléchargements APK</div>
                <div class="card-value" id="download-count">{count}</div>
                <div class="card-desc">Nombre total de fois que le fichier APK a été téléchargé via le endpoint /download.</div>
            </div>

            <div class="card actions-card">
                <div class="card-title">Actions Rapides</div>
                <div class="btn-group" style="display: flex; flex-direction: column; gap: 0.5rem; width: 100%;">
                    <div style="display: flex; gap: 0.5rem; width: 100%;">
                        <a href="/download?arch=64" class="btn btn-success" target="_blank" style="flex: 1; padding: 0.5rem 1rem; font-size: 0.9rem;">
                            📥 64-bit (Léger ~18Mo)
                        </a>
                        <a href="/download?arch=32" class="btn btn-primary" target="_blank" style="flex: 1; padding: 0.5rem 1rem; font-size: 0.9rem; background-color: var(--primary);">
                            📥 32-bit (Léger ~16Mo)
                        </a>
                    </div>
                    <div style="display: flex; gap: 0.5rem; width: 100%;">
                        <a href="/download" class="btn btn-outline" target="_blank" style="flex: 1; padding: 0.5rem 1rem; font-size: 0.9rem;">
                            ⚙️ Détection Auto (UA)
                        </a>
                        <button onclick="refreshData()" class="btn btn-outline" style="flex: 1; padding: 0.5rem 1rem; font-size: 0.9rem;">
                            🔄 Rafraîchir
                        </button>
                    </div>
                </div>
                <div style="font-size: 0.825rem; color: var(--text-muted); margin-top: 0.5rem;">
                    Url de téléchargement publique : <br>
                    <code>http://localhost:8000/download</code> (Détection auto ou 64-bit par défaut)<br>
                    32-bit spécifique : <code>/download?arch=32</code><br>
                    64-bit spécifique : <code>/download?arch=64</code>
                </div>
            </div>
        </div>

        <!-- ACTIVE USERS SECTION -->
        <div class="card">
            <h3 style="font-weight: 600; margin-bottom: 0.5rem;">Utilisateurs Actifs de l'APK</h3>
            <p style="font-size: 0.875rem; color: var(--text-muted); margin-bottom: 1rem;">
                Profils d'entreprises connectés et actifs.
            </p>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Nom / Entreprise</th>
                            <th>Téléphone</th>
                            <th>Email</th>
                            <th>Appareil</th>
                            <th>Projets</th>
                            <th>Dernière activité</th>
                        </tr>
                    </thead>
                    <tbody id="users-table-body">
                        <tr>
                            <td colspan="6" class="no-data">Chargement...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- GLOBAL ACTIVITY FEED SECTION -->
        <div class="card">
            <h3 style="font-weight: 600; margin-bottom: 0.5rem;">Journal d'Activité en Direct</h3>
            <p style="font-size: 0.875rem; color: var(--text-muted); margin-bottom: 1rem;">
                Historique chronologique des actions effectuées par les utilisateurs de l'APK (calculs, création de projets, exports PDF...).
            </p>
            <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                <table>
                    <thead>
                        <tr>
                            <th>Heure</th>
                            <th>Utilisateur</th>
                            <th>Action</th>
                            <th>Détails</th>
                            <th>Appareil</th>
                        </tr>
                    </thead>
                    <tbody id="activities-table-body">
                        <tr>
                            <td colspan="5" class="no-data">Chargement des activités...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <h3 style="margin-bottom: 1rem; font-weight: 600;">Fiche Développeur</h3>
            <p style="margin-bottom: 0.5rem; font-size: 0.95rem;">
                <strong>Développeur :</strong> Issoufou Abdou <br>
                <strong>Titre :</strong> Ingénieur Génie Civil <br>
                <strong>Téléphone :</strong> +227 96 38 08 77
            </p>
            <p style="font-size: 0.875rem; color: var(--text-muted);">
                Pour tout besoin d'application de génie civil sur mesure, d'optimisation de métrés ou de développement logiciel de structure, veuillez contacter l'ingénieur par téléphone ou WhatsApp.
            </p>
        </div>

        <footer class="dev-info">
            Métré BTP Pro &copy; 2026. Conçu pour le génie civil.
        </footer>
    </div>

    <script>
        function refreshData() {{
            // Stats
            fetch('/stats?password=mx23fy')
                .then(res => res.json())
                .then(data => {{
                    document.getElementById('download-count').innerText = data.downloads;
                }})
                .catch(err => console.error("Erreur stats:", err));

            // Users
            fetch('/users?password=mx23fy')
                .then(res => res.json())
                .then(users => {{
                    const tbody = document.getElementById('users-table-body');
                    tbody.innerHTML = '';

                    if (users.length === 0) {{
                        tbody.innerHTML = '<tr><td colspan="6" class="no-data">Aucun utilisateur actif.</td></tr>';
                        return;
                    }}

                    users.forEach(u => {{
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td><strong>${{u.company_name || 'Anonyme'}}</strong></td>
                            <td>${{u.phone || '-'}}</td>
                            <td>${{u.email || '-'}}</td>
                            <td>${{u.device || 'Inconnu'}}</td>
                            <td><span style="font-weight: bold; color: var(--secondary);">${{u.projects_count || 0}}</span></td>
                            <td>${{u.last_seen || '-'}}</td>
                        `;
                        tbody.appendChild(row);
                    }});
                }})
                .catch(err => {{
                    console.error("Erreur users:", err);
                    document.getElementById('users-table-body').innerHTML = '<tr><td colspan="6" class="no-data">Erreur.</td></tr>';
                }});

            // Activities
            fetch('/activities?password=mx23fy')
                .then(res => res.json())
                .then(activities => {{
                    const tbody = document.getElementById('activities-table-body');
                    tbody.innerHTML = '';

                    if (activities.length === 0) {{
                        tbody.innerHTML = '<tr><td colspan="5" class="no-data">Aucune activité enregistrée.</td></tr>';
                        return;
                    }}

                    activities.forEach(a => {{
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td style="white-space: nowrap; color: var(--text-muted);">${{a.timestamp || '-'}}</td>
                            <td><strong>${{a.company_name || 'Anonyme'}}</strong></td>
                            <td><span class="badge-action">${{a.action || '-'}}</span></td>
                            <td>${{a.details || '-'}}</td>
                            <td style="color: var(--text-muted);">${{a.device || 'Inconnu'}}</td>
                        `;
                        tbody.appendChild(row);
                    }});
                }})
                .catch(err => {{
                    console.error("Erreur activities:", err);
                    document.getElementById('activities-table-body').innerHTML = '<tr><td colspan="5" class="no-data">Erreur.</td></tr>';
                }});
        }}

        // Initial load
        refreshData();
        // Auto-refresh every 5 seconds
        setInterval(refreshData, 5000);
    </script>
</body>
</html>
"""
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(html_content.encode('utf-8'))))
            self.end_headers()
            self.wfile.write(html_content.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"404 Not Found")

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    pass

if __name__ == '__main__':
    server_address = ('', PORT)
    httpd = ThreadingHTTPServer(server_address, APKTrackerHandler)
    print(f"===========================================================")
    print(f"[Metre BTP Pro Tracker] Serveur demarre sur le port {PORT}")
    print(f"Console Admin : http://localhost:{PORT}/admin")
    print(f"Lien de telechargement : http://localhost:{PORT}/download")
    print(f"API Stats : http://localhost:{PORT}/stats")
    print(f"===========================================================")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nArret du serveur...")
        httpd.server_close()
