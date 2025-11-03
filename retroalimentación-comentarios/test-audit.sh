#!/bin/bash
echo "🧹 LIMPIEZA TOTAL Y REINICIO..."

echo "Deteniendo TODOS los procesos Java (excepto VS Code)..."
jcmd 2>/dev/null | grep -v "jcmd" | grep -v "eclipse" | awk '{print $1}' | while read pid; do
    echo "  Deteniendo PID $pid..."
    jcmd $pid VM.shutdown 2>/dev/null || true
done

sleep 5

echo "✅ Todos los procesos detenidos"
echo "🔨 Compilando con cambios de audit log..."
cd /workspace/retroalimentación-comentarios
./mvnw clean compile -DskipTests -q

echo "✅ Compilación completa"
echo "🚀 Iniciando aplicación con audit log habilitado..."
nohup ./mvnw spring-boot:run > audit-test.log 2>&1 &
NEW_PID=$!

echo "⏳ PID=$NEW_PID - Esperando 35 segundos para inicio completo..."
sleep 35

echo "🧪 Probando endpoint..."
if curl -s http://localhost:8080/api/v1/feedback?deliveryId=1 > /dev/null 2>&1; then
    echo "✅ Aplicación respondiendo correctamente"
    echo ""
    echo "📝 Creando feedback de prueba..."
    FEEDBACK_ID=$(curl -s -X POST http://localhost:8080/api/v1/feedback \
      -H "Content-Type: application/json" \
      -H "X-User-Id: 999" \
      -H "X-User-Role: PROFESOR" \
      -d '{"content": "TEST AUDIT LOG FINAL", "deliveryId": 1}' | jq -r '.id')
    
    echo "Feedback creado con ID: $FEEDBACK_ID"
    sleep 2
    
    echo ""
    echo "🔍 Verificando audit_logs en PostgreSQL..."
    PGPASSWORD=root1 psql -h db -U postgres -d InnosistemasDB -c "SELECT id, user_id, action, target_type, target_id FROM audit_logs ORDER BY id DESC LIMIT 5;"
else
    echo "❌ Error: La aplicación no responde"
    echo "Ver logs en: audit-test.log"
    exit 1
fi
