# 1. WLAN-Adapter identifizieren
$adapterAlias = "WLAN"

# 2. Feste DNS-Server (IPv4) setzen
Write-Host "Setze DNS-Server auf $adapterAlias..." -ForegroundColor Cyan
Set-DnsClientServerAddress -InterfaceAlias $adapterAlias -ServerAddresses ("146.255.56.98", "9.9.9.9")

# 3. DNS-over-HTTPS (DoH) Vorlagen registrieren bzw. konfigurieren
Write-Host "Konfiguriere Verschlüsselung (DoH)..." -ForegroundColor Cyan

# Applied Privacy (Primär) - Vorlage hinzufügen, falls nicht vorhanden
if (-not (Get-DnsClientDoHServerAddress -ServerAddress "146.255.56.98" -ErrorAction SilentlyContinue)) {
    Add-DnsClientDohServerAddress -ServerAddress "146.255.56.98" `
                                  -DohTemplate "https://doh.applied-privacy.net/query" `
                                  -AllowFallbackToUdp $false `
                                  -AutoUpgrade $true
} else {
    Set-DnsClientDohServerAddress -ServerAddress "146.255.56.98" -AutoUpgrade $true -AllowFallbackToUdp $false
}

# Quad9 (Sekundär) - Konfiguration aktualisieren
Set-DnsClientDohServerAddress -ServerAddress "9.9.9.9" -AutoUpgrade $true -AllowFallbackToUdp $false

# 4. Status zur Kontrolle ausgeben
Write-Host "`nAktuelle DNS-Konfiguration für $adapterAlias:" -ForegroundColor Green
Get-DnsClientServerAddress -InterfaceAlias $adapterAlias | Select-Object InterfaceAlias, ServerAddresses
Write-Host "`nVerschlüsselungs-Status (AutoUpgrade sollte True sein):" -ForegroundColor Green
Get-DnsClientDoHServerAddress | Where-Object { $_.ServerAddress -in "146.255.56.98", "9.9.9.9" }
