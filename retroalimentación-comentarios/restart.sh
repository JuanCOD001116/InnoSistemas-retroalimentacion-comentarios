#!/bin/bash

# Script para reiniciar la aplicación limpiamente
echo "🔄 Reiniciando aplicación..."

# Matar cualquier proceso Java en puerto 8080
netstat -tlnp 2>/dev/null | grep :8080 | awk '{print $7}' | cut -d'/' -f1 | xargs kill -9 2>/dev/null || true

# Esperar un poco
sleep 2

# Iniciar la aplicación
cd /workspace/retroalimentación-comentarios
./mvnw spring-boot:run
