# 🔍 Diagnóstico de RabbitMQ - Paso a Paso

## ✅ Lo que Ya Sabemos:

1. ✅ RabbitMQ está corriendo (puerto 15672 accesible)
2. ✅ Las colas están creadas:
   - `feedback.topic` (Durable, Idle, 0 mensajes)
   - `feedback.response` (Durable, Idle, 0 mensajes)

## 📋 Checklist de Verificación:

### PASO 1: Verificar Exchanges

**En RabbitMQ Management:**
1. Ve a la pestaña **"Exchanges"**
2. Busca los siguientes exchanges:
   - ✅ `feedback.exchange` (tipo: **topic**)
   - ✅ `feedback.response.exchange` (tipo: **topic**)

**Si NO ves los exchanges:**
- La aplicación Spring Boot no los ha creado aún
- Puede ser que la aplicación no se conectó correctamente a RabbitMQ
- O que `RabbitMQConfig` no se ejecutó

### PASO 2: Verificar Bindings (Enlaces)

**En RabbitMQ Management:**
1. En la pestaña **"Exchanges"**, haz clic en `feedback.exchange`
2. Ve a la pestaña **"Bindings"** (en la parte inferior)
3. Deberías ver:
   - Queue: `feedback.topic`
   - Routing key: `feedback.*`

4. Haz lo mismo con `feedback.response.exchange`:
   - Queue: `feedback.response`
   - Routing key: `response.*`

**Si NO ves los bindings:**
- Los exchanges y queues están creados pero no conectados
- El problema está en la configuración de bindings

### PASO 3: Verificar Conexión de la Aplicación

**En RabbitMQ Management:**
1. Ve a la pestaña **"Connections"**
2. Deberías ver una conexión activa con:
   - Name: Algo como `127.0.0.1:XXXXX -> 127.0.0.1:5672`
   - State: **Running**
   - User: `guest`

**Si NO ves conexiones:**
- La aplicación Spring Boot no se está conectando a RabbitMQ
- Verifica que la aplicación esté corriendo
- Revisa los logs de la aplicación para errores de conexión

### PASO 4: Probar Crear Feedback

**Ejecuta el script de prueba:**
```powershell
.\probar-feedback.ps1
```

**O manualmente:**
```powershell
$body = @{
    deliveryId = 1
    content = "Prueba de mensaje"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/feedback" `
    -Method Post `
    -ContentType "application/json" `
    -Headers @{"X-User-Id"="1"} `
    -Body $body
```

**Resultados esperados:**
- ✅ **Si funciona:** Verás el feedback creado y un mensaje aparecerá en RabbitMQ
- ❌ **Si falla:** Verás un error 500 y necesitamos revisar los logs

### PASO 5: Verificar Mensajes en RabbitMQ

**Después de crear un feedback exitosamente:**

1. Ve a **"Queues"** → Haz clic en **"feedback.topic"**
2. En la sección **"Message rates"**, deberías ver:
   - **incoming:** Un número > 0
   - **deliver / get:** Un número > 0

3. Ve a la pestaña **"Get messages"**
4. Haz clic en **"Get Message(s)"**
5. Deberías ver el mensaje JSON publicado por la aplicación

**Si NO ves mensajes:**
- El feedback se guardó en la BD pero no se publicó en RabbitMQ
- Hay un error en `FeedbackService.createFeedback()` cuando intenta publicar
- Necesitamos revisar los logs de la aplicación

---

## 🐛 Problemas Comunes y Soluciones:

### Problema 1: Exchanges NO están creados

**Solución:**
1. Reinicia la aplicación Spring Boot
2. Los exchanges se crean automáticamente cuando `RabbitMQConfig` se ejecuta
3. Verifica los logs al iniciar para ver si hay errores

**Logs esperados:**
```
Connected to RabbitMQ broker
```

### Problema 2: Error 500 al crear feedback

**Posibles causas:**
1. **RabbitMQ no está corriendo** → La aplicación no puede publicar
2. **Exchange no existe** → El mensaje no tiene dónde publicarse
3. **Error de serialización** → El objeto no se puede convertir a JSON

**Solución:**
- Revisa los logs de la aplicación
- Busca líneas que digan `Exception`, `Error`, o `Failed`

### Problema 3: Los mensajes se publican pero no se ven en RabbitMQ

**Causa común:**
- Los mensajes se consumen inmediatamente por `WebSocketMessagingService`
- Esto es **normal** si hay consumidores activos

**Para ver mensajes:**
- Los mensajes en colas se consumen automáticamente
- Usa **"Get messages"** para ver mensajes que pasaron por la cola
- O pausa temporalmente el consumidor

### Problema 4: No hay conexión activa en RabbitMQ

**Solución:**
1. Verifica que la aplicación esté corriendo: `Test-NetConnection localhost -Port 8080`
2. Verifica que RabbitMQ esté corriendo: `Test-NetConnection localhost -Port 5672`
3. Revisa `application.properties`:
   ```properties
   spring.rabbitmq.host=localhost
   spring.rabbitmq.port=5672
   spring.rabbitmq.username=guest
   spring.rabbitmq.password=guest
   ```

---

## 📊 Información que Necesito para Diagnosticar:

**Por favor, muéstrame o dime:**

1. **¿Los exchanges están creados?**
   - Ve a "Exchanges" y dime qué exchanges ves

2. **¿Hay conexiones activas?**
   - Ve a "Connections" y dime si ves alguna conexión

3. **¿Qué pasa cuando intentas crear un feedback?**
   - Ejecuta `.\probar-feedback.ps1` y dime el resultado

4. **¿Qué dicen los logs de la aplicación?**
   - Busca errores relacionados con RabbitMQ
   - Busca líneas que digan "convertAndSend" o "RabbitMQ"

5. **¿Los bindings están configurados?**
   - En "Exchanges" → `feedback.exchange` → "Bindings"
   - ¿Ves la cola `feedback.topic` enlazada?

---

## ✅ Qué Hacer Ahora:

1. **Ejecuta el script de prueba:**
   ```powershell
   .\probar-feedback.ps1
   ```

2. **Revisa RabbitMQ Management:**
   - Exchanges
   - Connections
   - Bindings

3. **Comparte conmigo:**
   - Captura de pantalla de "Exchanges"
   - Captura de pantalla de "Connections"
   - Resultado del script de prueba
   - Cualquier error que veas

Con esta información podré identificar exactamente qué está pasando y cómo solucionarlo.

