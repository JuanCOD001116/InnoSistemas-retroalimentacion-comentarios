# Script para detener todos los servicios en Windows
# Ejecutar con: .\stop.ps1

Write-Host "🛑 Deteniendo servicios..." -ForegroundColor Cyan
Write-Host ""

# Detener RabbitMQ
$rabbitRunning = docker ps --filter "name=rabbitmq" --format "{{.Names}}" | Select-String "rabbitmq"

if ($rabbitRunning) {
    Write-Host "🐰 Deteniendo RabbitMQ..." -ForegroundColor Cyan
    docker stop rabbitmq
    Write-Host "✓ RabbitMQ detenido" -ForegroundColor Green
}
else {
    Write-Host "ℹ️  RabbitMQ no está corriendo" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Servicios detenidos" -ForegroundColor Green
Write-Host ""
Write-Host "Para eliminar el contenedor completamente, ejecuta:"
Write-Host "  docker rm rabbitmq"
