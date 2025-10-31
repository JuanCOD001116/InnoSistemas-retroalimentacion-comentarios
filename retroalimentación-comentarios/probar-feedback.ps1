# Script para probar crear feedback y ver qué pasa en RabbitMQ

Write-Host "🧪 Probando Creación de Feedback" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Crear feedback
Write-Host "1️⃣ Creando Feedback en Delivery ID 1..." -ForegroundColor Yellow

$body = @{
    deliveryId = 1
    content = "Este es un feedback de prueba - $(Get-Date -Format 'HH:mm:ss')"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/feedback" `
        -Method Post `
        -ContentType "application/json" `
        -Headers @{"X-User-Id"="1"} `
        -Body $body
    
    Write-Host "✅ Feedback creado exitosamente!" -ForegroundColor Green
    Write-Host "   ID: $($response.id)" -ForegroundColor Gray
    Write-Host "   Contenido: $($response.content)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 Ahora verifica en RabbitMQ Management:" -ForegroundColor Yellow
    Write-Host "   1. Ve a la pestaña 'Queues'" -ForegroundColor Gray
    Write-Host "   2. Haz clic en 'feedback.topic'" -ForegroundColor Gray
    Write-Host "   3. Ve a la pestaña 'Get messages'" -ForegroundColor Gray
    Write-Host "   4. Haz clic en 'Get Message(s)' para ver el mensaje" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "❌ Error al crear feedback:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   Código de estado: $statusCode" -ForegroundColor Yellow
        
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "   Detalles del error:" -ForegroundColor Yellow
            Write-Host $errorBody -ForegroundColor Gray
        } catch {
            Write-Host "   No se pudo leer el cuerpo del error" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "🔍 Verifica:" -ForegroundColor Yellow
    Write-Host "   1. ¿La aplicación Spring Boot está corriendo?" -ForegroundColor Gray
    Write-Host "   2. ¿RabbitMQ está corriendo?" -ForegroundColor Gray
    Write-Host "   3. ¿Los exchanges están creados?" -ForegroundColor Gray
    Write-Host "   4. Revisa los logs de la aplicación para ver el error completo" -ForegroundColor Gray
}

