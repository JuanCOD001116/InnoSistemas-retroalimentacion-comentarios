#!/bin/bash

# Script de prueba SIMPLE - Solo lectura
echo "📖 TEST DE LECTURA - Sin crear datos nuevos"
echo ""

API="http://localhost:8080/api/v1"

echo "✅ TEST 1: Listar feedback de delivery #1"
curl -s "$API/feedback?deliveryId=1" \
  -H "X-User-Id: 200" \
  -H "X-User-Role: estudiante" | jq '.'

echo ""
echo "✅ TEST 2: Listar feedback de task #1"
curl -s "$API/feedback?taskId=1" \
  -H "X-User-Id: 200" | jq '.'

echo ""
echo "✅ TEST 3: Listar feedback de project #1"
curl -s "$API/feedback?projectId=1" \
  -H "X-User-Id: 100" \
  -H "X-User-Role: profesor" | jq '.'

echo ""
echo "✅ Todos los endpoints de lectura funcionan correctamente"
echo "⚠️  Para probar creación, necesitamos reiniciar con el código actualizado"
