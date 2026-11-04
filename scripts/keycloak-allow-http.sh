#!/usr/bin/env bash
# =============================================================================
# Keycloak: tắt yêu cầu HTTPS cho realm master
# Lý do: truy cập Keycloak qua Public IP (không phải localhost) bằng HTTP sẽ bị
# lỗi "HTTPS required". Chạy script này 1 lần sau khi Keycloak đã khởi động xong.
# Cách dùng:  bash scripts/keycloak-allow-http.sh
# =============================================================================
set -euo pipefail
KC=authentication-identity-server
KCADM=/opt/keycloak/bin/kcadm.sh

echo "Doi Keycloak san sang..."
for i in $(seq 1 40); do
  if docker exec "$KC" $KCADM config credentials --server http://localhost:8080/auth \
       --realm master --user admin --password admin >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

docker exec "$KC" $KCADM update realms/master -s sslRequired=NONE
docker exec "$KC" $KCADM update realms/realm_524h0032_524h0125 -s sslRequired=NONE || true
echo "Da tat sslRequired cho realm master va realm_524h0032_524h0125."

