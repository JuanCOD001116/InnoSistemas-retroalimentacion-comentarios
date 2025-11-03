# Copilot Instructions for retroalimentación-comentarios

## Project Overview
Spring Boot 3.5.7 feedback/comments system with real-time messaging for educational project management. Uses Java 21, Maven, PostgreSQL (Neon), RabbitMQ, WebSocket/STOMP, JWT security, Flyway migrations, and PDF reporting.

## Architecture - The Big Picture

### Three-Layer Messaging Flow (Critical to Understand)
1. **HTTP REST** → Controller receives request → Service saves to DB
2. **RabbitMQ** → Service publishes event to exchange → Routes to queue via pattern matching (`feedback.*`, `response.*`)
3. **WebSocket** → `WebSocketMessagingService` consumes queue → Broadcasts to STOMP clients on `/topic/{scope}/{id}`

**Why this matters:** Changes to feedback MUST publish to RabbitMQ using `RabbitTemplate` and `RabbitMQConfig` constants. The `WebSocketMessagingService` is the ONLY active RabbitMQ consumer (NotificationListener is commented out to avoid conflicts).

### Scope-Based Topic Routing
Feedback can be scoped to `deliveryId`, `taskId`, OR `projectId` (mutually exclusive, enforced by DB constraint `chk_feedback_scope`). Topics are determined dynamically:
- Delivery: `/topic/delivery/{id}`
- Task: `/topic/task/{id}` 
- Project: `/topic/project/{id}`

The `WebSocketMessagingService.determineTopic()` method extracts scope from payload to route messages correctly.

## Critical Patterns & Conventions

### 1. Service Layer Event Publishing Pattern
Every CRUD operation in `FeedbackService` follows this pattern:
```java
// Save to DB
Feedback saved = feedbackRepository.save(f);

// Log audit
auditLogService.logAction(userId, "COMMENT_CREATE", "feedback", saved.getId());

// Publish to RabbitMQ with error handling (don't fail transaction)
try {
    rabbitTemplate.convertAndSend(
        RabbitMQConfig.FEEDBACK_EXCHANGE, 
        "feedback.created",  // routing key matches binding pattern
        new WsEvent("feedback.created", saved)
    );
} catch (Exception e) {
    // Log but don't throw - allow DB transaction to succeed
}
```
**Never skip the try-catch** - RabbitMQ failures shouldn't block DB operations.

### 2. Database Schema Evolution Strategy
Migrations use Flyway with idempotent SQL patterns:
```sql
CREATE TABLE IF NOT EXISTS tasks (...);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS id_delivery BIGINT;
ALTER TABLE tasks DROP COLUMN IF EXISTS id_project;
```
**Context:** V3 migration refactored tasks from `project_id` → `id_delivery` relationship. Always write migrations that can run multiple times safely.

### 3. Security Configuration (Currently Disabled)
The codebase has **two security modes**:
- **Production mode:** JWT bearer tokens with RS256/HS256 (`JwtAuthenticationFilter`, `JwtService`)
- **Dev mode (ACTIVE):** All endpoints permit all + `UserIdHeaderFilter` injects dummy principal from `X-User-Id`/`X-User-Role` headers

**Important:** Authorization checks in services are commented out (`// ensureAccessToDelivery()`). When re-enabling:
1. Uncomment checks in `FeedbackService`
2. Enable JWT filter in `SecurityConfig`
3. Implement `AuthorizationService` methods (currently NOOPs)

### 4. Controller Header Extraction Pattern
Controllers use this helper to support both JWT and header-based auth:
```java
private long userId(Principal p, @RequestHeader(value = "X-User-Id", required = false) String userIdHeader) {
    if (userIdHeader != null) return Long.parseLong(userIdHeader);
    if (p != null) return Long.parseLong(p.getName());
    return 1L; // default for testing
}
```

## Developer Workflows

### Local Development Setup - Quick Start (Recommended)
Use automated scripts that handle everything:

**Linux/Mac:**
```bash
./start.sh
```

**Windows:**
```powershell
.\start.ps1
```

These scripts automatically:
- Verify Docker and Java prerequisites
- Start/restart RabbitMQ container
- Launch Spring Boot application
- Display all service URLs

To stop all services:
```bash
./stop.sh    # Linux/Mac
.\stop.ps1   # Windows
```

### Manual Setup (Alternative)
1. **Start RabbitMQ first (mandatory):**
   ```bash
   docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
   ```
   Access management UI: http://localhost:15672 (guest/guest)

2. **Run application:**
   ```bash
   ./mvnw spring-boot:run
   ```

3. **Test endpoints:**
   - Swagger UI: http://localhost:8080/swagger-ui.html
   - WebSocket test: Open `test-websocket.html` in browser
   - Example requests: See `EJEMPLOS_API.md` and `test-endpoints.ps1`

**Common issues:**
- `connection refused 5672` → RabbitMQ not running
- `500 errors on POST` → RabbitMQ not started before app
- WebSocket not receiving → Check RabbitMQ queues have consumers in management UI

### Testing Real-Time Messaging
1. Open `test-websocket.html` in browser
2. Connect to `ws://localhost:8080/ws`
3. Subscribe to `/topic/delivery/123` (replace with actual ID)
4. POST feedback via curl/Postman with `deliveryId=123`
5. Observe message in browser console

**Debugging tips:**
- Check RabbitMQ Management → Queues → `feedback.topic` for message rate
- Look for `[RabbitMQ] Feedback publicado exitosamente` in app logs
- WebSocket service logs as `[WebSocket] Error forwarding...` if routing fails

### Database Migrations
Flyway runs automatically on startup (`spring.flyway.enabled=true`). To create new migration:
1. Add file: `src/main/resources/db/migration/V{N}__description.sql`
2. Use idempotent SQL (`IF NOT EXISTS`, `IF EXISTS`)
3. Never modify existing migrations after deployment
4. Test by running fresh DB: `./mvnw flyway:clean flyway:migrate`

## Integration Points

### External Services
- **PostgreSQL (Neon):** Default config connects to cloud DB (`DB_URL` env var)
- **RabbitMQ:** Required dependency, fails gracefully if unavailable (see error handling pattern)
- **JWT Validation:** Supports both local HS256 secret and remote public key PEM (`JWT_PUBLIC_KEY` env)

### Cross-Component Communication
- **REST → Service:** DTOs validated with `@NotBlank`, `@Valid`
- **Service → RabbitMQ:** JSON serialization via `Jackson2JsonMessageConverter` (configured in `RabbitMQConfig`)
- **RabbitMQ → WebSocket:** `@RabbitListener` in `WebSocketMessagingService` consumes and forwards to `SimpMessagingTemplate`

### Configuration Hierarchy
1. `application.properties` (defaults for dev)
2. `.env` file (loaded automatically if present, overrides properties)
3. Environment variables (highest priority)

**Key configs:**
```properties
spring.rabbitmq.host=${RABBITMQ_HOST:rabbitmq}  # "rabbitmq" for Docker, "localhost" for local
app.websocket.allowed-origins=${WS_ALLOWED_ORIGINS:*}  # Restrict in production
app.security.enabled=${SECURITY_ENABLED:true}  # Currently false for testing
```

## Project-Specific Gotchas

1. **Zero values are normalized to null:** `projectId=0` → `null` in `createFeedback()` to satisfy DB constraint
2. **Soft deletes:** `deleted=true` flag instead of actual deletion (preserves audit trail)
3. **Scope is mutually exclusive:** Cannot have both `taskId` AND `deliveryId` on same feedback
4. **Response routing:** Uses parent feedback's scope to determine WebSocket topic (see `determineTopicForResponse()`)
5. **PDF reports:** Use OpenHTMLToPDF + PDFBox, templates are HTML strings in `PdfService` (not external files)

## Adding New Features

### New REST Endpoint
1. Add method to appropriate controller (`FeedbackController`, `ReportController`)
2. Create service method with business logic
3. Add `@Operation` annotation for Swagger docs
4. Update `EJEMPLOS_API.md` with curl example

### New Event Type
1. Define routing key pattern (e.g., `comment.liked`)
2. Update binding in `RabbitMQConfig` if needed
3. Publish with `rabbitTemplate.convertAndSend(EXCHANGE, "comment.liked", new WsEvent(...))`
4. `WebSocketMessagingService` already handles forwarding automatically

### New Database Table
1. Create V{N} migration with `CREATE TABLE IF NOT EXISTS`
2. Add JPA entity in `domain/` package
3. Create Spring Data repository interface
4. Remember to add `created_at`, `updated_at` for audit consistency

## Key Files Reference
- **Entry point:** `RetroalimentacionYComentariosApplication.java`
- **Main API:** `FeedbackController.java` (all CRUD endpoints)
- **Event flow:** `FeedbackService.java` → `RabbitMQConfig.java` → `WebSocketMessagingService.java`
- **Security:** `SecurityConfig.java` (currently permissive), `UserIdHeaderFilter.java` (dev auth)
- **DB schema:** `src/main/resources/db/migration/V*.sql`
- **Config:** `application.properties`, `RabbitMQConfig.java`, `WebSocketConfig.java`

## Documentation
Comprehensive docs exist in project root - reference these for detailed examples:
- `EJEMPLOS_API.md` - Complete API request/response examples
- `CONFIGURACION_RABBITMQ_WEBSOCKET.md` - RabbitMQ and WebSocket setup details
- `GUIA_EJECUCION_PASO_A_PASO.md` - Step-by-step execution guide
- `PRUEBAS_COMPLETAS.md` - Full testing scenarios
- `DIAGNOSTICO_RABBITMQ.md` - Troubleshooting guide
