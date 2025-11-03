# 🚀 Scripts de Inicio Rápido

Este proyecto incluye scripts automatizados para iniciar y detener todos los servicios con un solo comando.

## ✨ Inicio Rápido

### Linux / Mac / Git Bash

```bash
./start.sh
```

### Windows PowerShell

```powershell
.\start.ps1
```

## 🛑 Detener Servicios

### Linux / Mac / Git Bash

```bash
./stop.sh
```

### Windows PowerShell

```powershell
.\stop.ps1
```

## 📋 ¿Qué hacen los scripts?

Los scripts de inicio automáticamente:

1. ✅ **Verifican** que Docker y Java estén instalados y corriendo
2. 🐰 **Inician RabbitMQ** si no está corriendo (o lo reinician si está detenido)
3. 🌱 **Arrancan la aplicación Spring Boot** con todas sus dependencias
4. 📊 **Muestran** las URLs importantes:
   - Swagger UI: http://localhost:8080/swagger-ui.html
   - API Docs: http://localhost:8080/api-docs
   - WebSocket: ws://localhost:8080/ws
   - RabbitMQ Management: http://localhost:15672 (guest/guest)

## ⚙️ Opciones Adicionales

### Limpiar y reconstruir

Para limpiar el proyecto antes de iniciar:

```bash
./start.sh --clean     # Linux/Mac
.\start.ps1 --clean    # Windows
```

## 🔧 Requisitos Previos

- **Java 21** o superior
- **Docker Desktop** corriendo
- **Maven** (incluido como `mvnw`)

## 🐛 Solución de Problemas

### Error: "Docker no está corriendo"
- Inicia Docker Desktop y espera a que esté completamente listo
- Vuelve a ejecutar el script

### Error: "Java no está instalado"
- Instala Java 21 desde: https://adoptium.net/
- Verifica con: `java -version`

### El puerto 8080 está en uso
- Detén cualquier otra aplicación que use el puerto 8080
- O cambia el puerto en `application.properties`

### RabbitMQ no se inicia
- Verifica que Docker tenga suficientes recursos asignados
- Revisa los logs: `docker logs rabbitmq`
- Elimina el contenedor y vuelve a intentar: `docker rm -f rabbitmq && ./start.sh`

## 📚 Documentación Adicional

- [README.md](README.md) - Documentación completa del proyecto
- [EJEMPLOS_API.md](EJEMPLOS_API.md) - Ejemplos de todos los endpoints
- [GUIA_EJECUCION_PASO_A_PASO.md](GUIA_EJECUCION_PASO_A_PASO.md) - Guía detallada paso a paso
- [CONFIGURACION_RABBITMQ_WEBSOCKET.md](CONFIGURACION_RABBITMQ_WEBSOCKET.md) - Configuración de RabbitMQ y WebSocket
