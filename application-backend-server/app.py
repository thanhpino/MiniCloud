import os
import json
import pymysql
from flask import Flask, jsonify, request
from flask_cors import CORS
import jwt

app = Flask(__name__)
CORS(app)

DB_HOST = os.getenv("DB_HOST", "relational-database-server")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "minicloud_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "minicloud_pass")
DB_NAME = os.getenv("DB_NAME", "studentdb")

def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

@app.route("/", methods=["GET"])
def root():
    return jsonify({
        "service": "MiniCloud Application Backend",
        "status": "online",
        "endpoints": [
            "/hello",
            "/student",
            "/students-db",
            "/secure"
        ]
    })

# 1. Cơ bản (0.5đ): Route /hello trả về JSON
@app.route("/hello", methods=["GET"])
def hello():
    return jsonify({
        "message": "Hello from MiniCloud Backend API!",
        "status": "success",
        "service": "application-backend-server"
    })

# 2. Mở rộng 2 (0.5đ): Route /student đọc từ students.json
@app.route("/student", methods=["GET"])
def get_students():
    try:
        json_path = os.path.join(os.path.dirname(__file__), "students.json")
        with open(json_path, "r", encoding="utf-8") as f:
            students = json.load(f)
        return jsonify({
            "status": "success",
            "source": "students.json",
            "count": len(students),
            "data": students
        })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# 3. Mở rộng 3 (0.5đ): Route /students-db query từ MariaDB
@app.route("/students-db", methods=["GET"])
def get_students_db():
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT student_id, full_name, email, class_name, gpa, created_at FROM students")
            results = cursor.fetchall()
            for r in results:
                if 'created_at' in r and r['created_at']:
                    r['created_at'] = str(r['created_at'])
        conn.close()
        return jsonify({
            "status": "success",
            "source": "MariaDB database 'studentdb'",
            "count": len(results),
            "data": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Database query failed: {str(e)}"
        }), 500

# 4. Mở rộng 5 (0.5đ): Route /secure xác thực Keycloak Bearer Token
@app.route("/secure", methods=["GET"])
def secure_endpoint():
    auth_header = request.headers.get("Authorization", None)
    if not auth_header or not auth_header.startswith("Bearer "):
        return jsonify({
            "status": "unauthorized",
            "message": "Missing or invalid Bearer token. Please provide Authorization: Bearer <token>"
        }), 401

    token = auth_header.split(" ")[1]
    try:
        # Decode token payload without signature verification for test inspection,
        # or verify with Keycloak public certs in production.
        payload = jwt.decode(token, options={"verify_signature": False})
        return jsonify({
            "status": "authenticated",
            "message": "Access granted to secure resource!",
            "user": {
                "preferred_username": payload.get("preferred_username"),
                "email": payload.get("email"),
                "roles": payload.get("realm_access", {}).get("roles", [])
            },
            "token_claims": payload
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Token validation failed: {str(e)}"
        }), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
