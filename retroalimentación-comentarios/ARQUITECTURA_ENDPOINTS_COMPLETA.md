# 🎓 Arquitectura Completa de Endpoints - Proyecto Estudiantil

## 📋 Índice
1. [Flujos de Usuario](#flujos-de-usuario)
2. [Endpoints Actuales](#endpoints-actuales)
3. [Endpoints Necesarios Adicionales](#endpoints-necesarios-adicionales)
4. [Endpoints para Reportes](#endpoints-para-reportes)
5. [Casos de Uso por Rol](#casos-de-uso-por-rol)

---

## 🎯 Flujos de Usuario

### 👨‍🎓 **Flujo del ESTUDIANTE**
```
1. Estudiante entrega un trabajo (Delivery)
2. Estudiante navega a "Mis Entregas"
3. Estudiante ve su entrega específica
4. Estudiante ve automáticamente todas las retroalimentaciones del profesor
5. Estudiante puede responder a cada retroalimentación
6. Estudiante ve el historial de conversación (feedback + respuestas)
7. Estudiante puede editar/eliminar sus respuestas
```

### 👨‍🏫 **Flujo del PROFESOR**
```
1. Profesor navega a "Entregas Pendientes" o "Todas las Entregas"
2. Profesor selecciona una entrega específica
3. Profesor crea retroalimentación (CRUD completo)
4. Profesor ve respuestas de estudiantes
5. Profesor puede responder a las respuestas (conversación anidada)
6. Profesor puede editar/eliminar sus retroalimentaciones
```

### 📊 **Flujo de TAREAS dentro de ENTREGAS**
```
1. Entrega tiene múltiples tareas
2. Cada tarea puede tener retroalimentaciones independientes
3. Las retroalimentaciones de tareas funcionan igual que las de entregas
4. Se puede navegar: Entrega → Lista de Tareas → Retroalimentaciones por Tarea
```

---

## ✅ Endpoints ACTUALES (14 implementados)

### 📝 **Gestión de Feedbacks**

#### 1. **Listar feedbacks por scope**
```http
GET /api/v1/feedback?deliveryId={id}
GET /api/v1/feedback?taskId={id}
GET /api/v1/feedback?projectId={id}
```
- **Quién:** Estudiantes (ven sus retroalimentaciones), Profesores (ven todas)
- **Uso:** Estudiante ve retroalimentación de SU entrega/tarea/proyecto

#### 2. **Listar TODOS los feedbacks** (Admin)
```http
GET /api/v1/feedback/all
```
- **Quién:** Administradores, Dashboards
- **Uso:** Vista global, reportes, analytics

#### 3. **Crear feedback**
```http
POST /api/v1/feedback
Body: {
  "deliveryId": 1,  // O taskId, O projectId
  "taskId": null,
  "projectId": null,
  "content": "Excelente trabajo..."
}
```
- **Quién:** Profesores principalmente
- **Uso:** Dar retroalimentación a entregas/tareas/proyectos

#### 4. **Actualizar feedback**
```http
PATCH /api/v1/feedback/{id}
Body: {
  "content": "Contenido actualizado..."
}
```
- **Quién:** Autor del feedback (profesor)
- **Uso:** Corregir o ampliar retroalimentación

#### 5. **Eliminar feedback** (Soft delete)
```http
DELETE /api/v1/feedback/{id}
```
- **Quién:** Autor del feedback
- **Uso:** Eliminar retroalimentación inapropiada o incorrecta

---

### 💬 **Gestión de Respuestas**

#### 6. **Listar respuestas de un feedback**
```http
GET /api/v1/feedback/{feedbackId}/responses
```
- **Quién:** Todos (estudiantes y profesores)
- **Uso:** Ver conversación completa de una retroalimentación

#### 7. **Listar TODAS las respuestas** (Admin)
```http
GET /api/v1/feedback-responses/all
```
- **Quién:** Administradores
- **Uso:** Analytics global, métricas de participación

#### 8. **Crear respuesta a feedback**
```http
POST /api/v1/feedback/{feedbackId}/responses
Body: {
  "content": "Gracias por el feedback, ya corregí..."
}
```
- **Quién:** Estudiantes (responden a profesor), Profesores (responden a estudiantes)
- **Uso:** Conversación bidireccional

#### 9. **Actualizar respuesta**
```http
PATCH /api/v1/feedback-responses/{id}
Body: {
  "content": "Respuesta editada..."
}
```
- **Quién:** Autor de la respuesta
- **Uso:** Corregir respuesta

#### 10. **Eliminar respuesta** (Soft delete)
```http
DELETE /api/v1/feedback-responses/{id}
```
- **Quién:** Autor de la respuesta
- **Uso:** Eliminar respuesta inapropiada

---

## 🚀 Endpoints NECESARIOS Adicionales

### 🎓 **Para Navegación del Estudiante**

#### 11. **Ver MI entrega con retroalimentaciones** ⭐ CRÍTICO
```http
GET /api/v1/students/{studentId}/deliveries/{deliveryId}
```
**Response:**
```json
{
  "delivery": {
    "id": 1,
    "title": "Entrega Parcial 1",
    "description": "Backend de autenticación",
    "submittedAt": "2025-11-01T10:00:00Z",
    "studentId": 200,
    "status": "reviewed"
  },
  "feedbacks": [
    {
      "id": 4,
      "content": "Excelente trabajo...",
      "authorId": 100,
      "authorName": "Prof. García",
      "createdAt": "2025-11-03T02:47:14Z",
      "edited": false,
      "responsesCount": 2,
      "responses": [
        {
          "id": 1,
          "content": "Gracias profesor...",
          "authorId": 200,
          "authorName": "Juan Pérez",
          "createdAt": "2025-11-03T02:50:00Z"
        }
      ]
    }
  ],
  "tasks": [
    {
      "id": 1,
      "title": "Implementar JWT",
      "feedbacksCount": 3
    }
  ]
}
```
**Uso:** Estudiante ve su entrega con TODA la conversación automáticamente

---

#### 12. **Listar MIS entregas con contadores** ⭐ CRÍTICO
```http
GET /api/v1/students/{studentId}/deliveries
```
**Response:**
```json
[
  {
    "id": 1,
    "title": "Entrega Parcial 1",
    "submittedAt": "2025-11-01T10:00:00Z",
    "status": "reviewed",
    "feedbacksCount": 5,
    "unreadFeedbacksCount": 2,
    "hasNewResponses": true
  },
  {
    "id": 2,
    "title": "Entrega Final",
    "submittedAt": "2025-11-15T10:00:00Z",
    "status": "pending",
    "feedbacksCount": 0
  }
]
```
**Uso:** Vista principal del estudiante - "Mis Entregas"

---

#### 13. **Ver tarea específica con retroalimentaciones**
```http
GET /api/v1/deliveries/{deliveryId}/tasks/{taskId}
```
**Response:**
```json
{
  "task": {
    "id": 1,
    "deliveryId": 1,
    "title": "Implementar JWT",
    "description": "Crear sistema de autenticación",
    "completed": true
  },
  "feedbacks": [
    {
      "id": 5,
      "content": "Falta validación de errores...",
      "authorId": 100,
      "responses": [...]
    }
  ]
}
```
**Uso:** Navegación: Entrega → Ver tareas → Retroalimentaciones por tarea

---

### 👨‍🏫 **Para el Profesor**

#### 14. **Listar entregas pendientes de revisión** ⭐ CRÍTICO
```http
GET /api/v1/professor/deliveries/pending
```
**Response:**
```json
[
  {
    "id": 3,
    "studentId": 201,
    "studentName": "María López",
    "title": "Entrega Parcial 2",
    "submittedAt": "2025-11-02T15:30:00Z",
    "projectId": 1,
    "projectName": "Sistema de Gestión",
    "feedbacksCount": 0
  }
]
```
**Uso:** Dashboard del profesor - "Entregas sin revisar"

---

#### 15. **Listar todas las entregas (con filtros)**
```http
GET /api/v1/professor/deliveries?status=reviewed&studentId=200&projectId=1
```
**Filtros:** `status` (pending|reviewed|all), `studentId`, `projectId`, `dateFrom`, `dateTo`

**Uso:** Profesor busca entregas específicas

---

#### 16. **Ver entrega de estudiante para revisar** ⭐ CRÍTICO
```http
GET /api/v1/professor/deliveries/{deliveryId}
```
**Response:** (Similar al endpoint #11 pero con más info para el profesor)
```json
{
  "delivery": {
    "id": 1,
    "studentId": 200,
    "studentName": "Juan Pérez",
    "studentEmail": "juan@example.com",
    "title": "Entrega Parcial 1",
    "submittedAt": "2025-11-01T10:00:00Z",
    "files": ["backend.zip"],
    "status": "reviewed"
  },
  "myFeedbacks": [
    {
      "id": 4,
      "content": "Excelente trabajo...",
      "createdAt": "2025-11-03T02:47:14Z",
      "responsesCount": 2
    }
  ],
  "tasks": [...]
}
```
**Uso:** Profesor revisa entrega y da retroalimentación

---

#### 17. **Buscar feedbacks por contenido**
```http
GET /api/v1/feedback/search?query=validación&scope=delivery&scopeId=1
```
**Uso:** Profesor busca retroalimentaciones específicas

---

### 📊 **Endpoints para REPORTES**

#### 18. **Reporte de participación por estudiante** ⭐ CRÍTICO
```http
GET /api/v1/reports/student/{studentId}/engagement
```
**Response:**
```json
{
  "studentId": 200,
  "studentName": "Juan Pérez",
  "period": "2025-Q1",
  "stats": {
    "totalDeliveries": 5,
    "deliveriesWithFeedback": 5,
    "feedbacksReceived": 23,
    "responsesGiven": 18,
    "averageResponseTime": "2 hours",
    "engagementRate": 78.2
  },
  "timeline": [
    {
      "date": "2025-11-01",
      "feedbacksReceived": 3,
      "responsesGiven": 2
    }
  ]
}
```
**Uso:** Reporte individual del estudiante

---

#### 19. **Reporte de actividad del profesor**
```http
GET /api/v1/reports/professor/{professorId}/activity
```
**Response:**
```json
{
  "professorId": 100,
  "professorName": "Prof. García",
  "period": "2025-11",
  "stats": {
    "deliveriesReviewed": 45,
    "feedbacksGiven": 156,
    "averageFeedbackLength": 120,
    "responsesToStudents": 89,
    "averageReviewTime": "4 hours"
  }
}
```
**Uso:** Evaluar carga de trabajo del profesor

---

#### 20. **Reporte global del proyecto**
```http
GET /api/v1/reports/project/{projectId}/overview
```
**Response:**
```json
{
  "projectId": 1,
  "projectName": "Sistema de Gestión",
  "stats": {
    "totalStudents": 30,
    "totalDeliveries": 150,
    "deliveriesReviewed": 145,
    "deliveriesPending": 5,
    "totalFeedbacks": 456,
    "totalResponses": 389,
    "averageResponseRate": 85.3,
    "mostActiveStudents": [
      {"id": 200, "name": "Juan Pérez", "responsesCount": 25}
    ],
    "deliveriesWithoutFeedback": 5
  }
}
```
**Uso:** Dashboard general del proyecto

---

#### 21. **Reporte de feedback por entrega**
```http
GET /api/v1/reports/delivery/{deliveryId}/feedback-summary
```
**Response:**
```json
{
  "deliveryId": 1,
  "deliveryTitle": "Entrega Parcial 1",
  "studentId": 200,
  "stats": {
    "totalFeedbacks": 5,
    "feedbacksByScope": {
      "delivery": 3,
      "tasks": 2
    },
    "totalResponses": 4,
    "conversationThreads": 5,
    "averageResponseTime": "3 hours",
    "lastActivityAt": "2025-11-03T10:00:00Z"
  },
  "feedbackBreakdown": [
    {
      "type": "delivery",
      "count": 3,
      "avgLength": 150
    },
    {
      "type": "task",
      "taskId": 1,
      "taskTitle": "Implementar JWT",
      "count": 2
    }
  ]
}
```
**Uso:** Ver resumen de retroalimentación de una entrega específica

---

#### 22. **Reporte de tendencias temporales**
```http
GET /api/v1/reports/trends?projectId=1&startDate=2025-01-01&endDate=2025-12-31
```
**Response:**
```json
{
  "period": {
    "start": "2025-01-01",
    "end": "2025-12-31"
  },
  "trends": {
    "feedbacksPerWeek": [
      {"week": "2025-W01", "count": 45},
      {"week": "2025-W02", "count": 52}
    ],
    "responsesPerWeek": [...],
    "averageResponseTimePerWeek": [...],
    "engagementRate": [...]
  }
}
```
**Uso:** Ver evolución del proyecto a lo largo del tiempo

---

#### 23. **Reporte de auditoría**
```http
GET /api/v1/reports/audit?entityType=feedback&entityId=19&userId=999
```
**Response:**
```json
{
  "entityType": "feedback",
  "entityId": 19,
  "auditTrail": [
    {
      "id": 1,
      "action": "COMMENT_CREATE",
      "userId": 999,
      "timestamp": "2025-11-03T04:24:23Z",
      "metadata": {"content_preview": "Feedback inicial..."}
    },
    {
      "id": 2,
      "action": "COMMENT_UPDATE",
      "userId": 999,
      "timestamp": "2025-11-03T04:25:41Z",
      "metadata": {"old_content": "...", "new_content": "..."}
    },
    {
      "id": 3,
      "action": "COMMENT_DELETE",
      "userId": 999,
      "timestamp": "2025-11-03T04:26:00Z"
    }
  ]
}
```
**Uso:** Rastrear cambios y acciones sobre feedbacks/respuestas

---

#### 24. **Exportar datos para análisis** (CSV/JSON)
```http
GET /api/v1/reports/export?projectId=1&format=csv&type=feedbacks
GET /api/v1/reports/export?projectId=1&format=json&type=engagement
```
**Uso:** Exportar datos para análisis externo (Excel, Power BI, etc.)

---

## 🎯 Casos de Uso por Rol

### 👨‍🎓 **Estudiante (Usuario 200)**

#### Escenario 1: "Ver mi entrega con retroalimentación"
```
1. GET /api/v1/students/200/deliveries
   → Ve lista: "Entrega Parcial 1 (5 feedbacks)", "Entrega Final (0 feedbacks)"

2. GET /api/v1/students/200/deliveries/1
   → Ve su entrega con TODOS los feedbacks y respuestas automáticamente

3. POST /api/v1/feedback/4/responses
   Body: {"content": "Gracias profesor, ya corregí..."}
   → Responde a la retroalimentación del profesor
```

#### Escenario 2: "Ver retroalimentación de una tarea específica"
```
1. GET /api/v1/students/200/deliveries/1
   → Ve que tiene 3 tareas

2. GET /api/v1/deliveries/1/tasks/1
   → Ve la tarea "Implementar JWT" con sus 2 feedbacks

3. GET /api/v1/feedback?taskId=1
   → Ve feedbacks específicos de esa tarea
```

---

### 👨‍🏫 **Profesor (Usuario 100)**

#### Escenario 1: "Revisar entregas pendientes"
```
1. GET /api/v1/professor/deliveries/pending
   → Ve 5 entregas sin revisar

2. GET /api/v1/professor/deliveries/3
   → Abre entrega de María López

3. POST /api/v1/feedback
   Body: {
     "deliveryId": 3,
     "content": "Excelente trabajo, pero sugiero..."
   }
   → Crea retroalimentación

4. POST /api/v1/feedback
   Body: {
     "taskId": 5,
     "content": "Esta tarea necesita más validaciones..."
   }
   → Crea retroalimentación específica para una tarea
```

#### Escenario 2: "Responder a estudiante"
```
1. GET /api/v1/professor/deliveries/1
   → Ve que el estudiante respondió a su feedback

2. GET /api/v1/feedback/4/responses
   → Ve la respuesta del estudiante

3. POST /api/v1/feedback/4/responses
   Body: {"content": "Perfecto, ahora está mejor..."}
   → Responde al estudiante (conversación continua)
```

#### Escenario 3: "Editar retroalimentación"
```
1. GET /api/v1/feedback?deliveryId=1
   → Ve sus feedbacks anteriores

2. PATCH /api/v1/feedback/4
   Body: {"content": "Actualizo mi retroalimentación..."}
   → Corrige su feedback

3. GET /api/v1/reports/audit?entityId=4
   → Ve historial de cambios (quién editó qué y cuándo)
```

---

### 📊 **Administrador / Coordinador**

#### Escenario 1: "Ver estado general del proyecto"
```
1. GET /api/v1/reports/project/1/overview
   → Dashboard: 30 estudiantes, 145/150 entregas revisadas, 5 pendientes

2. GET /api/v1/reports/trends?projectId=1
   → Ve gráfica de actividad por semana

3. GET /api/v1/reports/export?projectId=1&format=csv
   → Exporta datos para presentación
```

#### Escenario 2: "Identificar estudiantes con bajo engagement"
```
1. GET /api/v1/reports/project/1/overview
   → Ve lista de estudiantes menos activos

2. GET /api/v1/reports/student/205/engagement
   → Ve que tiene 0 respuestas a 8 feedbacks recibidos (engagement 0%)

3. Coordina reunión con el estudiante
```

#### Escenario 3: "Evaluar carga de trabajo del profesor"
```
1. GET /api/v1/reports/professor/100/activity
   → Ve que revisó 45 entregas, 156 feedbacks en el mes

2. Decide asignar ayudante
```

---

## 📊 Resumen de Endpoints por Categoría

### ✅ **YA IMPLEMENTADOS (14)**
- Listar feedbacks por scope (delivery/task/project)
- CRUD completo de feedbacks
- CRUD completo de respuestas
- Listar respuestas por feedback
- Endpoints de administración (/all)

### 🚀 **NECESARIOS PARA ESTUDIANTES (3)**
- **#11** Ver MI entrega con retroalimentaciones
- **#12** Listar MIS entregas con contadores
- **#13** Ver tarea específica con retroalimentaciones

### 🚀 **NECESARIOS PARA PROFESORES (4)**
- **#14** Listar entregas pendientes de revisión
- **#15** Listar todas las entregas (con filtros)
- **#16** Ver entrega de estudiante para revisar
- **#17** Buscar feedbacks por contenido

### 📊 **NECESARIOS PARA REPORTES (7)**
- **#18** Reporte de participación por estudiante
- **#19** Reporte de actividad del profesor
- **#20** Reporte global del proyecto
- **#21** Reporte de feedback por entrega
- **#22** Reporte de tendencias temporales
- **#23** Reporte de auditoría
- **#24** Exportar datos (CSV/JSON)

---

## 🎯 Priorización de Desarrollo

### 🔴 **CRÍTICO (Implementar primero)**
1. **#11** - Ver MI entrega con retroalimentaciones
2. **#12** - Listar MIS entregas
3. **#14** - Listar entregas pendientes (profesor)
4. **#16** - Ver entrega para revisar (profesor)

### 🟡 **IMPORTANTE (Implementar segundo)**
5. **#13** - Ver tarea con retroalimentaciones
6. **#15** - Listar entregas con filtros
7. **#18** - Reporte de participación por estudiante
8. **#20** - Reporte global del proyecto

### 🟢 **NICE TO HAVE (Implementar tercero)**
9. **#17** - Buscar feedbacks
10. **#19** - Reporte de actividad del profesor
11. **#21** - Reporte por entrega
12. **#22** - Tendencias temporales
13. **#23** - Auditoría
14. **#24** - Exportar datos

---

## 💡 Notas de Implementación

### Consideraciones Técnicas:
- Los endpoints de navegación (#11, #12, #13, #16) necesitan **joins** entre tablas
- Los reportes (#18-#24) pueden ser **cacheados** para mejor performance
- Implementar **paginación** en listas largas
- Agregar **filtros de fecha** en todos los endpoints de lista
- Los contadores (`feedbacksCount`, `responsesCount`) pueden ser **campos calculados** o **precalculados**

### Seguridad:
- Endpoint #11, #12: Validar que `studentId` coincide con el usuario autenticado
- Endpoint #14, #15, #16: Solo profesores/admin
- Endpoint #17-#24: Solo admin o profesores (según el alcance)

¿Quieres que implemente alguno de estos endpoints en particular? 🚀
