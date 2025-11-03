# Script para iniciar el proyecto completo en Windows
# Ejecutar con: .\start.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando Sistema de Retroalimentación y Comentarios..." -ForegroundColor Cyan
Write-Host ""

# Función para verificar si un comando existe
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Función para verificar Docker
function Test-Docker {
    if (-not (Test-CommandExists docker)) {
        Write-Host "❌ Docker no está instalado." -ForegroundColor Red
        Write-Host "Por favor instala Docker Desktop desde: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    }
    
    try {
        docker info | Out-Null
        Write-Host "✓ Docker está corriendo" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Docker no está corriendo." -ForegroundColor Red
        Write-Host "Por favor inicia Docker Desktop y vuelve a ejecutar este script."
        exit 1
    }
}

# Función para verificar Java
function Test-Java {
    if (-not (Test-CommandExists java)) {
        Write-Host "❌ Java no está instalado." -ForegroundColor Red
        Write-Host "Por favor instala Java 21 desde: https://adoptium.net/"
        exit 1
    }
    
    $javaVersion = (java -version 2>&1)[0] -replace '.*"(\d+).*', '$1'
    if ([int]$javaVersion -lt 21) {
        Write-Host "⚠️  Advertencia: Se requiere Java 21 o superior. Versión actual: $javaVersion" -ForegroundColor Yellow
    }
    else {
        Write-Host "✓ Java $javaVersion está instalado" -ForegroundColor Green
    }
}

# Verificar prerrequisitos
Write-Host "📋 Verificando prerrequisitos..." -ForegroundColor Cyan
Test-Docker
Test-Java
Write-Host ""

# Verificar si RabbitMQ ya está corriendo
Write-Host "🐰 Verificando RabbitMQ..." -ForegroundColor Cyan
$rabbitRunning = docker ps --filter "name=rabbitmq" --format "{{.Names}}" | Select-String "rabbitmq"

if ($rabbitRunning) {
    Write-Host "✓ RabbitMQ ya está corriendo" -ForegroundColor Green
}
else {
    # Verificar si el contenedor existe pero está detenido
    $rabbitExists = docker ps -a --filter "name=rabbitmq" --format "{{.Names}}" | Select-String "rabbitmq"
    
    if ($rabbitExists) {
        Write-Host "⚠️  RabbitMQ existe pero está detenido. Iniciando..." -ForegroundColor Yellow
        docker start rabbitmq
        Write-Host "✓ RabbitMQ iniciado" -ForegroundColor Green
    }
    else {
        Write-Host "📦 Iniciando RabbitMQ por primera vez..." -ForegroundColor Cyan
        docker run -d --name rabbitmq `
            -p 5672:5672 `
            -p 15672:15672 `
            rabbitmq:3-management
        
        Write-Host "✓ RabbitMQ iniciado exitosamente" -ForegroundColor Green
        Write-Host "⏳ Esperando 10 segundos a que RabbitMQ esté completamente listo..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
    }
}

Write-Host ""
Write-Host "📊 Información de RabbitMQ:" -ForegroundColor Cyan
Write-Host "   - Management UI: http://localhost:15672"
Write-Host "   - Usuario: guest"
Write-Host "   - Contraseña: guest"
Write-Host ""

# Opción para limpiar y reconstruir
if ($args -contains "--clean" -or $args -contains "-c") {
    Write-Host "🧹 Limpiando proyecto..." -ForegroundColor Cyan
    .\mvnw.cmd clean
    Write-Host ""
}

# Configurar variables de entorno para desarrollo local
$env:RABBITMQ_HOST = "localhost"
$env:DB_URL = "jdbc:postgresql://localhost:5432/InnosistemasDB"

# Iniciar la aplicación Spring Boot
Write-Host "🌱 Iniciando aplicación Spring Boot..." -ForegroundColor Cyan
Write-Host "   - Swagger UI: http://localhost:8080/swagger-ui.html"
Write-Host "   - API Docs: http://localhost:8080/api-docs"
Write-Host "   - WebSocket: ws://localhost:8080/ws"
Write-Host ""
Write-Host "Presiona Ctrl+C para detener la aplicación" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================="
Write-Host ""

# Ejecutar Maven con Spring Boot
.\mvnw.cmd spring-boot:run
