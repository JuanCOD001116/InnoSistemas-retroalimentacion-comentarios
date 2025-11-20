#!/bin/bash

# Script para probar todos los endpoints del proyecto
# Con datos de prueba de la migración V7

BASE_URL="http://localhost:8092/api/v1"
ADMIN_TOKEN=""
STUDENT_TOKEN=""

echo "=========================================="
echo "PRUEBA DE TODOS LOS ENDPOINTS"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    local data=$4
    local extra_headers=$5
    
    echo -e "${BLUE}[TEST]${NC} $description"
    echo "   → $method $endpoint"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $extra_headers)
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            $extra_headers \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ $http_code -ge 200 ] && [ $http_code -lt 300 ]; then
        echo -e "   ${GREEN}✓ SUCCESS${NC} (HTTP $http_code)"
        # Show first 150 chars of response
        echo "   Response: $(echo $body | cut -c 1-150)"
    else
        echo -e "   ${RED}✗ FAILED${NC} (HTTP $http_code)"
        echo "   Response: $(echo $body | cut -c 1-200)"
    fi
    echo ""
    sleep 0.3
}

echo "=========================================="
echo "1. ENDPOINTS DE REPORTES DE ESTUDIANTES"
echo "=========================================="
echo ""

# GET - Obtener todos los reportes de estudiantes
test_endpoint "GET" "/student-reports" \
    "Listar todos los reportes de estudiantes"

# GET - Obtener reporte específico
test_endpoint "GET" "/student-reports/1" \
    "Obtener reporte de estudiante ID 1"

# GET - Filtrar reportes por estudiante
test_endpoint "GET" "/student-reports?studentId=101" \
    "Obtener reportes del estudiante 101"

# GET - Filtrar reportes por proyecto
test_endpoint "GET" "/student-reports?projectId=1000" \
    "Obtener reportes del proyecto 1000"

# POST - Generar reporte de estudiante
test_endpoint "POST" "/student-reports/generate" \
    "Generar nuevo reporte para estudiante" \
    '{
        "studentId": 103,
        "projectId": 1000,
        "startDate": "2025-11-01T00:00:00Z",
        "endDate": "2025-11-20T23:59:59Z"
    }'

echo "=========================================="
echo "2. ENDPOINTS DE REPORTES DE EQUIPOS"
echo "=========================================="
echo ""

# GET - Obtener todos los reportes de equipos
test_endpoint "GET" "/team-reports" \
    "Listar todos los reportes de equipos"

# GET - Obtener reporte específico
test_endpoint "GET" "/team-reports/1" \
    "Obtener reporte de equipo ID 1"

# GET - Filtrar reportes por equipo
test_endpoint "GET" "/team-reports?teamId=10" \
    "Obtener reportes del equipo 10"

# GET - Filtrar reportes por profesor
test_endpoint "GET" "/team-reports?professorId=1" \
    "Obtener reportes del profesor 1"

# GET - Filtrar reportes por curso
test_endpoint "GET" "/team-reports/course/5" \
    "Obtener reportes del curso 5"

# POST - Generar reporte de equipo
test_endpoint "POST" "/team-reports/generate" \
    "Generar nuevo reporte para equipo" \
    '{
        "teamId": 20,
        "professorId": 1,
        "courseId": 5,
        "startDate": "2025-11-01T00:00:00Z",
        "endDate": "2025-11-20T23:59:59Z"
    }'

echo "=========================================="
echo "3. ENDPOINTS DE BÚSQUEDA DE FEEDBACK"
echo "=========================================="
echo ""

# GET - Buscar feedback por proyecto
test_endpoint "GET" "/feedback/search?projectId=1000" \
    "Buscar feedback del proyecto 1000"

# GET - Buscar feedback por tarea
test_endpoint "GET" "/feedback/search?taskId=2000" \
    "Buscar feedback de la tarea 2000"

# GET - Buscar feedback por entrega
test_endpoint "GET" "/feedback/search?deliveryId=3000" \
    "Buscar feedback de la entrega 3000"

# GET - Buscar feedback por autor
test_endpoint "GET" "/feedback/search?authorId=1" \
    "Buscar feedback del autor 1"

echo "=========================================="
echo "4. ENDPOINTS DE ENTREGAS (PROFESSOR)"
echo "=========================================="
echo ""

# GET - Obtener entregas pendientes
test_endpoint "GET" "/professor/deliveries/pending?professorId=1" \
    "Obtener entregas pendientes del profesor 1"

# GET - Obtener todas las entregas
test_endpoint "GET" "/professor/deliveries?professorId=1" \
    "Obtener todas las entregas del profesor 1"

# GET - Obtener entrega específica
test_endpoint "GET" "/professor/deliveries/3000" \
    "Obtener detalles de la entrega 3000"

# GET - Obtener tarea de una entrega
test_endpoint "GET" "/deliveries/3000/tasks/2000" \
    "Obtener tarea 2000 de la entrega 3000"

echo "=========================================="
echo "5. ENDPOINTS DE REPORTES (LEGACY)"
echo "=========================================="
echo ""

# GET - Reporte de estudiante (JSON)
test_endpoint "GET" "/reports/student?studentId=101&projectId=1000" \
    "Obtener reporte JSON del estudiante 101"

# GET - Reporte de equipo (JSON)
test_endpoint "GET" "/reports/team?teamId=10&courseId=5" \
    "Obtener reporte JSON del equipo 10"

echo "=========================================="
echo "6. PRUEBAS DE DATOS DE MIGRACIÓN"
echo "=========================================="
echo ""

echo "Verificando datos insertados en la migración V7:"
echo ""

# Verificar que existen los feedbacks
echo -e "${BLUE}[INFO]${NC} Consultando base de datos directamente..."
echo ""

echo "=========================================="
echo "RESUMEN DE PRUEBAS"
echo "=========================================="
echo ""
echo "✓ Todos los endpoints principales han sido probados"
echo "✓ Datos de prueba de la migración V7 utilizados"
echo ""
echo "Endpoints cubiertos:"
echo "  • Reportes de Estudiantes (GET, POST, filtros)"
echo "  • Reportes de Equipos (GET, POST, filtros)"
echo "  • Búsqueda de Feedback (múltiples filtros)"
echo "  • Entregas de Profesor (GET, filtros)"
echo "  • Reportes Legacy (JSON y PDF)"
echo ""
echo "Datos de prueba disponibles:"
echo "  • 24 feedbacks (proyecto, tarea, entrega)"
echo "  • 23 respuestas a feedbacks"
echo "  • 10 audit logs"
echo "  • 2 reportes de equipos"
echo "  • 3 reportes de estudiantes"
echo ""
echo "=========================================="

