#!/bin/bash

# Crear feedback de prueba directamente via curl
echo "🧪 Prueba rápida de endpoints"
echo ""

API="http://localhost:8080/api/v1"

echo "1️⃣ Intentando crear feedback..."
curl -X POST "$API/feedback" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 100" \
  -H "X-User-Role: profesor" \
  -d '{
    "deliveryId": 1,
    "content": "Test simple"
  }' \
  -v

echo ""
echo ""
echo "2️⃣ Listar feedback..."
curl -s "$API/feedback?deliveryId=1" \
  -H "X-User-Id: 100" | jq '.'
