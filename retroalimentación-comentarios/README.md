# Retroalimentación y Comentarios (Spring Boot)

## Ejecutar en local

1. **Java 21 + Maven Wrapper.**
2. **RabbitMQ (requerido para mensajería):**
   ```bash
   docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
   ```
   Accede a RabbitMQ Management: http://localhost:15672 (guest/guest)
3. **Opcional:** crea un archivo `.env` (se carga automático) con tus overrides.
4. **Arranca:**
   ```
   ./mvnw spring-boot:run
   ```

Defaults ya configurados: conexión a Neon, JWT HS256 y WebSocket CORS `*`.

> 📚 **Documentación detallada:**
> - [EJEMPLOS_API.md](EJEMPLOS_API.md) - Ejemplos de todos los endpoints
> - [CONFIGURACION_RABBITMQ_WEBSOCKET.md](CONFIGURACION_RABBITMQ_WEBSOCKET.md) - Configuración completa de RabbitMQ y WebSocket
> - [PRUEBAS_COMPLETAS.md](PRUEBAS_COMPLETAS.md) - Guía paso a paso de pruebas
> - [test-websocket.html](test-websocket.html) - Página HTML para probar WebSocket en el navegador

## Variables (.env opcional)

- DATABASE_URL_JDBC, DATABASE_USERNAME, DATABASE_PASSWORD
- JWT_SECRET, JWT_EXP_MINUTES
- WS_ALLOWED_ORIGINS

## REST

- GET /api/v1/feedback?projectId|taskId|deliveryId
- POST /api/v1/feedback  body { projectId?, taskId?, deliveryId?, content }
- PATCH /api/v1/feedback/{id}
- DELETE /api/v1/feedback/{id}
- GET /api/v1/feedback/{id}/responses?deliveryId
- POST /api/v1/feedback/{id}/responses  body { content }

Reportes:
- GET /api/v1/reports/student?projectId=
- GET /api/v1/reports/team?teamId=

Auth: Authorization: Bearer <jwt> con claims { sub: "<userId>", role: "profesor|estudiante" }.
Para pruebas sin token, se aceptan headers X-User-Id y X-User-Role.

## WebSocket (STOMP)

- Endpoint: /ws
- Topics:
  - /topic/project/{id}
  - /topic/task/{id}
  - /topic/delivery/{id}
- Eventos: feedback.created|updated|deleted, reply.created|updated|deleted.

## Probar API (Swagger UI)

- Visita [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) después de iniciar la app para explorar/probar el backend vía Swagger.

## Mensajes en tiempo real

- El sistema utiliza **RabbitMQ + WebSocket STOMP** para mensajería en tiempo real:
  - **RabbitMQ**: Colas de mensajes (`feedback.exchange`, `feedback.response.exchange`) para desacoplar productores y consumidores.
  - **WebSocket STOMP**: Los mensajes de RabbitMQ se reenvían automáticamente a clientes WebSocket conectados.
  - Los eventos se publican en RabbitMQ y el servicio `WebSocketMessagingService` los reenvía a los topics STOMP correspondientes.

## Migraciones

- V1__feedback_service.sql: columnas de edición/borrado + audit logs.
- V2__feedback_scope_project_task.sql: soporte de feedback por proyecto/tarea.
- V3__tasks_relation_to_deliveries.sql: refactorización - las tareas ahora se relacionan con entregas (deliveries) en lugar de proyectos (projects).

## Seguridad y auditoría

- JWT HS256; filtros para JWT y fallback por headers en dev.
- Registros de ACCESS_DENIED y acciones CRUD en audit_logs.
