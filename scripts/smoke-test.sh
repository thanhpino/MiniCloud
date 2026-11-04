#!/usr/bin/env bash
# =============================================================================
# MiniCloud - Smoke test toàn bộ 9 server + phần mở rộng
# Cách dùng:  bash scripts/smoke-test.sh            (chạy trên máy đang host Docker)
# =============================================================================
H=${1:-localhost}
PASS=0; FAIL=0
ok()   { echo "  [PASS] $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$1"; }
has()  { curl -sL --max-time 10 "$1" | grep -qi "$2"; }

echo "== 1. Web Frontend =="
[ "$(code http://$H:8080/)" = 200 ]       && ok "Web1 /"      || bad "Web1 /"
[ "$(code http://$H:8080/blog/)" = 200 ]  && ok "Web1 /blog/" || bad "Web1 /blog/"
[ "$(code http://$H:8082/)" = 200 ]       && ok "Web2 /"      || bad "Web2 /"
for b in blog1 blog2 blog3; do
  [ "$(code http://$H/blog/$b.html)" = 200 ] && ok "Blog $b.html" || bad "Blog $b.html"
done

echo "== 2. App Backend =="
has http://$H:8085/hello "Hello" && ok "8085/hello"        || bad "8085/hello"
has http://$H/api/hello  "Hello" && ok "Proxy /api/hello"  || bad "Proxy /api/hello"
has http://$H/api/student   "524H0032" && ok "/api/student (JSON)" || bad "/api/student"
has http://$H/student/      "524H0032" && ok "/student/ (route mo rong 9)" || bad "/student/"
has http://$H/api/students-db "524H0032" && ok "/api/students-db (MariaDB)" || bad "/api/students-db"

echo "== 3. Database =="
docker exec relational-database-server mariadb -uroot -proot_password -e "SELECT title FROM minicloud.notes LIMIT 1;" >/dev/null 2>&1 \
  && ok "minicloud.notes" || bad "minicloud.notes"
docker exec relational-database-server mariadb -uroot -proot_password -e "SELECT COUNT(*) FROM studentdb.students;" >/dev/null 2>&1 \
  && ok "studentdb.students" || bad "studentdb.students"

echo "== 4. Keycloak =="
c=$(code http://$H:8081/auth/); { [ "$c" = 200 ] || [ "$c" = 302 ]; } && ok "8081/auth/ ($c)" || bad "8081/auth/ ($c)"
c=$(code http://$H/auth/);      { [ "$c" = 200 ] || [ "$c" = 302 ]; } && ok "Proxy /auth/ ($c)" || bad "Proxy /auth/ ($c)"
TOKEN=$(curl -s --max-time 10 -X POST "http://$H:8081/auth/realms/realm_524h0032_524h0125/protocol/openid-connect/token" \
  -d grant_type=password -d client_id=flask-app -d username=sv01 -d password=password123 \
  | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
[ -n "$TOKEN" ] && ok "Lay token sv01" || bad "Lay token sv01"
[ -n "$TOKEN" ] && curl -s -H "Authorization: Bearer $TOKEN" http://$H/api/secure | grep -q authenticated \
  && ok "/api/secure voi Bearer token" || bad "/api/secure voi Bearer token"

echo "== 5. MinIO =="
[ "$(code http://$H:9000/minio/health/live)" = 200 ] && ok "MinIO API 9000" || bad "MinIO API 9000"
[ "$(code http://$H:9001/)" = 200 ] && ok "MinIO Console 9001" || bad "MinIO Console 9001"

echo "== 6. DNS (Bind9) =="
for n in web-frontend-server app-backend minio keycloak; do
  ip=$(dig @$H -p 1053 $n.cloud.local +short 2>/dev/null)
  [ -n "$ip" ] && ok "$n.cloud.local -> $ip" || bad "$n.cloud.local"
done

echo "== 7. Prometheus =="
T=$(curl -s --max-time 10 http://$H:9090/api/v1/targets)
echo "$T" | grep -q '"health":"down"' && bad "Co target DOWN" || ok "Tat ca targets UP"
echo "$T" | grep -q 'web-frontend' && ok "Job web-frontend (mo rong 7)" || bad "Job web-frontend"

echo "== 8. Grafana =="
has http://$H:3000/api/health '"database": *"ok"' && ok "Grafana health" || bad "Grafana health"

echo "== 9. Gateway + Load Balancer =="
[ "$(code http://$H/)" = 200 ] && ok "Gateway /" || bad "Gateway /"
U=$(for i in 1 2 3 4; do curl -s -I http://$H/ | grep -i x-upstream-backend; done | sort -u | wc -l)
[ "$U" -ge 2 ] && ok "Round Robin luan phien 2 web" || bad "Round Robin ($U upstream)"

echo "== 10. Ping noi bo cloud-net =="
for t in web-frontend-server web-frontend-server2 application-backend-server relational-database-server \
         authentication-identity-server object-storage-server monitoring-prometheus-server \
         monitoring-grafana-dashboard-server internal-dns-server; do
  docker exec api-gateway-proxy-server ping -c 1 -W 2 $t >/dev/null 2>&1 && ok "ping $t" || bad "ping $t"
done

echo ""
echo "TONG KET: $PASS PASS / $FAIL FAIL"

