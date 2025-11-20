#!/bin/bash

BASE_URL="http://localhost:8092/api/v1"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "PRUEBA DE ENDPOINTS CON ERRORES"
echo "========================================"
echo ""

# Función para probar endpoints
test_endpoint() {
    local method=$1
    local url=$2
    local description=$3
    local data=$4
    local headers=$5
    
    echo -e "${YELLOW}Probando:${NC} $description"
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
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url" -H "$headers")
        else
            response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X $method "$url")
        fi
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)
    body=$(echo "$response" | sed '/HTTP_CODE/d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "  ${GREEN}✅ HTTP $http_code${NC}"
        echo "  Respuesta: $(echo "$body" | head -c 200)"
    else
        echo -e "  ${RED}❌ HTTP $http_code${NC}"
        echo "  Error: $body"
    fi
    echo ""
}

echo "========================================="
echo "1. STUDENT REPORTS - Requiere X-User-Id"
echo "========================================="

# Lista de reportes de estudiante (necesita header X-User-Id, usando student_id 101 de V7)
test_endpoint "GET" "$BASE_URL/student-reports" \
    "Listar reportes de estudiante 101" \
    "" \
    "X-User-Id: 101"

# Filtrar por proyecto (project_id 1000 de V7)
test_endpoint "GET" "$BASE_URL/student-reports?projectId=1000" \
    "Listar reportes de estudiante 101 por proyecto 1000" \
    "" \
    "X-User-Id: 101"

# Obtener reporte específico (nuevo reporte generado para student 101: ID 4)
test_endpoint "GET" "$BASE_URL/student-reports/4" \
    "Obtener reporte estudiante ID 4 (student 101)" \
    "" \
    "X-User-Id: 101"

# Verificar acceso a proyecto 1000
test_endpoint "GET" "$BASE_URL/student-reports/can-access/1000" \
    "Verificar acceso estudiante 101 a proyecto 1000" \
    "" \
    "X-User-Id: 101"

echo "========================================="
echo "2. FEEDBACK SEARCH - Requiere query"
echo "========================================="

# Búsqueda con query obligatorio (sin tildes para evitar problemas de encoding)
test_endpoint "GET" "$BASE_URL/feedback/search?query=validacion" \
    "Buscar feedback con query 'validacion'"

test_endpoint "GET" "$BASE_URL/feedback/search?query=bien&deliveryId=1" \
    "Buscar feedback 'bien' en delivery 1"

test_endpoint "GET" "$BASE_URL/feedback/search?query=codigo&taskId=1" \
    "Buscar feedback 'codigo' en task 1"

test_endpoint "GET" "$BASE_URL/feedback/search?query=proyecto&projectId=1" \
    "Buscar feedback 'proyecto' en project 1"

echo "========================================="
echo "3. PROFESSOR DELIVERIES - Detalles"
echo "========================================="

# Obtener detalle de delivery (usando IDs de V7: 3000-3005)
test_endpoint "GET" "$BASE_URL/professor/deliveries/3000" \
    "Obtener detalle de delivery 3000"

test_endpoint "GET" "$BASE_URL/professor/deliveries/3001" \
    "Obtener detalle de delivery 3001"

test_endpoint "GET" "$BASE_URL/professor/deliveries/3002" \
    "Obtener detalle de delivery 3002"

echo "========================================="
echo "4. TASK DETAILS"
echo "========================================="

# Ver detalle de tarea (usando IDs de V9: delivery 3000->task 2000, delivery 3001->task 2001)
test_endpoint "GET" "$BASE_URL/deliveries/3000/tasks/2000" \
    "Obtener detalle de task 2000 en delivery 3000"

test_endpoint "GET" "$BASE_URL/deliveries/3001/tasks/2001" \
    "Obtener detalle de task 2001 en delivery 3001"

echo "========================================="
echo "5. REPORTS - Requieren parámetros"
echo "========================================="

# Reportes con X-User-Id (usando IDs de V7: projects 1000-1001, teams 10-20)
test_endpoint "GET" "$BASE_URL/reports/student?projectId=1000" \
    "Reporte estudiante para proyecto 1000" \
    "" \
    "X-User-Id: 101"

test_endpoint "GET" "$BASE_URL/reports/team?teamId=10" \
    "Reporte equipo 10" \
    "" \
    "X-User-Id: 1"

echo "========================================="
echo "6. TEAM REPORTS - Con autenticación"
echo "========================================="

# Obtener reporte específico con autenticación (nuevos reportes generados: IDs 7, 8)
test_endpoint "GET" "$BASE_URL/team-reports/7" \
    "Obtener team-report ID 7 con profesor 1" \
    "" \
    "X-User-Id: 1"

test_endpoint "GET" "$BASE_URL/team-reports/8" \
    "Obtener team-report ID 8 con profesor 1" \
    "" \
    "X-User-Id: 1"

echo "========================================="
echo "PRUEBAS COMPLETADAS"
echo "========================================="
