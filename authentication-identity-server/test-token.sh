#!/bin/bash
# Test Keycloak OIDC Token retrieval for sv01 and sv02
KEYCLOAK_HOST=${1:-"localhost"}
KEYCLOAK_PORT=${2:-"8081"}
REALM="realm_524h0032_524h0125"
CLIENT_ID="flask-app"
USERNAME=${3:-"sv01"}
PASSWORD=${4:-"password123"}

echo "=== LẤY ACCESS TOKEN TỪ KEYCLOAK ==="
echo "Realm: $REALM | User: $USERNAME"

TOKEN_RESPONSE=$(curl -s -X POST "http://${KEYCLOAK_HOST}:${KEYCLOAK_PORT}/auth/realms/${REALM}/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=${CLIENT_ID}" \
  -d "username=${USERNAME}" \
  -d "password=${PASSWORD}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Lấy Token thất bại!"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

echo "✅ Lấy Token thành công!"
echo "Access Token (trích đoạn): ${ACCESS_TOKEN:0:50}..."

echo -e "\n=== TEST GỌI ROUTE /secure VỚI BEARER TOKEN ==="
curl -i -s -H "Authorization: Bearer $ACCESS_TOKEN" "http://localhost/api/secure"
