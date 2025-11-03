# Endpoint: Obtener Feedbacks con Respuestas por Delivery

## Descripción
Este endpoint retorna todos los feedbacks de un delivery específico junto con todas sus respuestas asociadas en una sola llamada.

## URL
```
GET /api/v1/deliveries/{deliveryId}/feedbacks-with-responses
```

## Parámetros

### Path Parameters
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| deliveryId | Long | Sí | ID del delivery del cual se quieren obtener los feedbacks |

### Headers
| Header | Tipo | Requerido | Descripción |
|--------|------|-----------|-------------|
| X-User-Id | String | No | ID del usuario que realiza la petición (default: 1) |
| X-User-Role | String | No | Rol del usuario (ej: "profesor", "estudiante") |

## Respuesta

### Código de Estado
- `200 OK`: La petición fue exitosa

### Formato de Respuesta
```json
[
  {
    "feedback": {
      "id": 1,
      "content": "Texto del feedback",
      "createdAt": "2025-10-29T00:29:15.896536Z",
      "updatedAt": null,
      "deliveryId": 1,
      "projectId": null,
      "taskId": null,
      "authorId": 101,
      "edited": false,
      "deleted": false
    },
    "responses": [
      {
        "id": 1,
        "content": "Texto de la respuesta",
        "createdAt": "2025-10-29T12:29:15.896536Z",
        "updatedAt": null,
        "feedbackId": 1,
        "authorId": 104,
        "edited": false,
        "deleted": false
      }
    ]
  }
]
```

## Ejemplos de Uso

### Ejemplo 1: Obtener feedbacks del delivery 1

**Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/deliveries/1/feedbacks-with-responses" \
  -H "X-User-Id: 101" \
  -H "Content-Type: application/json"
```

**Response:**
```json
[
  {
    "feedback": {
      "id": 1,
      "content": "Excelente trabajo en esta entrega. El código está bien estructurado y documentado.",
      "createdAt": "2025-10-29T00:29:15.896536Z",
      "updatedAt": null,
      "deliveryId": 1,
      "projectId": null,
      "taskId": null,
      "authorId": 101,
      "edited": false,
      "deleted": false
    },
    "responses": [
      {
        "id": 1,
        "content": "Gracias por el feedback positivo. Me alegra que te haya gustado la estructura del código.",
        "createdAt": "2025-10-29T12:29:15.896536Z",
        "updatedAt": null,
        "feedbackId": 1,
        "authorId": 104,
        "edited": false,
        "deleted": false
      }
    ]
  },
  {
    "feedback": {
      "id": 2,
      "content": "La funcionalidad implementada cumple con los requisitos, pero sugiero mejorar la validación de datos.",
      "createdAt": "2025-10-30T00:29:15.896536Z",
      "updatedAt": null,
      "deliveryId": 1,
      "projectId": null,
      "taskId": null,
      "authorId": 102,
      "edited": false,
      "deleted": false
    },
    "responses": [
      {
        "id": 2,
        "content": "Tienes razón, voy a reforzar las validaciones en la próxima iteración.",
        "createdAt": "2025-10-30T06:29:15.896536Z",
        "updatedAt": null,
        "feedbackId": 2,
        "authorId": 104,
        "edited": false,
        "deleted": false
      },
      {
        "id": 3,
        "content": "He agregado validaciones adicionales para los campos críticos. ¿Podrías revisarlo nuevamente?",
        "createdAt": "2025-11-01T00:29:15.896536Z",
        "updatedAt": null,
        "feedbackId": 2,
        "authorId": 104,
        "edited": false,
        "deleted": false
      }
    ]
  },
  {
    "feedback": {
      "id": 3,
      "content": "Buen diseño de la interfaz, muy intuitiva para el usuario final.",
      "createdAt": "2025-10-31T00:29:15.896536Z",
      "updatedAt": null,
      "deliveryId": 1,
      "projectId": null,
      "taskId": null,
      "authorId": 103,
      "edited": false,
      "deleted": false
    },
    "responses": []
  }
]
```

### Ejemplo 2: Obtener feedbacks del delivery 5

**Request:**
```bash
curl -X GET "http://localhost:8080/api/v1/deliveries/5/feedbacks-with-responses" \
  -H "X-User-Id: 120" \
  -H "X-User-Role: profesor" \
  -H "Content-Type: application/json"
```

**Response:** Retorna 4 feedbacks con sus respuestas asociadas (el delivery 5 tiene 4 feedbacks con 6 respuestas en total)

### Ejemplo 3: Contar feedbacks y respuestas

**Request para contar feedbacks:**
```bash
curl -s "http://localhost:8080/api/v1/deliveries/2/feedbacks-with-responses" \
  -H "X-User-Id: 1" | jq '. | length'
```

**Response:**
```
4
```

**Request para ver estructura de un feedback específico:**
```bash
curl -s "http://localhost:8080/api/v1/deliveries/2/feedbacks-with-responses" \
  -H "X-User-Id: 1" | jq '.[0]'
```

## Notas Importantes

1. **Feedbacks sin respuestas**: Si un feedback no tiene respuestas, el array `responses` estará vacío `[]`

2. **Ordenamiento**: 
   - Los feedbacks se ordenan por `createdAt` ascendente (más antiguos primero)
   - Las respuestas dentro de cada feedback también se ordenan por `createdAt` ascendente

3. **Filtrado**: Solo se retornan feedbacks y respuestas que NO estén marcados como eliminados (`deleted = false`)

4. **Performance**: Este endpoint realiza una consulta por el delivery y luego una consulta por cada feedback para obtener sus respuestas. Para deliveries con muchos feedbacks, considera la paginación.

## Datos de Prueba Disponibles

La base de datos contiene datos de prueba para los siguientes deliveries:

| Delivery ID | Feedbacks | Respuestas Totales |
|-------------|-----------|-------------------|
| 1 | 3 | 3 |
| 2 | 4 | 4 |
| 3 | 3 | 4 |
| 4 | 5 | 5 |
| 5 | 4 | 6 |
| **Total** | **19** | **22** |

## Casos de Uso

Este endpoint es útil para:
- Mostrar todos los comentarios de una entrega en una vista única
- Generar reportes de retroalimentación por entrega
- Exportar comentarios y respuestas de una entrega
- Mostrar un historial completo de comunicación sobre una entrega

## Códigos de Error

| Código | Descripción |
|--------|-------------|
| 200 | Éxito - Retorna array de feedbacks (puede estar vacío) |
| 400 | Bad Request - deliveryId inválido |
| 500 | Error interno del servidor |
