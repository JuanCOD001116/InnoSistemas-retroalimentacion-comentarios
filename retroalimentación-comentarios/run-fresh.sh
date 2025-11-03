#!/bin/bash

echo "🔄 Reiniciando aplicación Spring Boot..."
echo ""

# Intentar detener el proceso existente mediante curl (endpoint de shutdown si existiera)
# o simplemente iniciamos uno nuevo que fallará si el puerto está ocupado

cd /workspace/retroalimentación-comentarios

# Compilar con cambios recientes
echo "📦 Compilando cambios..."
./mvnw clean compile -q

echo ""
echo "🚀 Iniciando aplicación..."
echo "   Los logs se guardarán en: app-runtime.log"
echo "   Presiona Ctrl+C para detener"
echo ""

# Ejecutar
./mvnw spring-boot:run
