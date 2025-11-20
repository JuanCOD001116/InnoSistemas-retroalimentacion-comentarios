#!/bin/bash

# Script de pruebas exhaustivas para todos los endpoints
BASE_URL="http://localhost:8092/api/v1"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Función mejorada para pruebas
test_endpoint() {
    local method=$1
    local url=$2
    local description=$3
    local data=$4
    local headers=$5
    local expected_code=${6:-200}
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "\n${BLUE}Test #${TOTAL_TESTS}:${NC} $description"
    echo "  URL: $method $url"
    
    if [ -n "$data" ]; then
        if [ -n "$headers" ]; then
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url" \
                -H "Content-Type: application/json" \
                -H "$headers" \
                -d "$data")
        else
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    else
        if [ -n "$headers" ]; then
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url" \
                -H "Content-Type: application/json" \
                -H "$headers")
        else
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url" \
                -H "Content-Type: application/json")
        fi
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | sed 's/HTTP_CODE://')
    body=$(echo "$response" | sed '/HTTP_CODE:/d')
    
    if [ "$http_code" -eq "$expected_code" ]; then
        echo -e "  ${GREEN}✅ HTTP $http_code${NC} (esperado: $expected_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Validar que la respuesta no esté vacía para códigos 200
        if [ "$expected_code" -eq 200 ] && [ -z "$body" ]; then
            echo -e "  ${YELLOW}⚠️  Warning: Respuesta vacía${NC}"
        else
            # Mostrar primeros caracteres de la respuesta
            echo "  Respuesta: ${body:0:120}..."
        fi
    else
        echo -e "  ${RED}❌ HTTP $http_code${NC} (esperado: $expected_code)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "  Error: ${body:0:300}"
    fi
}

echo "════════════════════════════════════════════════════════════════"
echo "           PRUEBAS EXHAUSTIVAS DE ENDPOINTS API"
echo "════════════════════════════════════════════════════════════════"
echo "Fecha: $(date)"
echo "Base URL: $BASE_URL"
echo "════════════════════════════════════════════════════════════════"

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 1: STUDENT REPORTS (8 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/student-reports" \
    "Listar todos los reportes del estudiante 101" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/student-reports?projectId=1000" \
    "Filtrar reportes por proyecto 1000" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/student-reports?projectId=1001" \
    "Filtrar reportes por proyecto 1001 (estudiante 101)" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/4" \
    "Obtener reporte específico ID 4 (estudiante 101)" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/5" \
    "Obtener reporte específico ID 5 (estudiante 102)" \
    "" \
    "X-User-Id: 102" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/8" \
    "Obtener reporte específico ID 8 (estudiante 105)" \
    "" \
    "X-User-Id: 105" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/can-access/1000" \
    "Verificar acceso estudiante 101 a proyecto 1000" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/can-access/1001" \
    "Verificar acceso estudiante 105 a proyecto 1001" \
    "" \
    "X-User-Id: 105" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 2: FEEDBACK SEARCH (10 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/feedback/search?query=implementacion" \
    "Búsqueda simple sin filtros - 'implementacion'" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=sistema" \
    "Búsqueda simple sin filtros - 'sistema'" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=bien&deliveryId=1" \
    "Búsqueda con filtro delivery 1" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=excelente&deliveryId=3000" \
    "Búsqueda con filtro delivery 3000" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=codigo&taskId=1" \
    "Búsqueda con filtro task 1" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=tarea&taskId=2000" \
    "Búsqueda con filtro task 2000" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=proyecto&projectId=1" \
    "Búsqueda con filtro project 1" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=desarrollo&projectId=1000" \
    "Búsqueda con filtro project 1000" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=api&deliveryId=3000&taskId=2000" \
    "Búsqueda con múltiples filtros (delivery + task)" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/feedback/search?query=backend&projectId=1000&deliveryId=3000" \
    "Búsqueda con múltiples filtros (project + delivery)" \
    "" \
    "" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 3: PROFESSOR DELIVERIES (6 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/professor/deliveries/3000" \
    "Obtener detalle delivery 3000 (Sprint 1 Backend)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/professor/deliveries/3001" \
    "Obtener detalle delivery 3001 (Sprint 1 DB)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/professor/deliveries/3002" \
    "Obtener detalle delivery 3002 (Sprint 2 Frontend)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/professor/deliveries/3003" \
    "Obtener detalle delivery 3003 (Sprint 1 API)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/professor/deliveries/3004" \
    "Obtener detalle delivery 3004 (Sprint 2 Testing)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/professor/deliveries/3005" \
    "Obtener detalle delivery 3005 (Sprint 2 Deploy)" \
    "" \
    "X-User-Id: 1" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 4: TASK DETAILS (6 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/deliveries/3000/tasks/2000" \
    "Task 2000 en delivery 3000 (Autenticación JWT)" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/deliveries/3001/tasks/2001" \
    "Task 2001 en delivery 3001 (Diseño esquema DB)" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/deliveries/3002/tasks/2002" \
    "Task 2002 en delivery 3002 (Componentes React)" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/deliveries/3003/tasks/2003" \
    "Task 2003 en delivery 3003 (Endpoints REST)" \
    "" \
    "X-User-Id: 105" \
    200

test_endpoint "GET" "$BASE_URL/deliveries/3004/tasks/2004" \
    "Task 2004 en delivery 3004 (Tests unitarios)" \
    "" \
    "X-User-Id: 105" \
    200

test_endpoint "GET" "$BASE_URL/deliveries/3005/tasks/2005" \
    "Task 2005 en delivery 3005 (CI/CD Pipeline)" \
    "" \
    "X-User-Id: 105" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 5: REPORTS GENERALES (6 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/reports/student?projectId=1000" \
    "Reporte estudiante proyecto 1000" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/reports/student?projectId=1001" \
    "Reporte estudiante proyecto 1001" \
    "" \
    "X-User-Id: 105" \
    200

test_endpoint "GET" "$BASE_URL/reports/team?teamId=10" \
    "Reporte equipo 10 (Alpha - Microservicios)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/reports/team?teamId=20" \
    "Reporte equipo 20 (Beta - Arquitectura)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/reports/team?teamId=30" \
    "Reporte equipo 30 (Gamma - Cloud)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/reports/team?teamId=40" \
    "Reporte equipo 40 (Delta - DevOps)" \
    "" \
    "X-User-Id: 1" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 6: TEAM REPORTS (4 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/team-reports/3" \
    "Team report ID 3 (equipo 10, curso 100)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/team-reports/4" \
    "Team report ID 4 (equipo 20, curso 101)" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/team-reports" \
    "Listar todos los team reports del profesor 1" \
    "" \
    "X-User-Id: 1" \
    200

test_endpoint "GET" "$BASE_URL/team-reports?courseId=100" \
    "Filtrar team reports por curso 100" \
    "" \
    "X-User-Id: 1" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 7: CASOS DE EDGE (8 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/student-reports/999" \
    "Reporte inexistente ID 999 (debe fallar)" \
    "" \
    "X-User-Id: 101" \
    404

test_endpoint "GET" "$BASE_URL/professor/deliveries/9999" \
    "Delivery inexistente ID 9999 (error 500 esperado)" \
    "" \
    "X-User-Id: 1" \
    500

test_endpoint "GET" "$BASE_URL/deliveries/3000/tasks/9999" \
    "Task inexistente ID 9999 (error 500 esperado)" \
    "" \
    "X-User-Id: 101" \
    500

test_endpoint "GET" "$BASE_URL/team-reports/999" \
    "Team report inexistente ID 999 (debe fallar)" \
    "" \
    "X-User-Id: 1" \
    404

test_endpoint "GET" "$BASE_URL/feedback/search?query=" \
    "Búsqueda con query vacío" \
    "" \
    "" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/can-access/9999" \
    "Verificar acceso a proyecto inexistente 9999" \
    "" \
    "X-User-Id: 101" \
    200

test_endpoint "GET" "$BASE_URL/reports/team?teamId=999" \
    "Reporte equipo inexistente 999 (error esperado)" \
    "" \
    "X-User-Id: 1" \
    500

test_endpoint "GET" "$BASE_URL/feedback/search?query=xyzabc123notfound" \
    "Búsqueda sin resultados esperados" \
    "" \
    "" \
    200

# ============================================================================
echo -e "\n${YELLOW}═══ CATEGORÍA 8: ACCESO Y PERMISOS (4 pruebas) ═══${NC}"
# ============================================================================

test_endpoint "GET" "$BASE_URL/student-reports" \
    "Reportes estudiante 102 (diferente usuario)" \
    "" \
    "X-User-Id: 102" \
    200

test_endpoint "GET" "$BASE_URL/student-reports/4" \
    "Acceso reporte de otro estudiante (debe denegar acceso)" \
    "" \
    "X-User-Id: 102" \
    403

test_endpoint "GET" "$BASE_URL/reports/student?projectId=1000" \
    "Reporte estudiante 102 proyecto 1000" \
    "" \
    "X-User-Id: 102" \
    200

test_endpoint "GET" "$BASE_URL/reports/student?projectId=1001" \
    "Reporte estudiante 106 proyecto 1001" \
    "" \
    "X-User-Id: 106" \
    200

# ============================================================================
# RESUMEN FINAL
# ============================================================================

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "                    RESUMEN DE PRUEBAS"
echo "════════════════════════════════════════════════════════════════"
echo -e "Total de pruebas ejecutadas: ${BLUE}${TOTAL_TESTS}${NC}"
echo -e "Pruebas exitosas:           ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Pruebas fallidas:           ${RED}${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ¡TODAS LAS PRUEBAS PASARON! Tasa de éxito: 100%${NC}"
else
    PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "\n${YELLOW}Tasa de éxito: ${PERCENTAGE}%${NC}"
fi

echo "════════════════════════════════════════════════════════════════"
echo "Fecha finalización: $(date)"
echo "════════════════════════════════════════════════════════════════"
