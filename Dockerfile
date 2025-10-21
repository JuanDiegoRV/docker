# Multi-stage build para optimizar el tamaño de la imagen
FROM maven:3.9-eclipse-temurin-17 AS builder

# Configurar directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven primero para aprovechar la caché de Docker
COPY pom.xml .

# Descargar dependencias (capa de caché para Maven)
RUN mvn -B -q -DskipTests dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar la aplicación con optimizaciones
RUN mvn -B -q -DskipTests clean package -Dmaven.test.skip=true

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

# Instalar dependencias necesarias y limpiar caché
RUN apk add --no-cache \
    curl \
    wget \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Configurar directorio de trabajo
WORKDIR /app

# Copiar JAR desde el stage de build
COPY --from=builder /app/target/*.jar app.jar

# Cambiar ownership del archivo JAR
RUN chown appuser:appgroup app.jar

# Crear directorio para logs con permisos apropiados
RUN mkdir -p /app/logs && chown -R appuser:appgroup /app/logs

# Exponer puerto
EXPOSE 8080

# Variables de entorno optimizadas
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
    SPRING_PROFILES_ACTIVE=prod \
    TZ=UTC \
    SPRING_DATA_MONGODB_URI=mongodb://mongodb:27017/sirha \
    SPRING_DATA_MONGODB_AUTO_INDEX_CREATION=true \
    SPRING_DATA_MONGODB_AUTO_INDEX_CREATION=true \
    SPRING_DATA_MONGODB_HOST=mongodb \
    SPRING_DATA_MONGODB_PORT=27017 \
    SPRING_DATA_MONGODB_DATABASE=sirha

# Healthcheck mejorado
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Cambiar a usuario no-root
USER appuser

# Punto de entrada con dumb-init para mejor manejo de señales
ENTRYPOINT ["dumb-init", "--", "sh", "-c", "java $JAVA_OPTS -jar app.jar"]
