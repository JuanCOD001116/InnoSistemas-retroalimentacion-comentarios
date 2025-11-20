#!/bin/bash

# Script para generar reportes con formato correcto
BASE_URL="http://localhost:8092/api/v1"

echo "============================================="
echo "GENERACIÓN DE REPORTES"
echo "============================================="

# Función para generar reportes
generate_report() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    local description=$5
    
    echo ""
    echo "Generando: $description"
    echo "  URL: $method $url"
    
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
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | sed 's/HTTP_CODE://')
    body=$(echo "$response" | sed '/HTTP_CODE:/d')
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "  ✅ HTTP $http_code"
        echo "  Respuesta: ${body:0:200}"
    else
        echo "  ❌ HTTP $http_code"
        echo "  Error: ${body:0:300}"
    fi
}

echo ""
echo "============================================="
echo "1. STUDENT REPORTS - Generación"
echo "============================================="

# Generar reportes de estudiantes para proyecto 1000
generate_report "POST" "$BASE_URL/student-reports/generate" \
    '{"projectId":1000,"projectName":"Proyecto Sistemas Distribuidos"}' \
    "X-User-Id: 101" \
    "Generar reporte estudiante 101 proyecto 1000"

generate_report "POST" "$BASE_URL/student-reports/generate" \
    '{"projectId":1000,"projectName":"Proyecto Sistemas Distribuidos"}' \
    "X-User-Id: 102" \
    "Generar reporte estudiante 102 proyecto 1000"

generate_report "POST" "$BASE_URL/student-reports/generate" \
    '{"projectId":1001,"projectName":"Proyecto Arquitectura de Software"}' \
    "X-User-Id: 105" \
    "Generar reporte estudiante 105 proyecto 1001"

echo ""
echo "============================================="
echo "2. TEAM REPORTS - Generación"
echo "============================================="

# Generar reportes de equipos
generate_report "POST" "$BASE_URL/team-reports/generate" \
    '{"teamId":10,"projectId":1000,"courseId":100,"courseName":"Sistemas Distribuidos 2025-1"}' \
    "X-User-Id: 1" \
    "Generar reporte equipo 10 proyecto 1000"

generate_report "POST" "$BASE_URL/team-reports/generate" \
    '{"teamId":20,"projectId":1001,"courseId":101,"courseName":"Arquitectura de Software 2025-1"}' \
    "X-User-Id: 1" \
    "Generar reporte equipo 20 proyecto 1001"

echo ""
echo "============================================="
echo "3. VERIFICAR REPORTES GENERADOS"
echo "============================================="

# Listar reportes de estudiante
echo ""
echo "Listar reportes de estudiante 101:"
curl -s -X GET "$BASE_URL/student-reports" \
    -H "X-User-Id: 101" | python3 -m json.tool 2>/dev/null || echo "Sin reportes o error de formato"

# Listar reportes de equipo
echo ""
echo "Listar reportes del profesor 1:"
curl -s -X GET "$BASE_URL/team-reports" \
    -H "X-User-Id: 1" | python3 -m json.tool 2>/dev/null || echo "Sin reportes o error de formato"

echo ""
echo "============================================="
echo "GENERACIÓN COMPLETADA"
echo "============================================="
