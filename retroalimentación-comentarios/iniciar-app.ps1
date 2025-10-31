# Script para iniciar la aplicación Spring Boot
# Detecta y detiene procesos que usan el puerto 8080

Write-Host "🚀 Iniciando Aplicación Spring Boot" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si hay algo usando el puerto 8080
$port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port) {
    $pid = $port.OwningProcess
    Write-Host "⚠️  El puerto 8080 está en uso (PID: $pid)" -ForegroundColor Yellow
    Write-Host "   Deteniendo proceso..." -ForegroundColor Gray
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "✅ Proceso detenido" -ForegroundColor Green
    Write-Host ""
}

# Verificar RabbitMQ
Write-Host "🔍 Verificando RabbitMQ..." -ForegroundColor Yellow
$rabbitmq = Test-NetConnection localhost -Port 5672 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($rabbitmq) {
    Write-Host "✅ RabbitMQ está corriendo" -ForegroundColor Green
} else {
    Write-Host "⚠️  RabbitMQ NO está corriendo" -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management" -ForegroundColor Gray
}
Write-Host ""

# Iniciar aplicación
Write-Host "▶️  Iniciando Spring Boot..." -ForegroundColor Yellow
Write-Host ""
.\mvnw spring-boot:run

