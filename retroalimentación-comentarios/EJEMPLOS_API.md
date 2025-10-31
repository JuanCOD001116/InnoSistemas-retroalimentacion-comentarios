# Ejemplos de Uso de la API - Retroalimentación y Comentarios

## 🔧 Configuración Base

**URL Base:** `http://localhost:8080/api/v1`

**Headers opcionales (para pruebas):**
```
X-User-Id: 1        # ID del usuario (por defecto: 1)
X-User-Role: profesor  # o "estudiante"
```

---

## 📝 Endpoints de Feedback

### 1. Listar Feedback

#### Por Delivery
```bash
GET http://localhost:8080/api/v1/feedback?deliveryId=1
```

#### Por Task
```bash
GET http://localhost:8080/api/v1/feedback?taskId=5
```

#### Por Project
```bash
GET http://localhost:8080/api/v1/feedback?projectId=201
```

**Respuesta ejemplo:**
```json
[
  {
    "id": 1,
    "content": "Excelente trabajo en la entrega",
    "createdAt": "2025-10-31T10:00:00Z",
    "deliveryId": 1,
    "taskId": null,
    "projectId": null,
    "authorId": 20,
    "edited": false,
    "deleted": false
  }
]
```

---

### 2. Crear Feedback

#### Feedback en una Entrega (Delivery)
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json

{
  "deliveryId": 1,
  "content": "El código está bien estructurado, pero falta documentación"
}
```

#### Feedback en una Tarea (Task)
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json

{
  "taskId": 5,
  "content": "Avance correcto, continua así"
}
```

#### Feedback en un Proyecto (Project)
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json

{
  "projectId": 201,
  "content": "El proyecto necesita mejoras en la arquitectura"
}
```

**Con headers personalizados:**
```bash
POST http://localhost:8080/api/v1/feedback
Content-Type: application/json
X-User-Id: 25
X-User-Role: profesor

{
  "deliveryId": 1,
  "content": "Comentario del profesor"
}
```

---

### 3. Actualizar Feedback

```bash
PATCH http://localhost:8080/api/v1/feedback/1
Content-Type: application/json

{
  "content": "Comentario actualizado"
}
```

---

### 4. Eliminar Feedback

```bash
DELETE http://localhost:8080/api/v1/feedback/1
```

---

## 💬 Endpoints de Respuestas (Feedback Responses)

### 1. Listar Respuestas de un Feedback

```bash
GET http://localhost:8080/api/v1/feedback/1/responses
```

**Respuesta ejemplo:**
```json
[
  {
    "id": 1,
    "content": "Gracias por el feedback, trabajaremos en eso",
    "createdAt": "2025-10-31T11:00:00Z",
    "feedbackId": 1,
    "authorId": 21,
    "edited": false,
    "deleted": false
  }
]
```

---

### 2. Crear Respuesta a un Feedback

```bash
POST http://localhost:8080/api/v1/feedback/1/responses
Content-Type: application/json

{
  "content": "Entendido, trabajaremos en mejorar la documentación"
}
```

---

### 3. Actualizar Respuesta

```bash
PATCH http://localhost:8080/api/v1/feedback-responses/1
Content-Type: application/json

{
  "content": "Respuesta actualizada"
}
```

---

### 4. Eliminar Respuesta

```bash
DELETE http://localhost:8080/api/v1/feedback-responses/1
```

---

## 📊 Endpoints de Reportes

### 1. Reporte de Estudiante (JSON)

```bash
GET http://localhost:8080/api/v1/reports/student?projectId=201
```

### 2. Reporte de Estudiante (PDF)

```bash
GET http://localhost:8080/api/v1/reports/student/pdf?projectId=201
```

### 3. Reporte de Equipo (JSON)

```bash
GET http://localhost:8080/api/v1/reports/team?teamId=1
```

### 4. Reporte de Equipo (PDF)

```bash
GET http://localhost:8080/api/v1/reports/team/pdf?teamId=1
```

---

## 🧪 Ejemplos con cURL

```bash
# Crear feedback
curl -X POST http://localhost:8080/api/v1/feedback \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 20" \
  -d '{"deliveryId": 1, "content": "Buen trabajo!"}'

# Listar feedback de una entrega
curl http://localhost:8080/api/v1/feedback?deliveryId=1

# Crear respuesta
curl -X POST http://localhost:8080/api/v1/feedback/1/responses \
  -H "Content-Type: application/json" \
  -d '{"content": "Gracias!"}'
```

---

## 📋 Ejemplos con Postman/Thunder Client

### Collection JSON para importar:

```json
{
  "info": {
    "name": "Retroalimentación API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Crear Feedback",
      "request": {
        "method": "POST",
        "header": [
          {"key": "Content-Type", "value": "application/json"},
          {"key": "X-User-Id", "value": "1"}
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"deliveryId\": 1,\n  \"content\": \"Comentario de prueba\"\n}"
        },
        "url": {
          "raw": "http://localhost:8080/api/v1/feedback",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "feedback"]
        }
      }
    },
    {
      "name": "Listar Feedback",
      "request": {
        "method": "GET",
        "url": {
          "raw": "http://localhost:8080/api/v1/feedback?deliveryId=1",
          "protocol": "http",
          "host": ["localhost"],
          "port": "8080",
          "path": ["api", "v1", "feedback"],
          "query": [{"key": "deliveryId", "value": "1"}]
        }
      }
    }
  ]
}
```

