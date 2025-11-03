#!/bin/bash

# Script para probar endpoints de reportes de evaluación de equipos
# Cubre los escenarios Gherkin: generación, filtrado, acceso, consulta, manejo de errores

BASE_URL="http://localhost:9090/api/v1/team-reports"
PROFESSOR_ID=100

echo "=========================================="
echo "PRUEBAS DE REPORTES DE EVALUACIÓN"
echo "=========================================="
echo ""

# Escenario 1: Generar reporte de evaluación de equipo
echo "📊 Escenario 1: Generar reporte para equipo 1 (curso 1)"
REPORT_RESPONSE=$(curl -s -X POST "$BASE_URL/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESSOR_ID" \
  -d '{
    "teamId": 1,
    "courseId": 1,
    "courseName": "Ingeniería de Software II"
  }')

echo "$REPORT_RESPONSE" | jq '.'
REPORT_ID=$(echo "$REPORT_RESPONSE" | jq -r '.id // empty')

if [ -n "$REPORT_ID" ]; then
    echo "✅ Reporte generado con ID: $REPORT_ID"
else
    echo "❌ Error al generar reporte"
fi
echo ""

# Esperar un momento
sleep 1

# Escenario 2: Generar reporte para equipo 2
echo "📊 Generar reporte para equipo 2 (curso 1)"
REPORT_2_RESPONSE=$(curl -s -X POST "$BASE_URL/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $PROFESSOR_ID" \
  -d '{
    "teamId": 2,
    "courseId": 1,
    "courseName": "Ingeniería de Software II"
  }')

REPORT_2_ID=$(echo "$REPORT_2_RESPONSE" | jq -r '.id // empty')
if [ -n "$REPORT_2_ID" ]; then
    echo "✅ Reporte 2 generado con ID: $REPORT_2_ID"
else
    echo "❌ Error al generar reporte 2"
fi
echo ""

sleep 1

# Escenario 3: Obtener reporte por ID
if [ -n "$REPORT_ID" ]; then
    echo "🔍 Escenario 3: Obtener reporte por ID ($REPORT_ID)"
    curl -s -X GET "$BASE_URL/$REPORT_ID" \
      -H "X-User-Id: $PROFESSOR_ID" | jq '.'
    echo ""
fi

sleep 1

# Escenario 4: Listar todos los reportes del profesor
echo "📋 Escenario 4: Listar todos los reportes del profesor"
curl -s -X GET "$BASE_URL" \
  -H "X-User-Id: $PROFESSOR_ID" | jq '.[] | {id, teamName, courseName, generatedAt, projects: .projects | length, totalDeliveries: .statistics.totalDeliveries}'
echo ""

sleep 1

# Escenario 5: Filtrar reportes por curso
echo "🔎 Escenario 5: Filtrar reportes por courseId=1"
curl -s -X GET "$BASE_URL?courseId=1" \
  -H "X-User-Id: $PROFESSOR_ID" | jq '.[] | {id, teamName, courseName}'
echo ""

sleep 1

# Escenario 6: Listar reportes de un curso específico
echo "📚 Escenario 6: Listar reportes del curso 1"
curl -s -X GET "$BASE_URL/course/1" | jq '.[] | {id, teamName, professorName, generatedAt}'
echo ""

sleep 1

# Escenario 7: Control de acceso - intentar acceder con otro profesor
if [ -n "$REPORT_ID" ]; then
    echo "🔒 Escenario 7: Probar control de acceso (profesor 999 intenta ver reporte del 100)"
    ACCESS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/$REPORT_ID" \
      -H "X-User-Id: 999")
    
    HTTP_CODE=$(echo "$ACCESS_RESPONSE" | tail -n1)
    BODY=$(echo "$ACCESS_RESPONSE" | sed '$d')
    
    echo "HTTP Code: $HTTP_CODE"
    echo "$BODY" | jq '.'
    
    if [ "$HTTP_CODE" == "403" ]; then
        echo "✅ Control de acceso funcionando correctamente"
    else
        echo "❌ Control de acceso NO funcionó (esperado 403, recibido $HTTP_CODE)"
    fi
    echo ""
fi

sleep 1

# Escenario 8: Manejo de errores - reporte inexistente
echo "❌ Escenario 8: Manejo de errores - solicitar reporte inexistente"
ERROR_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/99999" \
  -H "X-User-Id: $PROFESSOR_ID")

HTTP_CODE=$(echo "$ERROR_RESPONSE" | tail -n1)
BODY=$(echo "$ERROR_RESPONSE" | sed '$d')

echo "HTTP Code: $HTTP_CODE"
echo "$BODY" | jq '.'

if [ "$HTTP_CODE" == "404" ]; then
    echo "✅ Manejo de errores correcto (404)"
else
    echo "⚠️ HTTP Code inesperado: $HTTP_CODE"
fi
echo ""

# Escenario 9: Verificar estructura del reporte
if [ -n "$REPORT_ID" ]; then
    echo "🔬 Escenario 9: Verificar estructura completa del reporte"
    FULL_REPORT=$(curl -s -X GET "$BASE_URL/$REPORT_ID" \
      -H "X-User-Id: $PROFESSOR_ID")
    
    echo "Reporte ID: $(echo "$FULL_REPORT" | jq -r '.id')"
    echo "Equipo: $(echo "$FULL_REPORT" | jq -r '.teamName')"
    echo "Curso: $(echo "$FULL_REPORT" | jq -r '.courseName')"
    echo "Generado: $(echo "$FULL_REPORT" | jq -r '.generatedAt')"
    echo ""
    echo "Proyectos:"
    echo "$FULL_REPORT" | jq '.projects[] | {nombre: .projectName, entregas: .deliveriesCount, tareasCompletadas: .completedTasks, tareasTotales: .totalTasks}'
    echo ""
    echo "Resumen de Feedbacks:"
    echo "$FULL_REPORT" | jq '.feedbacks[] | {categoria: .category, cantidad: .count}'
    echo ""
    echo "Estadísticas:"
    echo "$FULL_REPORT" | jq '.statistics'
    echo ""
fi

echo "=========================================="
echo "✅ PRUEBAS COMPLETADAS"
echo "=========================================="
