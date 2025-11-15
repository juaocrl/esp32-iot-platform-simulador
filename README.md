# 📘 ESP32 IoT Platform — Simulador (PowerShell)

Simulador oficial para enviar leituras falsas de **temperatura** e **umidade** para o backend da **IoT Platform**, sem a necessidade de um ESP32 físico.

Ideal para testes de:

- Dashboard  
- API `/api/readings`    
- Banco de dados (Prisma + PostgreSQL)  
- Múltiplos dispositivos simultâneos  
- Cálculo automático de média entre sensores  

---

## 📑 Índice

- Objetivo  
- Requisitos  
- Instalação  
- Configuração  
- Funcionamento do Simulador  
- Execução  
- Exemplo de Saída  
- Uso com Múltiplos Sensores  
- Código Completo  

---

## 🎯 Objetivo

Este simulador reproduz o comportamento de um ESP32 real, enviando leituras periódicas para a API REST do backend.

Ele simula:

✔ Atualização suave da temperatura  
✔ Variação dinâmica da umidade  
✔ Envios a cada **3 segundos**  
✔ Identificação do sensor por `device_uid`  
✔ Integração idêntica à do ESP32 real  

---

## 🧩 Requisitos

- Windows 10/11  
- PowerShell 5+ ou PowerShell Core  
- API `/api/readings` funcional  
- Um `device_uid` cadastrado no banco de dados  

> ⚠ **IMPORTANTE:**  
> O `device_uid` PRECISA existir no banco (tabela `device`).  
> Se não existir, o backend **não armazena nada**.

---

## 📥 Instalação

Clone o repositório:

```
git clone https://github.com/juaocrl/esp32-iot-platform-simulador.git
```

Ou baixe somente o arquivo `.ps1`.

---

## ⚙️ Configuração

Antes de executar, edite o arquivo:

```
esp32_simulador.ps1
```

E configure:

```powershell
$API_URL    = "http://SEU-SERVIDOR:3000/api/readings"
$DEVICE_UID = "esp32_sala"
$INTERVALO  = 3
```

---

## 🔧 Funcionamento do Simulador

O script:

✔ Gera temperatura que oscila suavemente  
✔ Ajusta umidade automaticamente  
✔ Monta o payload JSON  
✔ Envia via `Invoke-RestMethod`  
✔ Exibe logs amigáveis  
✔ Repete infinitamente  

---

## ▶ Execução

```
cd esp32-iot-platform-simulador
.\esp32_simulador.ps1
```

Se der bloqueio de script:

```
Set-ExecutionPolicy Bypass -Scope Process -Force
```

---

## 🖥 Exemplo de Saída

```
=== Simulador ESP32 iniciado ===
Enviando dados a cada 3 segundos para http://localhost:3000/api/readings

[OK] 21:03:10 → Temp=26.1°C  Umid=61.3% | Envio bem-sucedido
[OK] 21:03:13 → Temp=26.0°C  Umid=60.7%
[OK] 21:03:16 → Temp=25.8°C  Umid=59.9%
```

---

## 📡 Uso com Múltiplos Sensores

Para simular vários dispositivos:

1. Duplique o script  
2. Altere `$DEVICE_UID`  
3. Abra múltiplos PowerShells  

Exemplo:

```
esp32_sala
esp32_quarto
esp32_rack
esp32_externo
```

---

## 📜 Código Completo

```powershell
# ==============================
# ESP32 SIMULADOR (PowerShell)
# ==============================

# === CONFIGURAÇÃO ===
$API_URL    = "http://seu-servidor:3000/api/readings"
$DEVICE_UID = "esp32_sala"
$INTERVALO  = 3

# === VARIÁVEIS INICIAIS ===
$temperaturaAtual = 26.0
$umidadeAtual     = 60.0

# === Função para gerar variação suave ===
function Atualizar-Valores {
    param([ref]$temp, [ref]$hum)

    $temp.Value = [Math]::Round($temp.Value + (Get-Random -Minimum -0.3 -Maximum 0.3), 1)
    if ($temp.Value -lt 23) { $temp.Value = 23 }
    if ($temp.Value -gt 30) { $temp.Value = 30 }

    $hum.Value = [Math]::Round(65 - ($temp.Value - 25) * 1.2 + (Get-Random -Minimum -1 -Maximum 1), 1)
    if ($hum.Value -lt 45) { $hum.Value = 45 }
    if ($hum.Value -gt 75) { $hum.Value = 75 }
}

Write-Host "=== Simulador ESP32 iniciado ==="
Write-Host "Enviando dados a cada $INTERVALO segundos para $API_URL`n"

while ($true) {

    Atualizar-Valores -temp ([ref]$temperaturaAtual) -hum ([ref]$umidadeAtual)

    $payload = @{
        device_uid  = $DEVICE_UID
        temperature = $temperaturaAtual
        humidity    = $umidadeAtual
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $API_URL -Method POST -Body $payload -ContentType "application/json"
        Write-Host "[OK] → $(Get-Date -Format HH:mm:ss)  Temp=$temperaturaAtual  Hum=$umidadeAtual"
    }
    catch {
        Write-Host "[ERRO] → $($_.Exception.Message)"
    }

    Start-Sleep -Seconds $INTERVALO
}
```

---

## 👨‍💻 Autor

João Victor da Silva Moura  
Desenvolvedor IoT • Redes • Segurança • Automação
