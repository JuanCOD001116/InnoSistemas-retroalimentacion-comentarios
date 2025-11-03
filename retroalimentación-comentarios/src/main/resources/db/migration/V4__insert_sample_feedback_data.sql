-- Insert sample feedback and responses for deliveries 1-5
-- This migration populates the database with test data
-- ==============================================
-- 1. Insert feedback for delivery_id = 1
-- ==============================================
INSERT INTO feedback (
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    'Excelente trabajo en esta entrega. El código está bien estructurado y documentado.',
    101,
    1,
    NOW() - INTERVAL '5 days',
    FALSE,
    FALSE
  ),
  (
    'La funcionalidad implementada cumple con los requisitos, pero sugiero mejorar la validación de datos.',
    102,
    1,
    NOW() - INTERVAL '4 days',
    FALSE,
    FALSE
  ),
  (
    'Buen diseño de la interfaz, muy intuitiva para el usuario final.',
    103,
    1,
    NOW() - INTERVAL '3 days',
    FALSE,
    FALSE
  );
-- Insert responses for feedback on delivery 1
INSERT INTO feedback_responses (
    feedback_id,
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    1,
    'Gracias por el feedback positivo. Me alegra que te haya gustado la estructura del código.',
    104,
    1,
    NOW() - INTERVAL '4 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    2,
    'Tienes razón, voy a reforzar las validaciones en la próxima iteración.',
    104,
    1,
    NOW() - INTERVAL '3 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    2,
    'He agregado validaciones adicionales para los campos críticos. ¿Podrías revisarlo nuevamente?',
    104,
    1,
    NOW() - INTERVAL '2 days',
    FALSE,
    FALSE
  );
-- ==============================================
-- 2. Insert feedback for delivery_id = 2
-- ==============================================
INSERT INTO feedback (
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    'La integración con la API externa funciona correctamente. Muy buen trabajo.',
    105,
    2,
    NOW() - INTERVAL '6 days',
    FALSE,
    FALSE
  ),
  (
    'Encontré algunos problemas de performance en la carga de datos. Necesita optimización.',
    106,
    2,
    NOW() - INTERVAL '5 days 6 hours',
    FALSE,
    FALSE
  ),
  (
    'El manejo de errores está incompleto. Faltan casos edge que deben ser contemplados.',
    107,
    2,
    NOW() - INTERVAL '4 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    'La documentación de la API está excelente, muy clara y con buenos ejemplos.',
    108,
    2,
    NOW() - INTERVAL '3 days',
    FALSE,
    FALSE
  );
-- Insert responses for feedback on delivery 2
INSERT INTO feedback_responses (
    feedback_id,
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    4,
    'Muchas gracias! Fue un desafío pero logramos que funcionara de manera estable.',
    109,
    2,
    NOW() - INTERVAL '5 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    5,
    'Implementé un sistema de caché para mejorar la performance. Los tiempos de carga se redujeron en un 60%.',
    109,
    2,
    NOW() - INTERVAL '4 days',
    FALSE,
    FALSE
  ),
  (
    6,
    'Agregué manejo de errores para todos los casos edge que mencionaste. Gracias por señalarlo.',
    109,
    2,
    NOW() - INTERVAL '3 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    7,
    'Me esforcé en que la documentación fuera lo más clara posible. Me alegra que te sirva.',
    109,
    2,
    NOW() - INTERVAL '2 days 12 hours',
    FALSE,
    FALSE
  );
-- ==============================================
-- 3. Insert feedback for delivery_id = 3
-- ==============================================
INSERT INTO feedback (
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    'El módulo de autenticación tiene vulnerabilidades de seguridad que deben ser corregidas urgentemente.',
    110,
    3,
    NOW() - INTERVAL '7 days',
    FALSE,
    FALSE
  ),
  (
    'La experiencia de usuario en móviles necesita mejoras. La interfaz no es responsive.',
    111,
    3,
    NOW() - INTERVAL '6 days 6 hours',
    FALSE,
    FALSE
  ),
  (
    'El código sigue las mejores prácticas y es fácil de mantener. ¡Excelente trabajo!',
    112,
    3,
    NOW() - INTERVAL '5 days',
    FALSE,
    FALSE
  );
-- Insert responses for feedback on delivery 3
INSERT INTO feedback_responses (
    feedback_id,
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    8,
    'Tienes razón, implementé autenticación JWT y agregué validación de tokens. ¿Podrías revisar los cambios?',
    113,
    3,
    NOW() - INTERVAL '6 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    8,
    'Actualicé también el cifrado de contraseñas a bcrypt con salt. Ahora está mucho más seguro.',
    113,
    3,
    NOW() - INTERVAL '5 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    9,
    'Apliqué media queries y flexbox para que la interfaz sea completamente responsive. Probado en varios dispositivos.',
    113,
    3,
    NOW() - INTERVAL '5 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    10,
    'Gracias! Me aseguré de seguir los estándares y documentar bien cada función.',
    113,
    3,
    NOW() - INTERVAL '4 days 18 hours',
    FALSE,
    FALSE
  );
-- ==============================================
-- 4. Insert feedback for delivery_id = 4
-- ==============================================
INSERT INTO feedback (
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    'Los tests unitarios tienen buena cobertura, pero faltan tests de integración.',
    114,
    4,
    NOW() - INTERVAL '8 days',
    FALSE,
    FALSE
  ),
  (
    'El deployment automático funciona perfectamente. Gran configuración de CI/CD.',
    115,
    4,
    NOW() - INTERVAL '7 days 6 hours',
    FALSE,
    FALSE
  ),
  (
    'Hay código duplicado en varios módulos que debería ser refactorizado.',
    116,
    4,
    NOW() - INTERVAL '6 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    'La base de datos está bien normalizada y optimizada. Buen diseño del esquema.',
    117,
    4,
    NOW() - INTERVAL '5 days',
    FALSE,
    FALSE
  ),
  (
    'Sugiero agregar logs más detallados para facilitar el debugging en producción.',
    118,
    4,
    NOW() - INTERVAL '4 days',
    FALSE,
    FALSE
  );
-- Insert responses for feedback on delivery 4
INSERT INTO feedback_responses (
    feedback_id,
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    11,
    'Tienes razón, voy a crear tests de integración para los flujos principales esta semana.',
    119,
    4,
    NOW() - INTERVAL '7 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    12,
    'Gracias! Me tomó tiempo configurarlo pero ahora el proceso de deployment es muy fluido.',
    119,
    4,
    NOW() - INTERVAL '7 days',
    FALSE,
    FALSE
  ),
  (
    13,
    'Identifiqué los bloques duplicados y los moví a utilidades compartidas. El código quedó más limpio.',
    119,
    4,
    NOW() - INTERVAL '6 days',
    FALSE,
    FALSE
  ),
  (
    14,
    'Gracias! Apliqué normalización hasta 3NF y agregué índices en las consultas frecuentes.',
    119,
    4,
    NOW() - INTERVAL '4 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    15,
    'Implementé un sistema de logging estructurado con diferentes niveles. Ahora es más fácil rastrear problemas.',
    119,
    4,
    NOW() - INTERVAL '3 days 12 hours',
    FALSE,
    FALSE
  );
-- ==============================================
-- 5. Insert feedback for delivery_id = 5
-- ==============================================
INSERT INTO feedback (
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    'El rendimiento del sistema ha mejorado significativamente con las optimizaciones aplicadas.',
    120,
    5,
    NOW() - INTERVAL '9 days',
    FALSE,
    FALSE
  ),
  (
    'Falta documentación técnica sobre la arquitectura del sistema.',
    121,
    5,
    NOW() - INTERVAL '8 days 6 hours',
    FALSE,
    FALSE
  ),
  (
    'La API REST está bien diseñada siguiendo principios RESTful. Muy profesional.',
    122,
    5,
    NOW() - INTERVAL '7 days',
    FALSE,
    FALSE
  ),
  (
    'Necesitamos agregar validación de permisos en algunos endpoints que están expuestos.',
    123,
    5,
    NOW() - INTERVAL '6 days',
    FALSE,
    FALSE
  );
-- Insert responses for feedback on delivery 5
INSERT INTO feedback_responses (
    feedback_id,
    content,
    author_id,
    delivery_id,
    created_at,
    edited,
    is_deleted
  )
VALUES (
    16,
    'Me alegra que notes la mejora! Apliqué caching, optimización de queries y lazy loading.',
    124,
    5,
    NOW() - INTERVAL '8 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    17,
    'Voy a crear diagramas de arquitectura y documentación detallada de cada componente.',
    124,
    5,
    NOW() - INTERVAL '8 days',
    FALSE,
    FALSE
  ),
  (
    17,
    'Ya está lista la documentación con diagramas C4, descripción de patrones y guías de desarrollo.',
    124,
    5,
    NOW() - INTERVAL '6 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    18,
    'Gracias! Me aseguré de que cada recurso tenga su URI única y los métodos HTTP sean semánticos.',
    124,
    5,
    NOW() - INTERVAL '6 days 18 hours',
    FALSE,
    FALSE
  ),
  (
    19,
    'Implementé un sistema de roles y permisos con Spring Security. Todos los endpoints están protegidos ahora.',
    124,
    5,
    NOW() - INTERVAL '5 days 12 hours',
    FALSE,
    FALSE
  ),
  (
    19,
    'Agregué también rate limiting para prevenir abusos en la API.',
    124,
    5,
    NOW() - INTERVAL '5 days',
    FALSE,
    FALSE
  );
-- ==============================================
-- Summary of inserted data
-- ==============================================
-- Delivery 1: 3 feedbacks, 3 responses
-- Delivery 2: 4 feedbacks, 4 responses
-- Delivery 3: 3 feedbacks, 4 responses
-- Delivery 4: 5 feedbacks, 5 responses
-- Delivery 5: 4 feedbacks, 6 responses
-- TOTAL: 19 feedbacks, 22 responses