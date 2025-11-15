# ==============================
# ESP32 SIMULADOR (PowerShell)
# ==============================

# === CONFIGURAÇÃO ===
$API_URL = "http://192.168.1.21:3000/api/readings"   # Endereço do servidor Next.js
$SENSOR_ID = "1"                                     # ID do sensor cadastrado no banco
$INTERVALO = 3                                       # segundos entre envios

# === VARIÁVEIS INICIAIS ===
$temperaturaAtual = 26.0
$umidadeAtual = 60.0

# === Função para gerar variação suave ===
function Atualizar-Valores {
    param([ref]$temp, [ref]$hum)

    # Varia a temperatura gradualmente (-0.3 a +0.3)
    $deltaTemp = Get-Random -Minimum -0.3 -Maximum 0.3
    $temp.Value = [Math]::Round($temp.Value + $deltaTemp, 1)

    # Mantém temperatura em faixa razoável
    if ($temp.Value -lt 23) { $temp.Value = 23 }
    if ($temp.Value -gt 30) { $temp.Value = 30 }

    # Umidade inversamente proporcional à temperatura + ruído leve
    $deltaHum = (Get-Random -Minimum -1.0 -Maximum 1.0)
    $hum.Value = [Math]::Round(65 - ($temp.Value - 25) * 1.2 + $deltaHum, 1)

    if ($hum.Value -lt 45) { $hum.Value = 45 }
    if ($hum.Value -gt 75) { $hum.Value = 75 }
}

Write-Host "=== Simulador ESP32 iniciado ==="
Write-Host "Enviando dados a cada $INTERVALO segundos para $API_URL`n"

while ($true) {
    # Atualiza valores gradualmente
    Atualizar-Valores -temp ([ref]$temperaturaAtual) -hum ([ref]$umidadeAtual)

    # Monta JSON
    $payload = @{
        sensor_id = $SENSOR_ID
        temperature = $temperaturaAtual
        humidity = $umidadeAtual
    } | ConvertTo-Json

    try {
        # Envia POST
        $response = Invoke-RestMethod -Uri $API_URL -Method POST -Body $payload -ContentType "application/json" -TimeoutSec 5
        $hora = Get-Date -Format "HH:mm:ss"
        Write-Host "[OK] $hora → Temp=$temperaturaAtual°C  Umid=$umidadeAtual%  |  Envio bem-sucedido"
    }
    catch {
        $hora = Get-Date -Format "HH:mm:ss"
        Write-Host "[ERRO] $hora → Falha ao enviar ($($_.Exception.Message))"
    }

    Start-Sleep -Seconds $INTERVALO
}
