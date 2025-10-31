# 🚀 Guía de Ejecución Paso a Paso - Sistema Completo

## 📋 Requisitos Previos

1. ✅ **Java 21** instalado
2. ✅ **Docker Desktop** instalado y corriendo
3. ✅ **Maven** (incluido en el proyecto como `mvnw`)

---

## 🎯 PASO 1: Iniciar RabbitMQ

### ¿Por qué RabbitMQ?
RabbitMQ es el broker de mensajes que conecta la API con WebSocket. Cuando creas un feedback, se publica en RabbitMQ y luego se reenvía a los clientes WebSocket conectados.

### Ejecutar RabbitMQ con Docker:

```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

**Explicación:**
- `-d`: Ejecuta en modo "detached" (en segundo plano)
- `--name rabbitmq`: Nombre del contenedor
- `-p 5672:5672`: Puerto para conexiones AMQP (Spring Boot se conecta aquí)
- `-p 15672:15672`: Puerto para la interfaz web de gestión

### Verificar que RabbitMQ está corriendo:

```bash
docker ps --filter "name=rabbitmq"
```

Deberías ver algo como:
```
CONTAINER ID   IMAGE                    STATUS         PORTS
abc123def456   rabbitmq:3-management    Up 2 minutes   0.0.0.0:5672->5672/tcp, 0.0.0.0:15672->15672/tcp
```

### Acceder a RabbitMQ Management UI:

1. Abre tu navegador en: **http://localhost:15672**
2. **Usuario:** `guest`
3. **Contraseña:** `guest`

Aquí puedes ver:
- **Queues** (Colas): `feedback.topic` y `feedback.response`
- **Exchanges**: `feedback.exchange` y `feedback.response.exchange`
- **Mensajes en tiempo real** cuando se crean feedbacks

---

## 🎯 PASO 2: Iniciar la Aplicación Spring Boot

### Compilar el proyecto:

```bash
.\mvnw clean compile
```

**Qué hace:**
- Limpia compilaciones anteriores (`clean`)
- Compila el código Java (`compile`)
- Crea archivos `.class` en `target/classes/`

### Iniciar la aplicación:

```bash
.\mvnw spring-boot:run
```

**Qué pasa cuando inicia:**

1. **Spring Boot arranca** - Carga todas las configuraciones
2. **Flyway ejecuta migraciones** - Crea/actualiza tablas en la base de datos
   - `V1__feedback_service.sql`
   - `V2__feedback_scope_project_task.sql`
   - `V3__tasks_relation_to_deliveries.sql`
3. **Se conecta a PostgreSQL (Neon)** - Verifica la conexión
4. **Se conecta a RabbitMQ** - Crea exchanges y queues automáticamente
5. **Inicia el servidor en puerto 8080**

**Logs importantes a buscar:**
```
Started RetroalimentacionYComentariosApplication in X.XXX seconds
```

Si hay un error de conexión a RabbitMQ:
```
Caused by: java.net.ConnectException: Connection refused
```
→ **Solución:** Asegúrate de que RabbitMQ está corriendo (Paso 1)

---

## 🎯 PASO 3: Verificar que Todo Está Funcionando

### 3.1 Verificar que la aplicación responde:

```bash
curl http://localhost:8080/api-docs
```

Deberías ver un JSON con la documentación OpenAPI.

### 3.2 Verificar Swagger UI:

Abre en el navegador: **http://localhost:8080/swagger-ui.html**

Aquí puedes:
- Ver todos los endpoints disponibles
- Probar endpoints directamente desde el navegador
- Ver los modelos de datos (Feedback, FeedbackResponse, etc.)

### 3.3 Verificar RabbitMQ desde la App:

Si la aplicación inició correctamente, deberías ver en RabbitMQ Management:
- **Queues creadas automáticamente:**
  - `feedback.topic` (durable)
  - `feedback.response` (durable)
- **Exchanges creados:**
  - `feedback.exchange` (topic)
  - `feedback.response.exchange` (topic)

---

## 🎯 PASO 4: Probar los Endpoints REST

### 4.1 Crear un Feedback en una Entrega (Delivery)

**Con cURL:**
```bash
curl -X POST http://localhost:8080/api/v1/feedback `
  -H "Content-Type: application/json" `
  -H "X-User-Id: 1" `
  -d '{\"deliveryId\": 1, \"content\": \"Excelente trabajo en la entrega!\"}'
```

**Con PowerShell (Invoke-RestMethod):**
```powershell
$body = @{
    deliveryId = 1
    content = "Excelente trabajo en la entrega!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/v1/feedback" `
  -Method Post `
  -ContentType "application/json" `
  -Headers @{"X-User-Id"="1"} `
  -Body $body
```

**¿Qué pasa internamente?**
1. El `FeedbackController` recibe la petición
2. `FeedbackService.createFeedback()` se ejecuta:
   - Valida los datos
   - Guarda el feedback en la base de datos (tabla `feedback`)
   - Registra la acción en `audit_logs`
   - Publica un evento en RabbitMQ: `feedback.created`
3. `WebSocketMessagingService` consume el mensaje de RabbitMQ
4. Reenvía el mensaje al topic STOMP: `/topic/delivery/1`
5. Todos los clientes WebSocket suscritos a ese topic reciben el mensaje

### 4.2 Listar Feedback de una Entrega

```bash
curl http://localhost:8080/api/v1/feedback?deliveryId=1
```

**Respuesta esperada:**
```json
[
  {
    "id": 1,
    "content": "Excelente trabajo en la entrega!",
    "createdAt": "2025-10-31T16:20:00Z",
    "deliveryId": 1,
    "taskId": null,
    "projectId": null,
    "authorId": 1,
    "edited": false,
    "deleted": false
  }
]
```

### 4.3 Crear una Respuesta a un Feedback

```bash
curl -X POST http://localhost:8080/api/v1/feedback/1/responses `
  -H "Content-Type: application/json" `
  -H "X-User-Id: 2" `
  -d '{\"content\": \"Gracias por el feedback!\"}'
```

**Flujo:**
1. Se guarda la respuesta en `feedback_responses`
2. Se publica evento `reply.created` en RabbitMQ
3. Se reenvía a WebSocket clients

---

## 🎯 PASO 5: Probar WebSocket en Tiempo Real

### 5.1 Abrir el Archivo de Prueba

Abre `test-websocket.html` en tu navegador:
- Doble clic en el archivo, o
- Arrastra el archivo al navegador

### 5.2 Conectar WebSocket

1. Haz clic en **"Conectar"**
2. Deberías ver: **"Estado: Conectado ✓"**
3. Verás un mensaje: "Conectado a WebSocket exitosamente"

**¿Qué pasa?**
- El navegador establece una conexión WebSocket con `ws://localhost:8080/ws`
- SockJS maneja la conexión (con fallbacks si WebSocket puro no está disponible)
- STOMP se encarga del protocolo de mensajería

### 5.3 Suscribirse a un Topic

1. Selecciona **"Delivery"** en el dropdown
2. Ingresa el ID: **1**
3. Haz clic en **"Suscribirse"**

Verás: **"✓ Suscrito a: /topic/delivery/1"**

**¿Qué significa?**
- Ahora el cliente está escuchando todos los eventos relacionados con la entrega con ID 1
- Cualquier feedback creado/actualizado/eliminado en esa entrega llegará aquí

### 5.4 Crear un Feedback y Verlo en Tiempo Real

**Opción A: Desde la misma página HTML**
1. Haz clic en **"Crear Feedback en Delivery"**
2. **¡Mágico!** El mensaje aparece instantáneamente en la sección "Mensajes Recibidos"

**Opción B: Desde otra terminal/Postman**
1. Crea un feedback con cURL o Postman (Paso 4.1)
2. El mensaje aparecerá automáticamente en la página HTML

**Flujo completo:**
```
[Terminal] POST /api/v1/feedback
    ↓
[Spring Boot] FeedbackService guarda en BD
    ↓
[RabbitMQ] Publica en cola "feedback.topic"
    ↓
[WebSocketMessagingService] Consume de RabbitMQ
    ↓
[STOMP] Reenvía a /topic/delivery/1
    ↓
[Navegador] Recibe mensaje y lo muestra
```

### 5.5 Verificar en RabbitMQ Management

Mientras tanto, abre **http://localhost:15672**:

1. Ve a **"Queues"**
2. Haz clic en **"feedback.topic"**
3. En la pestaña **"Get messages"**, puedes ver los mensajes que pasaron por la cola

---

## 🎯 PASO 6: Probar Múltiples Clientes

### Escenario: Dos Usuarios viendo la misma entrega

1. **Abre `test-websocket.html` en dos navegadores diferentes** (o dos pestañas)
2. **Conecta ambos** al WebSocket
3. **Suscríbete a `/topic/delivery/1` en ambos**
4. **Crea un feedback desde Postman/terminal**
5. **¡Ambos navegadores reciben el mensaje al mismo tiempo!**

Esto simula el comportamiento real:
- Un profesor crea un comentario
- Todos los estudiantes del equipo lo ven instantáneamente
- No necesitan refrescar la página

---

## 🔍 Entendiendo la Arquitectura

### ¿Por qué RabbitMQ + WebSocket?

```
┌─────────────┐
│   Frontend  │  ← Clientes WebSocket (React, Vue, etc.)
└──────┬──────┘
       │ WebSocket STOMP
       ↓
┌─────────────────────┐
│  Spring Boot App    │
│  WebSocketMessaging │  ← Consume de RabbitMQ y reenvía
│  Service            │
└──────┬──────────────┘
       │ Consume
       ↓
┌─────────────────────┐
│     RabbitMQ        │  ← Cola de mensajes (desacopla servicios)
│  (feedback.topic)   │
└──────┬──────────────┘
       │ Publica
       ↓
┌─────────────────────┐
│  FeedbackService     │  ← Crea feedback en BD
└─────────────────────┘
```

**Ventajas:**
1. **Desacoplamiento**: La API no necesita saber sobre clientes WebSocket
2. **Escalabilidad**: Puedes tener múltiples instancias de la app consumiendo de RabbitMQ
3. **Confiabilidad**: Si un cliente se desconecta, los mensajes están en RabbitMQ
4. **Flexibilidad**: Otros servicios pueden suscribirse a RabbitMQ también

### Componentes Clave:

#### 1. **RabbitMQConfig.java**
- Crea los exchanges y queues cuando la app inicia
- Define los bindings (qué queue escucha qué routing key)

#### 2. **WebSocketConfig.java**
- Configura el endpoint `/ws`
- Habilita STOMP
- Configura CORS

#### 3. **WebSocketMessagingService.java**
- Tiene `@RabbitListener` que escucha las colas
- Cuando llega un mensaje, lo reenvía a los topics STOMP
- Determina el topic correcto según el tipo de feedback (delivery/task/project)

#### 4. **FeedbackService.java**
- Después de guardar en BD, publica en RabbitMQ usando `RabbitTemplate`
- No sabe nada sobre WebSocket

---

## 🐛 Troubleshooting

### Error: "Connection refused" al iniciar

**Problema:** RabbitMQ no está corriendo

**Solución:**
```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

### Error: "Port 5672 already in use"

**Problema:** RabbitMQ ya está corriendo en otro contenedor

**Solución:**
```bash
# Ver contenedores
docker ps -a

# Detener el contenedor existente
docker stop rabbitmq
docker rm rabbitmq

# Iniciar uno nuevo
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

### WebSocket no conecta

**Verificar:**
1. ¿La app está corriendo? `curl http://localhost:8080/api-docs`
2. ¿El endpoint es correcto? `ws://localhost:8080/ws`
3. Revisa la consola del navegador (F12) para errores

### Los mensajes no llegan al frontend

**Verificar:**
1. ¿Estás suscrito al topic correcto? (ej: `/topic/delivery/1`)
2. ¿El `deliveryId` del feedback coincide con el topic?
3. Revisa los logs de la app para ver si hay errores en `WebSocketMessagingService`

---

## ✅ Checklist Final

Antes de considerar el sistema completamente funcional:

- [ ] RabbitMQ corriendo y accesible en http://localhost:15672
- [ ] Aplicación Spring Boot iniciada sin errores
- [ ] Swagger UI accesible en http://localhost:8080/swagger-ui.html
- [ ] Puedo crear feedbacks via API
- [ ] Puedo listar feedbacks via API
- [ ] WebSocket se conecta desde `test-websocket.html`
- [ ] Puedo suscribirme a topics
- [ ] Cuando creo un feedback, aparece en tiempo real en el navegador
- [ ] Veo los mensajes en RabbitMQ Management UI
- [ ] Múltiples clientes reciben el mismo mensaje

---

## 🎓 Conceptos Clave Entendidos

✅ **REST API**: Endpoints HTTP para crear/listar feedback
✅ **RabbitMQ**: Cola de mensajes que desacopla servicios
✅ **WebSocket**: Conexión persistente para mensajes en tiempo real
✅ **STOMP**: Protocolo de mensajería sobre WebSocket
✅ **Arquitectura**: Cómo todos los componentes trabajan juntos

