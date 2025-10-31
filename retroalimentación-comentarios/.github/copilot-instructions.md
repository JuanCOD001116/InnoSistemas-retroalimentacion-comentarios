# Copilot Instructions for retroalimentación-comentarios

## Project Overview
- Spring Boot 3.5, Java 21, Maven, PostgreSQL, RabbitMQ, Flyway, JWT, WebSocket (STOMP), Swagger/OpenAPI.
- REST API for feedback, responses, and reports. Real-time events via RabbitMQ and WebSocket topics.
- Security: JWT bearer tokens (HS256 by default), fallback to X-User-Id/X-User-Role headers in dev.
- Audit logging for CRUD and access denied events.

## Key Conventions
- Main package: `com.inosistemas.retroalimentacion.y.comentarios`.
- REST endpoints: `/api/v1/feedback`, `/api/v1/reports`, etc. (see `FeedbackController`, `ReportController`).
- WebSocket endpoint: `/ws`, topics: `/topic/project/{id}`, `/topic/task/{id}`, `/topic/delivery/{id}`.
- Use `Authorization: Bearer <jwt>` with claims `{ sub: "<userId>", role: "profesor|estudiante" }`.
- For local/dev, X-User-Id and X-User-Role headers are accepted.
- RabbitMQ queues: `feedback.topic`, `feedback.response` (see `NotificationListener`).
- DB migrations: Flyway, scripts in `src/main/resources/db/migration`.
- PDF reports: see `ReportController`, `PdfService`.

## Architecture
- Controllers: REST endpoints, input validation, principal extraction.
- Services: business logic, authorization, audit, event publishing.
- Security: JWT filter (`JwtAuthenticationFilter`), fallback header filter (`UserIdHeaderFilter`), config in `SecurityConfig`.
- Repositories: Spring Data JPA for PostgreSQL.
- Config: `application.properties`, `.env` (optional, auto-loaded).

## AI Agent Guidelines
- Follow existing REST/resource patterns and naming.
- Use DTOs/records for request/response bodies.
- Validate input with Jakarta annotations.
- Use service layer for business logic, not controllers.
- Publish events to RabbitMQ for feedback/response changes.
- Log actions and access denied in `AuditLogService`.
- Keep migrations idempotent and additive.
- Document new endpoints in README.md.

## Testing
- Use Swagger UI at `/swagger-ui.html` for manual API testing.
- Use Postman or curl for JWT-protected endpoints.
- For WebSocket, use STOMP clients (e.g., WebSocket King, browser plugins).

## References
- See `README.md` for usage, environment, and endpoint details.
- See `application.properties` for config keys and defaults.
- See `FeedbackController`, `ReportController`, `SecurityConfig`, `NotificationListener` for main flows.
