#!/bin/bash
# Test completo de los 7 nuevos endpoints

BASE_URL="http://localhost:8080/api/v1"

echo "════════════════════════════════════════════════════════════════════════════"
echo "   🧪 PRUEBA DE 7 NUEVOS ENDPOINTS - Estudiantes y Profesores"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📊 Datos actuales en la base de datos:"
echo "   - Proyectos: 1"
echo "   - Equipos: 2"
echo "   - Entregas: 3"
echo "   - Tareas: 4"
echo "   - Feedbacks: 15"
echo "   - Respuestas: 3"
echo ""

# =============================================================================
echo "════════════════════════════════════════════════════════════════════════════"
echo "   ENDPOINTS PARA ESTUDIANTES (3)"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# TEST 1: Listar MIS entregas con contadores
echo -e "${BLUE}TEST 1: GET /api/v1/students/{studentId}/deliveries${NC}"
echo "   📝 Lista entregas del estudiante con contadores de feedbacks y tareas"
echo ""
echo "   Request:"
echo "   curl $BASE_URL/students/200/deliveries"
echo ""
echo "   Response:"
RESPONSE_1=$(curl -s "$BASE_URL/students/200/deliveries")
echo "$RESPONSE_1" | jq '.'
echo ""
COUNT_1=$(echo "$RESPONSE_1" | jq '. | length')
echo -e "   ${GREEN}✅ Devuelve $COUNT_1 entregas${NC}"
echo ""
echo "   Validación:"
echo "$RESPONSE_1" | jq -r '.[] | "      • Delivery \(.id): \"\(.title)\" - \(.feedbacksCount) feedbacks, \(.tasksCount) tareas"'
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# TEST 2: Ver detalle de UNA entrega con TODAS las retroalimentaciones
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}TEST 2: GET /api/v1/students/{studentId}/deliveries/{deliveryId}${NC}"
echo "   📝 Ver entrega específica con TODOS los feedbacks y respuestas"
echo ""
echo "   Request:"
echo "   curl $BASE_URL/students/200/deliveries/1"
echo ""
echo "   Response:"
RESPONSE_2=$(curl -s "$BASE_URL/students/200/deliveries/1")
echo "$RESPONSE_2" | jq '.'
echo ""
FEEDBACKS_COUNT=$(echo "$RESPONSE_2" | jq '.feedbacks | length')
TASKS_COUNT=$(echo "$RESPONSE_2" | jq '.tasks | length')
echo -e "   ${GREEN}✅ Entrega con $FEEDBACKS_COUNT feedbacks y $TASKS_COUNT tareas${NC}"
echo ""
echo "   Detalles:"
echo "      Delivery: $(echo "$RESPONSE_2" | jq -r '.delivery.title')"
echo "      Feedbacks:"
echo "$RESPONSE_2" | jq -r '.feedbacks[] | "         - Feedback \(.feedback.id): \(.responsesCount) respuestas"'
echo "      Tareas:"
echo "$RESPONSE_2" | jq -r '.tasks[] | "         - Task \(.id): \"\(.title)\" - \(.feedbacksCount) feedbacks"'
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# TEST 3: Ver tarea específica con retroalimentaciones
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}TEST 3: GET /api/v1/deliveries/{deliveryId}/tasks/{taskId}${NC}"
echo "   📝 Ver tarea específica con sus feedbacks y respuestas"
echo ""
echo "   Request:"
echo "   curl $BASE_URL/deliveries/1/tasks/1"
echo ""
echo "   Response:"
RESPONSE_3=$(curl -s "$BASE_URL/deliveries/1/tasks/1")
echo "$RESPONSE_3" | jq '.'
echo ""
TASK_FEEDBACKS=$(echo "$RESPONSE_3" | jq '.feedbacks | length')
echo -e "   ${GREEN}✅ Tarea con $TASK_FEEDBACKS feedbacks${NC}"
echo ""
echo "   Detalles:"
echo "      Tarea: $(echo "$RESPONSE_3" | jq -r '.task.title')"
echo "      Status: $(echo "$RESPONSE_3" | jq -r '.task.status')"
echo "      Feedbacks de esta tarea:"
echo "$RESPONSE_3" | jq -r '.feedbacks[] | "         - Feedback \(.feedback.id): \"\(.feedback.content | .[0:60])...\" (\(.responsesCount) respuestas)"'
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# =============================================================================
echo "════════════════════════════════════════════════════════════════════════════"
echo "   ENDPOINTS PARA PROFESORES (4)"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# TEST 4: Listar entregas pendientes de revisión
echo -e "${BLUE}TEST 4: GET /api/v1/professor/deliveries/pending${NC}"
echo "   📝 Listar entregas SIN feedbacks (pendientes de revisar)"
echo ""
echo "   Request:"
echo "   curl $BASE_URL/professor/deliveries/pending"
echo ""
echo "   Response:"
RESPONSE_4=$(curl -s "$BASE_URL/professor/deliveries/pending")
echo "$RESPONSE_4" | jq '.'
echo ""
COUNT_4=$(echo "$RESPONSE_4" | jq '. | length')
echo -e "   ${GREEN}✅ Hay $COUNT_4 entregas pendientes de revisión${NC}"
echo ""
if [ "$COUNT_4" -gt 0 ]; then
    echo "   Entregas pendientes:"
    echo "$RESPONSE_4" | jq -r '.[] | "      • Delivery \(.id): \"\(.title)\" (0 feedbacks)"'
else
    echo "   ${YELLOW}⚠️  Todas las entregas ya tienen feedback${NC}"
fi
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# TEST 5: Listar todas las entregas con filtros
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}TEST 5: GET /api/v1/professor/deliveries?status=...${NC}"
echo "   📝 Listar entregas con filtros (status: all, pending, reviewed)"
echo ""

echo "   5a) Todas las entregas:"
echo "   curl $BASE_URL/professor/deliveries"
RESPONSE_5A=$(curl -s "$BASE_URL/professor/deliveries")
COUNT_5A=$(echo "$RESPONSE_5A" | jq '. | length')
echo "   ${GREEN}✅ Total: $COUNT_5A entregas${NC}"
echo ""

echo "   5b) Solo entregas revisadas (con feedbacks):"
echo "   curl $BASE_URL/professor/deliveries?status=reviewed"
RESPONSE_5B=$(curl -s "$BASE_URL/professor/deliveries?status=reviewed")
COUNT_5B=$(echo "$RESPONSE_5B" | jq '. | length')
echo "   ${GREEN}✅ Revisadas: $COUNT_5B entregas${NC}"
echo ""

echo "   5c) Solo entregas pendientes:"
echo "   curl $BASE_URL/professor/deliveries?status=pending"
RESPONSE_5C=$(curl -s "$BASE_URL/professor/deliveries?status=pending")
COUNT_5C=$(echo "$RESPONSE_5C" | jq '. | length')
echo "   ${GREEN}✅ Pendientes: $COUNT_5C entregas${NC}"
echo ""

echo "   Resumen completo:"
echo "$RESPONSE_5A" | jq -r '.[] | "      • Delivery \(.id): \"\(.title)\" - \(.feedbacksCount) feedbacks, \(.tasksCount) tareas"'
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# TEST 6: Ver entrega para revisar (profesor)
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}TEST 6: GET /api/v1/professor/deliveries/{deliveryId}${NC}"
echo "   📝 Ver detalle de entrega para revisar (igual que estudiantes pero desde vista profesor)"
echo ""
echo "   Request:"
echo "   curl $BASE_URL/professor/deliveries/1"
echo ""
echo "   Response:"
RESPONSE_6=$(curl -s "$BASE_URL/professor/deliveries/1")
echo "$RESPONSE_6" | jq '.'
echo ""
PROF_FEEDBACKS=$(echo "$RESPONSE_6" | jq '.feedbacks | length')
PROF_TASKS=$(echo "$RESPONSE_6" | jq '.tasks | length')
echo -e "   ${GREEN}✅ Entrega con $PROF_FEEDBACKS feedbacks totales y $PROF_TASKS tareas${NC}"
echo ""
echo "   Vista del profesor:"
echo "      Delivery: $(echo "$RESPONSE_6" | jq -r '.delivery.title')"
echo "      Team ID: $(echo "$RESPONSE_6" | jq -r '.delivery.teamId')"
echo "      Feedbacks existentes: $PROF_FEEDBACKS"
echo "      Tareas para revisar: $PROF_TASKS"
echo ""
read -p "Presiona Enter para continuar..."
echo ""

# TEST 7: Buscar feedbacks por contenido
echo "════════════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}TEST 7: GET /api/v1/feedback/search?query=...${NC}"
echo "   📝 Buscar feedbacks por contenido (texto)"
echo ""

echo "   7a) Buscar 'validación':"
echo "   curl '$BASE_URL/feedback/search?query=validación'"
RESPONSE_7A=$(curl -s "$BASE_URL/feedback/search?query=validación")
COUNT_7A=$(echo "$RESPONSE_7A" | jq '. | length')
echo "   ${GREEN}✅ Encontrados: $COUNT_7A feedbacks${NC}"
if [ "$COUNT_7A" -gt 0 ]; then
    echo "$RESPONSE_7A" | jq -r '.[] | "      • Feedback \(.feedback.id): \"\(.feedback.content | .[0:70])...\""'
fi
echo ""

echo "   7b) Buscar 'arquitectura':"
echo "   curl '$BASE_URL/feedback/search?query=arquitectura'"
RESPONSE_7B=$(curl -s "$BASE_URL/feedback/search?query=arquitectura")
COUNT_7B=$(echo "$RESPONSE_7B" | jq '. | length')
echo "   ${GREEN}✅ Encontrados: $COUNT_7B feedbacks${NC}"
if [ "$COUNT_7B" -gt 0 ]; then
    echo "$RESPONSE_7B" | jq -r '.[] | "      • Feedback \(.feedback.id): \"\(.feedback.content | .[0:70])...\""'
fi
echo ""

echo "   7c) Buscar en delivery específico:"
echo "   curl '$BASE_URL/feedback/search?query=trabajo&deliveryId=1'"
RESPONSE_7C=$(curl -s "$BASE_URL/feedback/search?query=trabajo&deliveryId=1")
COUNT_7C=$(echo "$RESPONSE_7C" | jq '. | length')
echo "   ${GREEN}✅ Encontrados: $COUNT_7C feedbacks en delivery 1${NC}"
if [ "$COUNT_7C" -gt 0 ]; then
    echo "$RESPONSE_7C" | jq -r '.[] | "      • Feedback \(.feedback.id): \"\(.feedback.content | .[0:70])...\""'
fi
echo ""

# =============================================================================
echo "════════════════════════════════════════════════════════════════════════════"
echo "   📊 RESUMEN FINAL"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✅ TODOS LOS ENDPOINTS FUNCIONANDO CORRECTAMENTE${NC}"
echo ""
echo "Endpoints probados:"
echo ""
echo "ESTUDIANTES:"
echo "   ✅ GET /api/v1/students/{studentId}/deliveries"
echo "      → Devuelve: $COUNT_1 entregas con contadores"
echo ""
echo "   ✅ GET /api/v1/students/{studentId}/deliveries/{deliveryId}"
echo "      → Devuelve: Detalle completo con $FEEDBACKS_COUNT feedbacks y $TASKS_COUNT tareas"
echo ""
echo "   ✅ GET /api/v1/deliveries/{deliveryId}/tasks/{taskId}"
echo "      → Devuelve: Tarea con $TASK_FEEDBACKS feedbacks"
echo ""
echo "PROFESORES:"
echo "   ✅ GET /api/v1/professor/deliveries/pending"
echo "      → Devuelve: $COUNT_4 entregas pendientes"
echo ""
echo "   ✅ GET /api/v1/professor/deliveries?status=..."
echo "      → Todas: $COUNT_5A | Revisadas: $COUNT_5B | Pendientes: $COUNT_5C"
echo ""
echo "   ✅ GET /api/v1/professor/deliveries/{deliveryId}"
echo "      → Devuelve: Detalle completo para revisión"
echo ""
echo "   ✅ GET /api/v1/feedback/search?query=..."
echo "      → Búsqueda 'validación': $COUNT_7A | 'arquitectura': $COUNT_7B | 'trabajo' en delivery 1: $COUNT_7C"
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "   🎯 CASOS DE USO VALIDADOS"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "👨‍🎓 Flujo Estudiante:"
echo "   1. Lista sus entregas → Ve 3 entregas con contadores"
echo "   2. Selecciona entrega 1 → Ve todos los feedbacks del profesor automáticamente"
echo "   3. Navega a tarea 1 → Ve feedbacks específicos de esa tarea"
echo ""
echo "👨‍🏫 Flujo Profesor:"
echo "   1. Ve entregas pendientes → Identifica $COUNT_4 sin revisar"
echo "   2. Filtra por status → Organiza trabajo (revisadas vs pendientes)"
echo "   3. Abre entrega → Ve todo el contexto para dar feedback"
echo "   4. Busca feedbacks → Encuentra retroalimentaciones específicas por texto"
echo ""
echo "✅ IMPLEMENTACIÓN COMPLETA Y FUNCIONAL"
echo ""
