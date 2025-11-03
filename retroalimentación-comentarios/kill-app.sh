#!/bin/bash

# Kill all java processes running spring-boot
echo "🛑 Deteniendo procesos Java..."
pgrep -f "spring-boot:run" | xargs kill -9 2>/dev/null || echo "No hay procesos Java corriendo"

# Wait for port to be free
sleep 3

echo "✅ Procesos detenidos"
