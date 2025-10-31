# Guía de Pruebas Completas del Sistema

## 🎯 Escenarios de Prueba Paso a Paso

### Escenario 1: Crear Feedback y Verlo en Tiempo Real

#### Paso 1: Iniciar RabbitMQ
```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

#### Paso 2: Iniciar la Aplicación
```bash
./mvnw spring-boot:run
```

#### Paso 3: Abrir RabbitMQ Management
- Navegar a: http://localhost:15672
- Login: `guest` / `guest`
- Ir a "Queues" → verificar que existen `feedback.topic` y `feedback.response`

#### Paso 4: Abrir HTML de Prueba (Frontend)
Crear archivo `test-websocket.html` en el proyecto o usar la consola del navegador:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Test WebSocket</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
</head>
<body>
    <h1>Feedback en Tiempo Real</h1>
    <button onclick="connect()">Conectar</button>
    <button onclick="disconnect()">Desconectar</button>
    <div id="messages"></div>

    <script>
        let stompClient = null;

        function connect() {
            const socket = new SockJS('http://localhost:8080/ws');
            stompClient = Stomp.over(socket);
            
            stompClient.connect({}, function(frame) {
                console.log('Conectado: ' + frame);
                
                // Suscribirse a delivery 1
                stompClient.subscribe('/topic/delivery/1', function(message) {
                    const event = JSON.parse(message.body);
                    showMessage(event);
                });
            });
        }

        function disconnect() {
            if (stompClient !== null) {
                stompClient.disconnect();
            }
        }

        function showMessage(event) {
            const div = document.createElement('div');
            div.innerHTML = `<strong>${event.type}</strong>: ${JSON.stringify(event.payload)}`;
            document.getElementById('messages').appendChild(div);
        }
    </script>
</body>
</html>
```

#### Paso 5: Crear Feedback (Postman/Thunder Client/cURL)
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json

{
  "deliveryId": 1,
  "content": "Este es un comentario de prueba"
}
```

#### Paso 6: Verificar
- ✅ El mensaje aparece en RabbitMQ Management (cola `feedback.topic`)
- ✅ El mensaje aparece automáticamente en el navegador (WebSocket)
- ✅ El feedback se guarda en la base de datos

---

### Escenario 2: Respuesta a Feedback

#### Paso 1: Crear Respuesta
```bash
POST http://localhost:8080/api/v1/feedback/1/responses
Content-Type: application/json

{
  "content": "Gracias por el feedback, lo tendremos en cuenta"
}
```

#### Paso 2: Verificar
- ✅ Mensaje en cola `feedback.response`
- ✅ Aparece en WebSocket si estás suscrito al topic correcto

---

### Escenario 3: Feedback en Tareas

#### Paso 1: Crear Feedback en una Tarea
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json

{
  "taskId": 5,
  "content": "La tarea está bien encaminada"
}
```

#### Paso 2: Suscribirse al Topic de la Tarea
En el frontend:
```javascript
stompClient.subscribe('/topic/task/5', function(message) {
    const event = JSON.parse(message.body);
    console.log('Feedback de tarea:', event);
});
```

---

## 🔍 Verificación de la Configuración

### Verificar que Todo Está Configurado

1. **RabbitMQ corriendo:**
   ```bash
   curl http://localhost:15672/api/overview
   ```

2. **Aplicación Spring Boot corriendo:**
   ```bash
   curl http://localhost:8080/api-docs
   ```

3. **WebSocket accesible:**
   - Abrir consola del navegador
   - Conectar manualmente vía JavaScript (ver ejemplo arriba)

4. **Verificar logs del servicio:**
   - Buscar mensajes: `[RabbitMQ] Evento feedback:`
   - Buscar mensajes: `[WebSocket] Error forwarding` (no deberían aparecer)

---

## 🐛 Troubleshooting

### Problema: No veo mensajes en RabbitMQ

**Solución:**
1. Verificar que RabbitMQ está corriendo: `docker ps` o `Test-NetConnection localhost -Port 5672`
2. Verificar logs de la app - debería decir "Created new connection"
3. Verificar que las colas existen en RabbitMQ Management

### Problema: WebSocket no conecta

**Solución:**
1. Verificar CORS: `app.websocket.allowed-origins` en `application.properties`
2. Verificar que el endpoint es `/ws`
3. Usar SockJS para fallback automático
4. Revisar consola del navegador para errores

### Problema: Los mensajes no llegan al frontend

**Solución:**
1. Verificar que estás suscrito al topic correcto (ej: `/topic/delivery/1`)
2. Verificar que el `deliveryId` del feedback coincide con el topic
3. Revisar logs del servicio para ver si hay errores en `WebSocketMessagingService`

### Problema: Error al iniciar (RabbitMQ connection failed)

**Solución:**
1. Iniciar RabbitMQ primero: `docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management`
2. Esperar 10-15 segundos para que RabbitMQ inicie completamente
3. Luego iniciar la aplicación Spring Boot

