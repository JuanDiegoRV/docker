# SIRHA Backend - Docker Setup

Este documento describe cómo configurar y ejecutar la aplicación SIRHA Backend usando Docker.

## Prerrequisitos

- Docker Desktop instalado
- Docker Compose instalado
- Acceso a MongoDB Atlas (URI de conexión)

## Configuración

### 1. Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# MongoDB Atlas Configuration
SPRING_DATA_MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/sirha_db?retryWrites=true&w=majority

# Application Configuration
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080

# Logging Configuration
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_EDU_DOSW_SIRHA=DEBUG
```

### 2. Construcción de la Imagen

```bash
# Construir la imagen localmente
docker build -t sirha-backend:latest .

# O usar docker-compose
docker-compose build
```

### 3. Ejecución

```bash
# Ejecutar con docker-compose (recomendado)
docker-compose up -d

# O ejecutar directamente
docker run -d \
  --name sirha-backend \
  -p 8080:8080 \
  --env-file .env \
  sirha-backend:latest
```

## Acceso a la Aplicación

Una vez ejecutándose, la aplicación estará disponible en:

- **API Base**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health
- **API Docs**: http://localhost:8080/v3/api-docs

## Comandos Útiles

### Ver logs
```bash
docker-compose logs -f sirha-backend
```

### Detener la aplicación
```bash
docker-compose down
```

### Reconstruir y ejecutar
```bash
docker-compose up --build -d
```

### Acceder al contenedor
```bash
docker exec -it sirha-backend sh
```

## GitHub Actions

El proyecto incluye GitHub Actions que automáticamente:

1. **Construye** la imagen Docker cuando se hace push a `develop` o `main`
2. **Sube** la imagen al GitHub Container Registry (ghcr.io)
3. **Escanea** la imagen en busca de vulnerabilidades de seguridad
4. **Etiqueta** las imágenes según la rama y commit

### Imágenes Disponibles

- `ghcr.io/tu-usuario/sirha-backend:develop` - Última versión de develop
- `ghcr.io/tu-usuario/sirha-backend:main` - Última versión de main
- `ghcr.io/tu-usuario/sirha-backend:latest` - Última versión estable

## Configuración de Producción

Para usar la imagen en producción:

```bash
# Pull de la imagen desde GitHub Container Registry
docker pull ghcr.io/tu-usuario/sirha-backend:latest

# Ejecutar en producción
docker run -d \
  --name sirha-backend-prod \
  -p 8080:8080 \
  -e SPRING_DATA_MONGODB_URI="tu-uri-de-mongodb-atlas" \
  -e SPRING_PROFILES_ACTIVE=prod \
  ghcr.io/tu-usuario/sirha-backend:latest
```

## Troubleshooting

### Problemas de Conexión a MongoDB
- Verifica que la URI de MongoDB Atlas sea correcta
- Asegúrate de que la IP esté en la whitelist de MongoDB Atlas
- Revisa los logs: `docker-compose logs sirha-backend`

### Problemas de Swagger
- Verifica que la aplicación esté ejecutándose correctamente
- Accede a http://localhost:8080/swagger-ui.html
- Si no carga, revisa los logs de la aplicación

### Problemas de Memoria
- Ajusta las variables JAVA_OPTS en docker-compose.yml
- Ejemplo: `JAVA_OPTS: "-Xmx1g -Xms512m"`

## Monitoreo

La aplicación incluye endpoints de monitoreo:

- **Health Check**: `/actuator/health`
- **Info**: `/actuator/info`
- **Metrics**: `/actuator/metrics`

Estos endpoints están configurados para funcionar correctamente en el entorno Docker.
