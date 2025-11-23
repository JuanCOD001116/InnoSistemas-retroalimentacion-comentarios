#!/bin/bash

# Script para generar reportes para Estudiante ID 1 y Profesor ID 2
# Proyectos: 201 y 202
# Equipos: 301 (proyecto 201) y 302 (proyecto 202)

BASE_URL="https://redesigned-carnival-xgq9vx6wvg43p4xg-8080.app.github.dev/api/v1"

echo "📊 GENERANDO REPORTES PARA ESTUDIANTE 1 Y PROFESOR 2"
echo "====================================================="
echo ""

# ============================================
# REPORTES DE ESTUDIANTE (ID: 1)
# ============================================
echo "🎓 PARTE 1: REPORTES DE ESTUDIANTE (ID: 1)"
echo "=========================================="
echo ""

# Reporte Proyecto 201
echo "📝 1.1. Generando reporte de estudiante 1 para proyecto 201..."
echo "-------------------------------------------------------------"
curl -s -X POST "$BASE_URL/student-reports/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d '{
    "projectId": 201,
    "projectName": "Proyecto 201"
  }' | jq '.'
echo ""

# Reporte Proyecto 202
echo "📝 1.2. Generando reporte de estudiante 1 para proyecto 202..."
echo "-------------------------------------------------------------"
curl -s -X POST "$BASE_URL/student-reports/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d '{
    "projectId": 202,
    "projectName": "Proyecto 202"
  }' | jq '.'
echo ""

# Listar reportes del estudiante
echo "📋 1.3. Listando todos los reportes del estudiante 1..."
echo "-----------------------------------------------------"
curl -s -X GET "$BASE_URL/student-reports" \
  -H "X-User-Id: 1" \
  | jq '.[] | {
      id: .id,
      projectId: .projectId,
      projectName: .projectName,
      finalGrade: .finalGrade,
      generatedAt: .generatedAt
    }'
echo ""

# Filtrar por proyecto 201
echo "🔍 1.4. Reportes del estudiante 1 en proyecto 201..."
echo "--------------------------------------------------"
curl -s -X GET "$BASE_URL/student-reports?projectId=201" \
  -H "X-User-Id: 1" \
  | jq '.'
echo ""

# Filtrar por proyecto 202
echo "🔍 1.5. Reportes del estudiante 1 en proyecto 202..."
echo "--------------------------------------------------"
curl -s -X GET "$BASE_URL/student-reports?projectId=202" \
  -H "X-User-Id: 1" \
  | jq '.'
echo ""

# Descargar PDF del proyecto 201
echo "📥 1.6. Descargando PDF del reporte proyecto 201..."
echo "-------------------------------------------------"
REPORT_ID_201=$(curl -s -X GET "$BASE_URL/student-reports?projectId=201" \
  -H "X-User-Id: 1" | jq -r '.[0].id // empty')

if [ -n "$REPORT_ID_201" ]; then
    curl -s -X GET "$BASE_URL/student-reports/$REPORT_ID_201/pdf" \
      -H "X-User-Id: 1" \
      -o "/tmp/reporte-estudiante-1-proyecto-201.pdf"
    
    if [ -f "/tmp/reporte-estudiante-1-proyecto-201.pdf" ]; then
        SIZE=$(wc -c < "/tmp/reporte-estudiante-1-proyecto-201.pdf")
        echo "✅ PDF descargado: /tmp/reporte-estudiante-1-proyecto-201.pdf ($SIZE bytes)"
    else
        echo "❌ Error al descargar PDF"
    fi
else
    echo "⚠️ No se encontró reporte para proyecto 201"
fi
echo ""

# ============================================
# REPORTES DE EQUIPO (PROFESOR ID: 2)
# ============================================
echo ""
echo "👨‍🏫 PARTE 2: REPORTES DE EQUIPO (PROFESOR ID: 2)"
echo "=============================================="
echo ""

# Reporte Equipo 301 (Proyecto 201)
echo "📝 2.1. Generando reporte de equipo 301 (proyecto 201)..."
echo "-------------------------------------------------------"
curl -s -X POST "$BASE_URL/team-reports/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 2" \
  -d '{
    "teamId": 301,
    "courseId": 100,
    "courseName": "Curso para Proyecto 201"
  }' | jq '.'
echo ""

# Reporte Equipo 302 (Proyecto 202)
echo "📝 2.2. Generando reporte de equipo 302 (proyecto 202)..."
echo "-------------------------------------------------------"
curl -s -X POST "$BASE_URL/team-reports/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 2" \
  -d '{
    "teamId": 302,
    "courseId": 100,
    "courseName": "Curso para Proyecto 202"
  }' | jq '.'
echo ""

# Listar reportes del profesor
echo "📋 2.3. Listando todos los reportes del profesor 2..."
echo "---------------------------------------------------"
curl -s -X GET "$BASE_URL/team-reports" \
  -H "X-User-Id: 2" \
  | jq '.[] | {
      id: .id,
      teamId: .teamId,
      teamName: .teamName,
      courseId: .courseId,
      courseName: .courseName,
      averageGrade: .averageGrade,
      generatedAt: .generatedAt
    }'
echo ""

# Filtrar por curso
echo "🔍 2.4. Reportes del profesor 2 en curso 100..."
echo "---------------------------------------------"
curl -s -X GET "$BASE_URL/team-reports?courseId=100" \
  -H "X-User-Id: 2" \
  | jq '.'
echo ""

# ============================================
# VERIFICACIONES
# ============================================
echo ""
echo "✅ VERIFICACIONES FINALES"
echo "========================="
echo ""

# Verificar acceso del estudiante a proyectos
echo "🔐 Verificar acceso estudiante 1 a proyecto 201:"
curl -s -X GET "$BASE_URL/student-reports/can-access/201" \
  -H "X-User-Id: 1" \
  | jq '.'
echo ""

echo "🔐 Verificar acceso estudiante 1 a proyecto 202:"
curl -s -X GET "$BASE_URL/student-reports/can-access/202" \
  -H "X-User-Id: 1" \
  | jq '.'
echo ""

# Resumen final
echo ""
echo "=================================================="
echo "✅ PROCESO COMPLETADO"
echo "=================================================="
echo ""
echo "📊 Resumen:"
echo "  - Estudiante ID: 1"
echo "  - Profesor ID: 2"
echo "  - Proyecto 201 → Equipo 301"
echo "  - Proyecto 202 → Equipo 302"
echo ""
echo "📁 Archivos generados:"
echo "  - /tmp/reporte-estudiante-1-proyecto-201.pdf"
echo ""
echo "💡 Para ver un reporte específico:"
echo "   curl -X GET '$BASE_URL/student-reports/[ID]' -H 'X-User-Id: 1' | jq '.'"
echo ""
