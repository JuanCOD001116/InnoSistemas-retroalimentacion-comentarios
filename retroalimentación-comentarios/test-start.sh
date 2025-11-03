#!/bin/bash
# Script de prueba simple para diagnosticar problemas

cd /workspace/retroalimentación-comentarios

echo "🔍 Probando conexión a la base de datos..."
export RABBITMQ_HOST=rabbitmq
export DB_URL=jdbc:postgresql://db:5432/InnosistemasDB
export DB_USERNAME=postgres
export DB_PASSWORD=root1

echo "Variables configuradas:"
echo "  RABBITMQ_HOST=$RABBITMQ_HOST"
echo "  DB_URL=$DB_URL"
echo ""

echo "🚀 Iniciando Spring Boot (presiona Ctrl+C si hay errores)..."
./mvnw spring-boot:run
