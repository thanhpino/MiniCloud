# Test DNS resolution for MiniCloud in PowerShell
Write-Host "=== KIỂM THỬ PHÂN GIẢI DNS BIND9 (cloud.local) ===" -ForegroundColor Cyan

$domains = @(
    "web-frontend-server.cloud.local",
    "app-backend.cloud.local",
    "minio.cloud.local",
    "keycloak.cloud.local",
    "gateway.cloud.local"
)

foreach ($domain in $domains) {
    Write-Host "`nĐang tra cứu: $domain" -ForegroundColor Yellow
    docker exec internal-dns-server dig "@127.0.0.1" $domain +short
}

Write-Host "`n=== HOÀN TẤT KIỂM THỬ DNS ===" -ForegroundColor Green
