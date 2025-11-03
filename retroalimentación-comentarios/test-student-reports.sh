#!/bin/bash

# Test script for Student Final Report endpoints
# Tests all 6 Gherkin scenarios

BASE_URL="http://localhost:8092/api/v1/student-reports"
STUDENT_ID_200=200  # Student in Team 1 (Backend)
STUDENT_ID_202=202  # Student in Team 2 (Frontend)
STUDENT_ID_999=999  # Student NOT in any team
PROJECT_ID=1

echo "🧪 PRUEBAS DE REPORTES FINALES DE ESTUDIANTES"
echo "=============================================="
echo ""

# Scenario 1: Generate student final report successfully
echo "📝 Escenario 1: Generación exitosa del reporte"
echo "-----------------------------------------------"
curl -s -X POST "$BASE_URL/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $STUDENT_ID_200" \
  -d "{\"projectId\": $PROJECT_ID, \"projectName\": \"Sistema de Gestión Académica\"}" \
  | jq '.'
echo ""
echo ""

# Generate report for student 202 as well
echo "📝 Escenario 1 (bis): Generar reporte para estudiante 202"
echo "---------------------------------------------------------"
curl -s -X POST "$BASE_URL/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $STUDENT_ID_202" \
  -d "{\"projectId\": $PROJECT_ID, \"projectName\": \"Sistema de Gestión Académica\"}" \
  | jq '.'
echo ""
echo ""

# Scenario 2: Download PDF
echo "📄 Escenario 2: Descargar reporte en PDF"
echo "---------------------------------------"
REPORT_ID=$(curl -s -X GET "$BASE_URL?projectId=$PROJECT_ID" -H "X-User-Id: $STUDENT_ID_200" | jq -r '.[0].id // 1')
PDF_SIZE=$(curl -s -X GET "$BASE_URL/$REPORT_ID/pdf" \
  -H "X-User-Id: $STUDENT_ID_200" \
  -o /tmp/reporte-test.pdf \
  -w "%{size_download}")

if [ -f "/tmp/reporte-test.pdf" ] && [ "$PDF_SIZE" -gt 0 ]; then
    echo "✅ PDF descargado exitosamente"
    echo "   Tamaño: $PDF_SIZE bytes"
    echo "   Archivo: /tmp/reporte-test.pdf"
    # Verify it's a valid PDF
    if file /tmp/reporte-test.pdf | grep -q "PDF"; then
        echo "   ✅ Formato PDF válido"
    else
        echo "   ❌ Advertencia: el archivo no parece ser un PDF válido"
    fi
else
    echo "❌ Error: no se pudo descargar el PDF"
fi
echo ""
echo ""

# Scenario 3: Get report by ID (for viewing)
echo "👁️ Escenario 3: Obtener reporte por ID"
echo "---------------------------------------"
REPORT_ID=$(curl -s -X GET "$BASE_URL?projectId=$PROJECT_ID" -H "X-User-Id: $STUDENT_ID_200" | jq -r '.[0].id // 1')
curl -s -X GET "$BASE_URL/$REPORT_ID" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | jq '{
      id: .id,
      studentName: .studentName,
      projectName: .projectName,
      finalGrade: .finalGrade,
      generatedAt: .generatedAt,
      deliveriesCount: (.deliveries | length),
      feedbackCount: (.feedbackReceived | length),
      responsesCount: (.responsesGiven | length),
      statistics: .statistics
    }'
echo ""
echo ""

# Scenario 3 (print view): Get printable view
echo "🖨️ Escenario 3: Vista imprimible (primeros 500 caracteres)"
echo "----------------------------------------------------------"
curl -s -X GET "$BASE_URL/$REPORT_ID/print" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | head -c 500
echo ""
echo "... (contenido HTML truncado)"
echo ""
echo ""

# Scenario 5: List all reports for a student
echo "📋 Escenario 5: Listar todos los reportes del estudiante"
echo "-------------------------------------------------------"
curl -s -X GET "$BASE_URL" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | jq '. | length as $count | {
      totalReports: $count,
      reports: map({id: .id, projectName: .projectName, finalGrade: .finalGrade, generatedAt: .generatedAt})
    }'
echo ""
echo ""

# Scenario 5: Filter reports by project
echo "🔍 Escenario 5: Filtrar reportes por proyecto"
echo "--------------------------------------------"
curl -s -X GET "$BASE_URL?projectId=$PROJECT_ID" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | jq '. | length as $count | {
      totalReportsForProject: $count,
      projectId: '"$PROJECT_ID"'
    }'
echo ""
echo ""

# Scenario 4: Check access permission (should be true for team member)
echo "🔐 Escenario 4: Verificar acceso para estudiante del equipo"
echo "----------------------------------------------------------"
curl -s -X GET "$BASE_URL/can-access/$PROJECT_ID" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | jq '.'
echo ""
echo ""

# Scenario 4: Check access permission (should be false for non-team member)
echo "🚫 Escenario 4: Verificar acceso para estudiante NO del equipo"
echo "-------------------------------------------------------------"
curl -s -X GET "$BASE_URL/can-access/$PROJECT_ID" \
  -H "X-User-Id: $STUDENT_ID_999" \
  | jq '.'
echo ""
echo ""

# Scenario 4: Try to access report from different student (should get 403)
echo "⛔ Escenario 4: Intento de acceso no autorizado (espera 403)"
echo "----------------------------------------------------------"
STUDENT_202_REPORT=$(curl -s -X GET "$BASE_URL?projectId=$PROJECT_ID" -H "X-User-Id: $STUDENT_ID_202" | jq -r '.[0].id // 2')
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/$STUDENT_202_REPORT" -H "X-User-Id: $STUDENT_ID_200")
echo "HTTP Status Code: $HTTP_CODE (esperado: 403)"
if [ "$HTTP_CODE" = "403" ]; then
    echo "✅ Acceso denegado correctamente"
else
    echo "❌ Error: se esperaba 403"
fi
echo ""
echo ""

# Scenario 6: Error when generating report (simulate error by using invalid project)
echo "⚠️ Escenario 6: Error al generar reporte (proyecto inválido)"
echo "-----------------------------------------------------------"
curl -s -X POST "$BASE_URL/generate" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: $STUDENT_ID_999" \
  -d '{"projectId": 99999, "projectName": "Proyecto Inexistente"}' \
  | jq '.'
echo ""
echo ""

# Scenario 6: Error when getting non-existent report (404)
echo "❌ Escenario 6: Error al obtener reporte inexistente (espera 404)"
echo "---------------------------------------------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$BASE_URL/99999" -H "X-User-Id: $STUDENT_ID_200")
echo "HTTP Status Code: $HTTP_CODE (esperado: 404)"
if [ "$HTTP_CODE" = "404" ]; then
    echo "✅ Reporte no encontrado correctamente"
else
    echo "❌ Error: se esperaba 404"
fi
echo ""
echo ""

# Verify complete report structure
echo "✅ Escenario final: Verificar estructura completa del reporte"
echo "-----------------------------------------------------------"
curl -s -X GET "$BASE_URL/$REPORT_ID" \
  -H "X-User-Id: $STUDENT_ID_200" \
  | jq 'has("id") and has("studentName") and has("projectName") and has("finalGrade") and 
        has("deliveries") and has("feedbackReceived") and has("responsesGiven") and 
        has("statistics") and (.deliveries | type == "array") and 
        (.feedbackReceived | type == "array") and (.responsesGiven | type == "array") and
        (.statistics | has("totalDeliveries")) and (.statistics | has("completedTasks")) and
        (.statistics | has("taskCompletionRate")) as $complete |
        if $complete then "✅ Estructura completa verificada" else "❌ Estructura incompleta" end'
echo ""
echo ""

echo "=============================================="
echo "✅ PRUEBAS COMPLETADAS"
echo "=============================================="
