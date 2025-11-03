#!/bin/bash

# Script para detener todos los servicios
# Ejecutar con: ./stop.sh

echo "🛑 Deteniendo servicios..."
echo ""

# Detener RabbitMQ
if docker ps --filter "name=rabbitmq" --format "{{.Names}}" | grep -q "rabbitmq"; then
    echo "🐰 Deteniendo RabbitMQ..."
    docker stop rabbitmq
    echo "✓ RabbitMQ detenido"
else
    echo "ℹ️  RabbitMQ no está corriendo"
fi

echo ""
echo "✅ Servicios detenidos"
echo ""
echo "Para eliminar el contenedor completamente, ejecuta:"
echo "  docker rm rabbitmq"
