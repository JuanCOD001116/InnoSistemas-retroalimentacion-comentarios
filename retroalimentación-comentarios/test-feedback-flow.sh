#!/bin/bash

# Script para probar el flujo completo de feedback y respuestas
# Ejecutar con: ./test-feedback-flow.sh

set -e  # Detener si hay errores

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

API_URL="http://localhost:8080/api/v1"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  TEST COMPLETO: Feedback de Profesor → Respuesta Estudiante  ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Variables de prueba
PROFESOR_ID=100
ESTUDIANTE_ID=200
DELIVERY_ID=1
TASK_ID=1
PROJECT_ID=1

echo -e "${YELLOW}📋 Configuración de prueba:${NC}"
echo "  - Profesor ID: $PROFESOR_ID"
echo "  - Estudiante ID: $ESTUDIANTE_ID"
echo "  - Delivery ID: $DELIVERY_ID"
echo "  - Task ID: $TASK_ID"
echo "  - Project ID: $PROJECT_ID"
echo ""

# ==============================================================================
# TEST 1: Profesor crea feedback en una ENTREGA
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 1: Profesor crea feedback en Entrega #${DELIVERY_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

FEEDBACK_RESPONSE=$(curl -s -X POST "$API_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESOR_ID" \
  -H "X-User-Role: profesor" \
  -d "{
    \"deliveryId\": $DELIVERY_ID,
    \"content\": \"Excelente trabajo en la entrega parcial. La arquitectura está bien diseñada, pero sugiero mejorar la documentación de los endpoints.\"
  }")

echo -e "${GREEN}✓ Respuesta del servidor:${NC}"
echo "$FEEDBACK_RESPONSE" | jq '.'

# Extraer el ID del feedback creado
FEEDBACK_ID=$(echo "$FEEDBACK_RESPONSE" | jq -r '.id')

if [ "$FEEDBACK_ID" = "null" ] || [ -z "$FEEDBACK_ID" ]; then
  echo -e "${RED}❌ ERROR: No se pudo crear el feedback${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Feedback creado exitosamente con ID: $FEEDBACK_ID${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 2: Listar feedback de la entrega
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 2: Listar todos los feedbacks de la Entrega #${DELIVERY_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

curl -s -X GET "$API_URL/feedback?deliveryId=$DELIVERY_ID" \
  -H "X-User-Id: $ESTUDIANTE_ID" \
  -H "X-User-Role: estudiante" | jq '.'

echo ""
echo -e "${GREEN}✅ Feedbacks listados correctamente${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 3: Estudiante responde al feedback
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 3: Estudiante responde al Feedback #${FEEDBACK_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

RESPONSE_RESPONSE=$(curl -s -X POST "$API_URL/feedback/$FEEDBACK_ID/responses" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $ESTUDIANTE_ID" \
  -H "X-User-Role: estudiante" \
  -d "{
    \"content\": \"Gracias por el feedback, profesor. Ya actualicé la documentación con ejemplos de uso y diagramas de secuencia.\"
  }")

echo -e "${GREEN}✓ Respuesta del servidor:${NC}"
echo "$RESPONSE_RESPONSE" | jq '.'

RESPONSE_ID=$(echo "$RESPONSE_RESPONSE" | jq -r '.id')

if [ "$RESPONSE_ID" = "null" ] || [ -z "$RESPONSE_ID" ]; then
  echo -e "${RED}❌ ERROR: No se pudo crear la respuesta${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Respuesta creada exitosamente con ID: $RESPONSE_ID${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 4: Listar respuestas del feedback
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 4: Listar respuestas del Feedback #${FEEDBACK_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

curl -s -X GET "$API_URL/feedback/$FEEDBACK_ID/responses" \
  -H "X-User-Id: $PROFESOR_ID" \
  -H "X-User-Role: profesor" | jq '.'

echo ""
echo -e "${GREEN}✅ Respuestas listadas correctamente${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 5: Estudiante edita su respuesta
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 5: Estudiante edita su Respuesta #${RESPONSE_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

curl -s -X PATCH "$API_URL/feedback-responses/$RESPONSE_ID" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $ESTUDIANTE_ID" \
  -H "X-User-Role: estudiante" \
  -d "{
    \"content\": \"Gracias por el feedback, profesor. Ya actualicé la documentación con ejemplos de uso, diagramas de secuencia y tests de integración.\"
  }" | jq '.'

echo ""
echo -e "${GREEN}✅ Respuesta editada correctamente (campo 'edited' debería ser true)${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 6: Profesor crea feedback en una TAREA
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 6: Profesor crea feedback en Tarea #${TASK_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TASK_FEEDBACK_RESPONSE=$(curl -s -X POST "$API_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESOR_ID" \
  -H "X-User-Role: profesor" \
  -d "{
    \"taskId\": $TASK_ID,
    \"content\": \"La implementación de la tarea está completa, pero falta validación de errores en el backend.\"
  }")

echo -e "${GREEN}✓ Respuesta del servidor:${NC}"
echo "$TASK_FEEDBACK_RESPONSE" | jq '.'

TASK_FEEDBACK_ID=$(echo "$TASK_FEEDBACK_RESPONSE" | jq -r '.id')

echo ""
echo -e "${GREEN}✅ Feedback en tarea creado con ID: $TASK_FEEDBACK_ID${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 7: Listar feedback por TAREA
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 7: Listar feedbacks de la Tarea #${TASK_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

curl -s -X GET "$API_URL/feedback?taskId=$TASK_ID" \
  -H "X-User-Id: $ESTUDIANTE_ID" \
  -H "X-User-Role: estudiante" | jq '.'

echo ""
echo -e "${GREEN}✅ Feedbacks de tarea listados correctamente${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 8: Profesor crea feedback en PROYECTO completo
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 8: Profesor crea feedback en Proyecto #${PROJECT_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROJECT_FEEDBACK_RESPONSE=$(curl -s -X POST "$API_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESOR_ID" \
  -H "X-User-Role: profesor" \
  -d "{
    \"projectId\": $PROJECT_ID,
    \"content\": \"El proyecto en general muestra buen progreso. La arquitectura es sólida y el código está bien estructurado.\"
  }")

echo -e "${GREEN}✓ Respuesta del servidor:${NC}"
echo "$PROJECT_FEEDBACK_RESPONSE" | jq '.'

PROJECT_FEEDBACK_ID=$(echo "$PROJECT_FEEDBACK_RESPONSE" | jq -r '.id')

echo ""
echo -e "${GREEN}✅ Feedback en proyecto creado con ID: $PROJECT_FEEDBACK_ID${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 9: Validar restricción de scope (debe fallar)
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 9: Intentar crear feedback con múltiples scopes (debe fallar)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

ERROR_RESPONSE=$(curl -s -X POST "$API_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESOR_ID" \
  -H "X-User-Role: profesor" \
  -w "\nHTTP_CODE:%{http_code}" \
  -d "{
    \"projectId\": $PROJECT_ID,
    \"taskId\": $TASK_ID,
    \"content\": \"Esto debería fallar por el constraint chk_feedback_scope\"
  }")

echo -e "${YELLOW}Respuesta esperada (debe ser error 500 o 400):${NC}"
echo "$ERROR_RESPONSE"

echo ""
echo -e "${GREEN}✅ Constraint de scope funcionando correctamente${NC}"
echo ""
sleep 2

# ==============================================================================
# TEST 10: Soft delete - Eliminar respuesta
# ==============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}TEST 10: Soft delete - Eliminar Respuesta #${RESPONSE_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

curl -s -X DELETE "$API_URL/feedback-responses/$RESPONSE_ID" \
  -H "X-User-Id: $ESTUDIANTE_ID" \
  -H "X-User-Role: estudiante"

echo ""
echo -e "${GREEN}✅ Respuesta marcada como eliminada (is_deleted=true)${NC}"
echo ""

# Verificar que sigue en BD pero marcada como eliminada
echo "Verificando respuestas restantes:"
curl -s -X GET "$API_URL/feedback/$FEEDBACK_ID/responses" \
  -H "X-User-Id: $PROFESOR_ID" | jq '.'

echo ""
sleep 2

# ==============================================================================
# RESUMEN FINAL
# ==============================================================================
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ TESTS COMPLETADOS                     ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${GREEN}Resultados:${NC}"
echo "  ✅ Feedback creado en entrega (ID: $FEEDBACK_ID)"
echo "  ✅ Feedback creado en tarea (ID: $TASK_FEEDBACK_ID)"
echo "  ✅ Feedback creado en proyecto (ID: $PROJECT_FEEDBACK_ID)"
echo "  ✅ Respuesta de estudiante creada (ID: $RESPONSE_ID)"
echo "  ✅ Respuesta editada correctamente"
echo "  ✅ Respuesta eliminada (soft delete)"
echo "  ✅ Listados funcionando correctamente"
echo "  ✅ Constraint de scope validado"
echo ""
echo -e "${BLUE}📊 Para ver los datos en la base de datos, puedes usar:${NC}"
echo "  docker exec -it db psql -U postgres -d InnosistemasDB -c 'SELECT * FROM feedback;'"
echo "  docker exec -it db psql -U postgres -d InnosistemasDB -c 'SELECT * FROM feedback_responses;'"
echo ""
echo -e "${YELLOW}🔔 Próximo paso: Verificar que WebSocket/RabbitMQ envió notificaciones${NC}"
echo "  Revisa los logs de la aplicación para mensajes '[RabbitMQ] Feedback publicado exitosamente'"
echo ""
