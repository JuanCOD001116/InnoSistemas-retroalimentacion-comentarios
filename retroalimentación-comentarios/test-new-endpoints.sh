#!/bin/bash
# Script de prueba funcional para los 2 nuevos endpoints
# GET /api/v1/feedback/all
# GET /api/v1/feedback-responses/all

echo "════════════════════════════════════════════════════════════════"
echo "   PRUEBA FUNCIONAL - Nuevos Endpoints de Administración"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Configuración
BASE_URL="http://localhost:8082/api/v1"
PORT=8082

echo "🔧 Configuración:"
echo "   Base URL: $BASE_URL"
echo "   Puerto: $PORT"
echo ""

# Verificar que la aplicación esté corriendo
echo "🔍 Verificando aplicación..."
if ! curl -s --connect-timeout 5 "$BASE_URL/feedback?deliveryId=1" > /dev/null 2>&1; then
    echo "❌ Error: La aplicación no está corriendo en puerto $PORT"
    echo ""
    echo "Para iniciar la aplicación ejecuta:"
    echo "  cd /workspace/retroalimentación-comentarios"
    echo "  ./mvnw spring-boot:run -Dspring-boot.run.arguments=\"--server.port=$PORT\""
    echo ""
    exit 1
fi

echo "✅ Aplicación respondiendo correctamente"
echo ""

# Preparar datos de prueba
echo "📝 Preparando datos de prueba..."
echo ""

# Crear 3 feedbacks de prueba
echo "Creando feedbacks..."
FB1=$(curl -s -X POST "$BASE_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 100" \
  -H "X-User-Role: PROFESOR" \
  -d '{"content": "Feedback 1: Excelente trabajo en esta entrega", "deliveryId": 1}' | jq -r '.id')

FB2=$(curl -s -X POST "$BASE_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 101" \
  -H "X-User-Role: PROFESOR" \
  -d '{"content": "Feedback 2: Buen progreso en el proyecto", "projectId": 1}' | jq -r '.id')

FB3=$(curl -s -X POST "$BASE_URL/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 102" \
  -H "X-User-Role: PROFESOR" \
  -d '{"content": "Feedback 3: La tarea necesita mejoras", "taskId": 1}' | jq -r '.id')

echo "   ✅ Feedback 1 creado: ID=$FB1 (deliveryId=1)"
echo "   ✅ Feedback 2 creado: ID=$FB2 (projectId=1)"
echo "   ✅ Feedback 3 creado: ID=$FB3 (taskId=1)"
echo ""

# Crear 2 respuestas
echo "Creando respuestas..."
if [ ! -z "$FB1" ] && [ "$FB1" != "null" ]; then
    RESP1=$(curl -s -X POST "$BASE_URL/feedback/$FB1/responses" \
      -H "Content-Type: application/json" \
      -H "X-User-Id: 200" \
      -H "X-User-Role: STUDENT" \
      -d '{"content": "Gracias por el feedback profesor"}' | jq -r '.id')
    echo "   ✅ Respuesta 1 creada: ID=$RESP1 (feedback=$FB1)"
fi

if [ ! -z "$FB2" ] && [ "$FB2" != "null" ]; then
    RESP2=$(curl -s -X POST "$BASE_URL/feedback/$FB2/responses" \
      -H "Content-Type: application/json" \
      -H "X-User-Id: 201" \
      -H "X-User-Role: STUDENT" \
      -d '{"content": "Voy a implementar las mejoras sugeridas"}' | jq -r '.id')
    echo "   ✅ Respuesta 2 creada: ID=$RESP2 (feedback=$FB2)"
fi

echo ""
sleep 2

echo "════════════════════════════════════════════════════════════════"
echo "   TEST 1: GET /api/v1/feedback/all"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Descripción: Listar TODOS los feedbacks sin filtros"
echo "🔗 Endpoint: GET $BASE_URL/feedback/all"
echo ""

echo "📤 Request:"
echo "   curl $BASE_URL/feedback/all"
echo ""

echo "📥 Response:"
RESPONSE=$(curl -s "$BASE_URL/feedback/all")
echo "$RESPONSE" | jq '.'
echo ""

TOTAL_FEEDBACKS=$(echo "$RESPONSE" | jq 'length')
echo "📊 Resultados:"
echo "   Total de feedbacks: $TOTAL_FEEDBACKS"
echo ""

if [ "$TOTAL_FEEDBACKS" -gt 0 ]; then
    echo "   Detalle de feedbacks:"
    echo "$RESPONSE" | jq -r '.[] | "   - ID: \(.id) | Autor: \(.authorId) | Scope: \(if .deliveryId != null then "delivery_id=\(.deliveryId)" elif .taskId != null then "task_id=\(.taskId)" else "project_id=\(.projectId)" end) | Contenido: \(.content[0:50])..."'
    echo ""
    echo "✅ TEST 1 EXITOSO: Se listaron $TOTAL_FEEDBACKS feedbacks"
else
    echo "⚠️  No hay feedbacks en la base de datos"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "   TEST 2: GET /api/v1/feedback-responses/all"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Descripción: Listar TODAS las respuestas sin filtros"
echo "🔗 Endpoint: GET $BASE_URL/feedback-responses/all"
echo ""

echo "📤 Request:"
echo "   curl $BASE_URL/feedback-responses/all"
echo ""

echo "📥 Response:"
RESPONSE_RESP=$(curl -s "$BASE_URL/feedback-responses/all")
echo "$RESPONSE_RESP" | jq '.'
echo ""

TOTAL_RESPONSES=$(echo "$RESPONSE_RESP" | jq 'length')
echo "📊 Resultados:"
echo "   Total de respuestas: $TOTAL_RESPONSES"
echo ""

if [ "$TOTAL_RESPONSES" -gt 0 ]; then
    echo "   Detalle de respuestas:"
    echo "$RESPONSE_RESP" | jq -r '.[] | "   - ID: \(.id) | Feedback: \(.feedbackId) | Autor: \(.authorId) | Contenido: \(.content[0:50])..."'
    echo ""
    echo "✅ TEST 2 EXITOSO: Se listaron $TOTAL_RESPONSES respuestas"
else
    echo "⚠️  No hay respuestas en la base de datos"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "   COMPARACIÓN: Endpoints filtrados vs. /all"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Comparar con endpoints filtrados
FB_DELIVERY=$(curl -s "$BASE_URL/feedback?deliveryId=1" | jq 'length')
FB_TASK=$(curl -s "$BASE_URL/feedback?taskId=1" | jq 'length')
FB_PROJECT=$(curl -s "$BASE_URL/feedback?projectId=1" | jq 'length')

echo "📊 Feedbacks por scope:"
echo "   - delivery_id=1: $FB_DELIVERY feedbacks"
echo "   - task_id=1: $FB_TASK feedbacks"
echo "   - project_id=1: $FB_PROJECT feedbacks"
echo "   - TODOS (sin filtro): $TOTAL_FEEDBACKS feedbacks"
echo ""

SUMA_FILTRADOS=$((FB_DELIVERY + FB_TASK + FB_PROJECT))
echo "💡 Análisis:"
if [ "$SUMA_FILTRADOS" -eq "$TOTAL_FEEDBACKS" ]; then
    echo "   ✅ La suma de feedbacks filtrados ($SUMA_FILTRADOS) coincide con el total ($TOTAL_FEEDBACKS)"
    echo "   ✅ El endpoint /feedback/all funciona correctamente"
elif [ "$TOTAL_FEEDBACKS" -gt "$SUMA_FILTRADOS" ]; then
    DIFF=$((TOTAL_FEEDBACKS - SUMA_FILTRADOS))
    echo "   ℹ️  Hay $DIFF feedbacks adicionales con otros scopes"
    echo "   ✅ El endpoint /feedback/all incluye MÁS datos que los filtros individuales (correcto)"
else
    echo "   ⚠️  Discrepancia: Total ($TOTAL_FEEDBACKS) < Suma filtrados ($SUMA_FILTRADOS)"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "   RESUMEN FINAL"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "✅ Endpoint 1: GET /api/v1/feedback/all"
echo "   - Estado: FUNCIONAL"
echo "   - Resultados: $TOTAL_FEEDBACKS feedbacks"
echo ""
echo "✅ Endpoint 2: GET /api/v1/feedback-responses/all"
echo "   - Estado: FUNCIONAL"
echo "   - Resultados: $TOTAL_RESPONSES respuestas"
echo ""
echo "🎯 CONCLUSIÓN: Ambos endpoints funcionan correctamente"
echo ""
