# Script de Prueba de Endpoints - Retroalimentación API
# Ejecutar desde PowerShell: .\test-endpoints.ps1

$baseUrl = "http://localhost:8080/api/v1"
$headers = @{
    "Content-Type" = "application/json"
    "X-User-Id" = "1"
    "X-User-Role" = "profesor"
}

Write-Host "🧪 Probando Endpoints de Retroalimentación API" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verificar que la API responde
Write-Host "1️⃣ Verificando que la API está corriendo..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/feedback?deliveryId=999" -Method Get -ErrorAction SilentlyContinue
    Write-Host "✅ API está corriendo" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✅ API está corriendo (endpoint existe)" -ForegroundColor Green
    } else {
        Write-Host "❌ API no responde. Verifica que la aplicación está corriendo." -ForegroundColor Red
        Write-Host "   Ejecuta: .\mvnw spring-boot:run" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host ""

# Test 2: Crear Feedback en una Entrega
Write-Host "2️⃣ Creando Feedback en Delivery ID 1..." -ForegroundColor Yellow
$feedbackBody = @{
    deliveryId = 1
    content = "Este es un feedback de prueba creado desde el script de PowerShell. Excelente trabajo!"
} | ConvertTo-Json

try {
    $feedback = Invoke-RestMethod -Uri "$baseUrl/feedback" `
        -Method Post `
        -Headers $headers `
        -Body $feedbackBody
    
    $feedbackId = $feedback.id
    Write-Host "✅ Feedback creado exitosamente!" -ForegroundColor Green
    Write-Host "   ID: $feedbackId" -ForegroundColor Gray
    Write-Host "   Contenido: $($feedback.content)" -ForegroundColor Gray
    Write-Host "   Delivery ID: $($feedback.deliveryId)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Error al crear feedback:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Test 3: Listar Feedback de la Entrega
Write-Host "3️⃣ Listando Feedback de Delivery ID 1..." -ForegroundColor Yellow
try {
    $feedbacks = Invoke-RestMethod -Uri "$baseUrl/feedback?deliveryId=1" -Method Get
    Write-Host "✅ Se encontraron $($feedbacks.Count) feedback(s)" -ForegroundColor Green
    foreach ($fb in $feedbacks) {
        Write-Host "   - ID $($fb.id): $($fb.content.Substring(0, [Math]::Min(50, $fb.content.Length)))..." -ForegroundColor Gray
    }
    Write-Host ""
} catch {
    Write-Host "❌ Error al listar feedback:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

# Test 4: Crear Respuesta al Feedback
Write-Host "4️⃣ Creando Respuesta al Feedback ID $feedbackId..." -ForegroundColor Yellow
$responseBody = @{
    content = "Gracias por el feedback! Lo tendremos en cuenta."
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/feedback/$feedbackId/responses" `
        -Method Post `
        -Headers $headers `
        -Body $responseBody
    
    $responseId = $response.id
    Write-Host "✅ Respuesta creada exitosamente!" -ForegroundColor Green
    Write-Host "   ID: $responseId" -ForegroundColor Gray
    Write-Host "   Contenido: $($response.content)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Error al crear respuesta:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

# Test 5: Listar Respuestas
Write-Host "5️⃣ Listando Respuestas del Feedback ID $feedbackId..." -ForegroundColor Yellow
try {
    $responses = Invoke-RestMethod -Uri "$baseUrl/feedback/$feedbackId/responses" -Method Get
    Write-Host "✅ Se encontraron $($responses.Count) respuesta(s)" -ForegroundColor Green
    foreach ($resp in $responses) {
        Write-Host "   - ID $($resp.id): $($resp.content)" -ForegroundColor Gray
    }
    Write-Host ""
} catch {
    Write-Host "❌ Error al listar respuestas:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

# Test 6: Actualizar Feedback
Write-Host "6️⃣ Actualizando Feedback ID $feedbackId..." -ForegroundColor Yellow
$updateBody = @{
    content = "Contenido actualizado: Este feedback fue modificado desde el script de prueba."
} | ConvertTo-Json

try {
    $updated = Invoke-RestMethod -Uri "$baseUrl/feedback/$feedbackId" `
        -Method Patch `
        -Headers $headers `
        -Body $updateBody
    
    Write-Host "✅ Feedback actualizado exitosamente!" -ForegroundColor Green
    Write-Host "   Nuevo contenido: $($updated.content)" -ForegroundColor Gray
    Write-Host "   Editado: $($updated.edited)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Error al actualizar feedback:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

# Resumen
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "✅ Pruebas completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Inicia RabbitMQ: docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management" -ForegroundColor Gray
Write-Host "   2. Abre test-websocket.html en el navegador" -ForegroundColor Gray
Write-Host "   3. Crea un nuevo feedback y observalo aparecer en tiempo real" -ForegroundColor Gray
Write-Host ""

