# Configuración de RabbitMQ y WebSocket

## 🐰 RabbitMQ - Visualización y Configuración

### 1. Instalar y Ejecutar RabbitMQ

**Opción A: Docker (Recomendado)**
```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

**Opción B: Instalación Local**
- Descargar desde: https://www.rabbitmq.com/download.html
- O usar Chocolatey en Windows: `choco install rabbitmq`

### 2. Acceder a RabbitMQ Management UI

Una vez ejecutando RabbitMQ:

1. Abre tu navegador en: **http://localhost:15672**
2. **Usuario:** `guest`
3. **Contraseña:** `guest`

### 3. Visualizar las Colas de Mensajes

En la interfaz de RabbitMQ:

1. Ve a la pestaña **"Queues"**
2. Verás las siguientes colas:
   - `feedback.topic` - Mensajes de feedback (created, updated, deleted)
   - `feedback.response` - Mensajes de respuestas (created, updated, deleted)

3. **Para ver mensajes en tiempo real:**
   - Haz clic en el nombre de una cola
   - Ve a la pestaña **"Get messages"**
   - Haz clic en **"Get Message(s)"** para ver los mensajes

4. **Para monitorear mensajes entrantes:**
   - En la pestaña **"Queues"**, observa el contador de mensajes
   - Los mensajes se consumen automáticamente por `WebSocketMessagingService`

### 4. Verificar Exchanges

En la pestaña **"Exchanges"**:
- `feedback.exchange` - Topic exchange para feedback
- `feedback.response.exchange` - Topic exchange para respuestas

### 5. Configuración Actual en `application.properties`

```properties
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
```

---

## 🌐 WebSocket - Configuración para Frontend

### Endpoint WebSocket

**URL de Conexión:** `ws://localhost:8080/ws`

**Con SockJS (Recomendado):** `http://localhost:8080/ws`

### Topics STOMP Disponibles

Los clientes se pueden suscribir a:

1. **`/topic/delivery/{deliveryId}`** - Feedback de una entrega específica
2. **`/topic/task/{taskId}`** - Feedback de una tarea específica  
3. **`/topic/project/{projectId}`** - Feedback de un proyecto específico

### Eventos que se Publican

Cada evento tiene el formato:
```json
{
  "type": "feedback.created" | "feedback.updated" | "feedback.deleted" | 
          "reply.created" | "reply.updated" | "reply.deleted",
  "payload": {
    // Objeto Feedback o FeedbackResponse completo
  }
}
```

---

## 💻 Ejemplo de Conexión desde Frontend (JavaScript)

### HTML + JavaScript (Vanilla)

```html
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Test</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
</head>
<body>
    <h1>Feedback en Tiempo Real</h1>
    <div id="messages"></div>

    <script>
        // Conectar a WebSocket
        const socket = new SockJS('http://localhost:8080/ws');
        const stompClient = Stomp.over(socket);

        // Conectar
        stompClient.connect({}, function(frame) {
            console.log('Conectado: ' + frame);
            
            // Suscribirse a feedback de delivery ID 1
            const subscription = stompClient.subscribe('/topic/delivery/1', function(message) {
                const event = JSON.parse(message.body);
                console.log('Evento recibido:', event);
                
                // Mostrar en la página
                const div = document.createElement('div');
                div.textContent = `[${event.type}] ${JSON.stringify(event.payload)}`;
                document.getElementById('messages').appendChild(div);
            });
            
            console.log('Suscrito a /topic/delivery/1');
        });

        // Desconectar (opcional)
        // stompClient.disconnect();
    </script>
</body>
</html>
```

### React Example

```jsx
import { useEffect, useState } from 'react';
import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';

function FeedbackComponent({ deliveryId }) {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    const socket = new SockJS('http://localhost:8080/ws');
    const client = new Client({
      webSocketFactory: () => socket,
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
    });

    client.onConnect = () => {
      console.log('Conectado a WebSocket');
      
      client.subscribe(`/topic/delivery/${deliveryId}`, (message) => {
        const event = JSON.parse(message.body);
        setMessages(prev => [...prev, event]);
      });
    };

    client.activate();

    return () => {
      client.deactivate();
    };
  }, [deliveryId]);

  return (
    <div>
      <h2>Feedback en Tiempo Real</h2>
      {messages.map((msg, idx) => (
        <div key={idx}>
          <strong>{msg.type}:</strong> {JSON.stringify(msg.payload)}
        </div>
      ))}
    </div>
  );
}
```

### Vue.js Example

```vue
<template>
  <div>
    <h2>Feedback en Tiempo Real</h2>
    <div v-for="(msg, idx) in messages" :key="idx">
      <strong>{{ msg.type }}:</strong> {{ msg.payload }}
    </div>
  </div>
</template>

<script>
import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';

export default {
  data() {
    return {
      messages: [],
      client: null
    };
  },
  props: {
    deliveryId: Number
  },
  mounted() {
    const socket = new SockJS('http://localhost:8080/ws');
    this.client = new Client({
      webSocketFactory: () => socket,
      reconnectDelay: 5000
    });

    this.client.onConnect = () => {
      this.client.subscribe(`/topic/delivery/${this.deliveryId}`, (message) => {
        const event = JSON.parse(message.body);
        this.messages.push(event);
      });
    };

    this.client.activate();
  },
  beforeUnmount() {
    if (this.client) {
      this.client.deactivate();
    }
  }
};
</script>
```

---

## 🔄 Flujo Completo: API → RabbitMQ → WebSocket → Frontend

```
1. Frontend hace POST /api/v1/feedback
   ↓
2. FeedbackService guarda en BD y publica en RabbitMQ
   ↓
3. WebSocketMessagingService consume de RabbitMQ
   ↓
4. WebSocketMessagingService reenvía a topic STOMP
   ↓
5. Todos los clientes suscritos al topic reciben el evento
```

### Ejemplo de Flujo Completo:

**Terminal 1 - Ver logs del servicio:**
```bash
./mvnw spring-boot:run
```

**Terminal 2 - RabbitMQ Management:**
- Abrir http://localhost:15672
- Monitorear colas en tiempo real

**Navegador - Frontend:**
- Conectar a `ws://localhost:8080/ws`
- Suscribirse a `/topic/delivery/1`
- Hacer POST desde otra pestaña o Postman
- Ver el mensaje aparecer automáticamente

---

## ✅ Checklist de Configuración Final

### 1. RabbitMQ ✅
- [x] Configurado en `application.properties`
- [x] Exchanges y Queues creados en `RabbitMQConfig`
- [ ] **FALTA:** Ejecutar RabbitMQ (Docker o instalación local)

### 2. WebSocket ✅
- [x] Configuración STOMP en `WebSocketConfig`
- [x] Endpoint `/ws` configurado
- [x] CORS configurado (`*` por defecto)

### 3. Integración RabbitMQ → WebSocket ✅
- [x] `WebSocketMessagingService` consume de RabbitMQ
- [x] Reenvía mensajes a topics STOMP

### 4. Frontend
- [ ] Instalar dependencias STOMP/SockJS en frontend
- [ ] Conectar a `ws://localhost:8080/ws`
- [ ] Suscribirse a topics según necesidad

### 5. Pruebas
- [ ] Verificar que RabbitMQ esté corriendo
- [ ] Crear feedback via API
- [ ] Ver mensaje en RabbitMQ Management
- [ ] Ver mensaje llegar a cliente WebSocket

---

## 🚀 Comandos Rápidos

### Iniciar RabbitMQ con Docker
```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

### Ver logs de RabbitMQ
```bash
docker logs -f rabbitmq
```

### Detener RabbitMQ
```bash
docker stop rabbitmq
docker rm rabbitmq
```

### Verificar que RabbitMQ está corriendo
```bash
# Windows PowerShell
Test-NetConnection localhost -Port 5672
Test-NetConnection localhost -Port 15672
```

---

## 📝 Notas Importantes

1. **RabbitMQ debe estar corriendo antes de iniciar la aplicación Spring Boot**
2. **El frontend debe estar en un origen permitido** (configurado en `app.websocket.allowed-origins`)
3. **Los mensajes se consumen automáticamente** - no quedan en la cola indefinidamente
4. **Si no hay clientes WebSocket conectados**, los mensajes se procesan pero no se reenvían

