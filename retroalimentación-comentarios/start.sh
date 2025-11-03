#!/bin/bash

# Script para iniciar el proyecto completo
# Ejecutar con: ./start.sh

set -e  # Detener si hay errores

echo "🚀 Iniciando Sistema de Retroalimentación y Comentarios..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si Docker está corriendo
check_docker() {
    if ! command_exists docker; then
        echo -e "${RED}❌ Docker no está instalado.${NC}"
        echo "Por favor instala Docker desde: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker no está corriendo.${NC}"
        echo "Por favor inicia Docker Desktop y vuelve a ejecutar este script."
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker está corriendo${NC}"
}

# Función para verificar Java
check_java() {
    if ! command_exists java; then
        echo -e "${RED}❌ Java no está instalado.${NC}"
        echo "Por favor instala Java 21 desde: https://adoptium.net/"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 21 ]; then
        echo -e "${YELLOW}⚠️  Advertencia: Se requiere Java 21 o superior. Versión actual: $JAVA_VERSION${NC}"
    else
        echo -e "${GREEN}✓ Java $JAVA_VERSION está instalado${NC}"
    fi
}

# Verificar prerrequisitos
echo "📋 Verificando prerrequisitos..."
check_docker
check_java
echo ""

# Verificar si RabbitMQ ya está corriendo
echo "🐰 Verificando RabbitMQ..."
if docker ps --filter "name=rabbitmq" --format "{{.Names}}" | grep -q "rabbitmq"; then
    echo -e "${GREEN}✓ RabbitMQ ya está corriendo${NC}"
    
    # Detectar el host de RabbitMQ
    RABBITMQ_CONTAINER=$(docker ps --filter "name=rabbitmq" --format "{{.Names}}" | head -1)
    if docker inspect "$RABBITMQ_CONTAINER" >/dev/null 2>&1; then
        echo "   Contenedor detectado: $RABBITMQ_CONTAINER"
    fi
else
    # Verificar si el contenedor existe pero está detenido
    if docker ps -a --filter "name=rabbitmq" --format "{{.Names}}" | grep -q "rabbitmq"; then
        echo -e "${YELLOW}⚠️  RabbitMQ existe pero está detenido. Iniciando...${NC}"
        docker start rabbitmq
        echo -e "${GREEN}✓ RabbitMQ iniciado${NC}"
    else
        echo "📦 Iniciando RabbitMQ por primera vez..."
        docker run -d --name rabbitmq \
            -p 5672:5672 \
            -p 15672:15672 \
            rabbitmq:3-management
        
        echo -e "${GREEN}✓ RabbitMQ iniciado exitosamente${NC}"
        echo -e "${YELLOW}⏳ Esperando 10 segundos a que RabbitMQ esté completamente listo...${NC}"
        sleep 10
    fi
fi

echo ""
echo "📊 Información de RabbitMQ:"
echo "   - Management UI: http://localhost:15672"
echo "   - Usuario: guest"
echo "   - Contraseña: guest"
echo ""

# Opción para limpiar y reconstruir
if [ "$1" == "--clean" ] || [ "$1" == "-c" ]; then
    echo "🧹 Limpiando proyecto..."
    ./mvnw clean
    echo ""
fi

# Configurar variables de entorno para desarrollo local
# Detectar si estamos en un devcontainer o local
if docker ps --filter "name=devcontainer" >/dev/null 2>&1; then
    # En devcontainer, usar nombres de servicio
    export RABBITMQ_HOST=${RABBITMQ_HOST:-rabbitmq}
    export DB_URL=${DB_URL:-jdbc:postgresql://db:5432/InnosistemasDB}
    echo "   Modo: DevContainer (usando nombres de servicio internos)"
else
    # En local, usar localhost
    export RABBITMQ_HOST=${RABBITMQ_HOST:-localhost}
    export DB_URL=${DB_URL:-jdbc:postgresql://localhost:5432/InnosistemasDB}
    echo "   Modo: Local (usando localhost)"
fi

export DB_USERNAME=${DB_USERNAME:-postgres}
export DB_PASSWORD=${DB_PASSWORD:-root1}

# Iniciar la aplicación Spring Boot
echo "🌱 Iniciando aplicación Spring Boot..."
echo "   - Swagger UI: http://localhost:8080/swagger-ui.html"
echo "   - API Docs: http://localhost:8080/api-docs"
echo "   - WebSocket: ws://localhost:8080/ws"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para detener la aplicación${NC}"
echo ""
echo "=========================================="
echo ""

# Ejecutar Maven con Spring Boot
./mvnw spring-boot:run
