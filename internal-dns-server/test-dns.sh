#!/bin/bash
# Script kiểm thử phân giải DNS Bind9 (Cơ bản + Mở rộng 6)
DNS_IP=${1:-"127.0.0.1"}
DNS_PORT=${2:-"1053"}

echo "=== KIỂM THỬ INTERNAL DNS SERVER (Port $DNS_PORT) ==="

echo -e "\n1. Phân giải web-frontend-server.cloud.local (Cơ bản):"
dig @$DNS_IP -p $DNS_PORT web-frontend-server.cloud.local +short

echo -e "\n2. Phân giải app-backend.cloud.local (Mở rộng 6):"
dig @$DNS_IP -p $DNS_PORT app-backend.cloud.local +short

echo -e "\n3. Phân giải minio.cloud.local (Mở rộng 6):"
dig @$DNS_IP -p $DNS_PORT minio.cloud.local +short

echo -e "\n4. Phân giải keycloak.cloud.local (Mở rộng 6):"
dig @$DNS_IP -p $DNS_PORT keycloak.cloud.local +short

echo -e "\n5. Phân giải gateway.cloud.local:"
dig @$DNS_IP -p $DNS_PORT gateway.cloud.local +short

echo -e "\n=== HOÀN TẤT KIỂM THỬ ==="
