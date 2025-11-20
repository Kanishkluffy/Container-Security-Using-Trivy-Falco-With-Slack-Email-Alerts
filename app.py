from flask import Flask, request, jsonify, render_template_string
import os
import sqlite3
import subprocess

app = Flask(__name__)

# HTML template for the web interface
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>DevSecOps Demo App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .endpoint {
            background: #e8f4f8;
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #2196F3;
        }
        .warning {
            background: #fff3cd;
            padding: 10px;
            border-left: 4px solid #ffc107;
            margin: 20px 0;
        }
        input, button {
            padding: 10px;
            margin: 5px 0;
            width: 100%;
        }
        button {
            background: #2196F3;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 5px;
        }
        button:hover { background: #0b7dda; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 DevSecOps Container Security Demo</h1>
        <p>A vulnerable Flask application for Trivy + Falco demonstration</p>
        
        <div class="warning">
            ⚠️ <strong>Warning:</strong> This application contains intentional vulnerabilities for educational purposes only!
        </div>

        <h2>Available Endpoints:</h2>
        
        <div class="endpoint">
            <strong>GET /</strong> - Home page (this page)
        </div>
        
        <div class="endpoint">
            <strong>GET /health</strong> - Health check endpoint
        </div>
        
        <div class="endpoint">
            <strong>POST /user</strong> - Create user (vulnerable to SQL injection)
            <br>Body: {"username": "test", "email": "test@example.com"}
        </div>
        
        <div class="endpoint">
            <strong>GET /user/&lt;username&gt;</strong> - Get user (SQL injection vulnerable)
        </div>
        
        <div class="endpoint">
            <strong>POST /execute</strong> - Execute system command (dangerous!)
            <br>Body: {"command": "ls -la"}
        </div>

        <h2>Test SQL Injection:</h2>
        <form id="userForm">
            <input type="text" id="username" placeholder="Enter username" required>
            <button type="submit">Search User</button>
        </form>
        <div id="result"></div>
    </div>

    <script>
        document.getElementById('userForm').onsubmit = async (e) => {
            e.preventDefault();
            const username = document.getElementById('username').value;
            const response = await fetch('/user/' + username);
            const data = await response.json();
            document.getElementById('result').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        };
    </script>
</body>
</html>
"""

# Initialize SQLite database
def init_db():
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY, username TEXT, email TEXT)''')
    # Insert sample data
    c.execute("INSERT OR IGNORE INTO users VALUES (1, 'admin', 'admin@example.com')")
    c.execute("INSERT OR IGNORE INTO users VALUES (2, 'john', 'john@example.com')")
    conn.commit()
    conn.close()

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "app": "DevSecOps Demo",
        "version": "1.0.0"
    }), 200

@app.route('/user', methods=['POST'])
def create_user():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    
    # Vulnerable: SQL Injection possible
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    query = f"INSERT INTO users (username, email) VALUES ('{username}', '{email}')"
    c.execute(query)
    conn.commit()
    conn.close()
    
    return jsonify({"message": "User created", "username": username}), 201

@app.route('/user/<username>', methods=['GET'])
def get_user(username):
    # Vulnerable: SQL Injection
    conn = sqlite3.connect('users.db')
    c = conn.cursor()
    query = f"SELECT * FROM users WHERE username = '{username}'"
    c.execute(query)
    user = c.fetchall()
    conn.close()
    
    return jsonify({"user": user}), 200

@app.route('/execute', methods=['POST'])
def execute_command():
    # Vulnerable: Command Injection - This will trigger Falco alerts!
    data = request.get_json()
    command = data.get('command', 'whoami')
    
    try:
        # This is intentionally vulnerable
        result = subprocess.check_output(command, shell=True, text=True)
        return jsonify({"output": result}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/file', methods=['POST'])
def read_file():
    # Vulnerable: Path Traversal
    data = request.get_json()
    filename = data.get('filename', '/etc/passwd')
    
    try:
        with open(filename, 'r') as f:
            content = f.read()
        return jsonify({"content": content}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)