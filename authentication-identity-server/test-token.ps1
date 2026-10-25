# Test Keycloak OIDC Token retrieval in PowerShell
param (
    [string]$HostName = "localhost",
    [string]$Port = "8081",
    [string]$Realm = "realm_524h0032_524h0125",
    [string]$ClientId = "flask-app",
    [string]$Username = "sv01",
    [string]$Password = "password123"
)

Write-Host "=== LẤY ACCESS TOKEN TỪ KEYCLOAK (PowerShell) ===" -ForegroundColor Cyan
Write-Host "Realm: $Realm | User: $Username"

$body = @{
    grant_type = "password"
    client_id  = $ClientId
    username   = $Username
    password   = $Password
}

try {
    $tokenResponse = Invoke-RestMethod -Uri "http://${HostName}:${Port}/auth/realms/${Realm}/protocol/openid-connect/token" -Method Post -Body $body
    $accessToken = $tokenResponse.access_token
    Write-Host "✅ Lấy Token thành công!" -ForegroundColor Green
    Write-Host "Token trích đoạn: $($accessToken.Substring(0, 50))..." -ForegroundColor DarkGray

    Write-Host "`n=== GỌI ROUTE /secure VỚI BEARER TOKEN ===" -ForegroundColor Cyan
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    $secureResponse = Invoke-RestMethod -Uri "http://localhost/api/secure" -Method Get -Headers $headers
    $secureResponse | ConvertTo-Json -Depth 5
} catch {
    Write-Host "❌ Lỗi: $_" -ForegroundColor Red
}
