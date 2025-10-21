# Multi-stage build para optimizar el tamaño de la imagen
FROM maven:3.9-eclipse-temurin-17 AS builder

# Configurar directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven
COPY pom.xml .

# Descargar dependencias (capa de caché para Maven)
RUN mvn -B -q -DskipTests dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar la aplicación
RUN mvn -B -q -DskipTests clean package

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

# Instalar dependencias necesarias
RUN apk add --no-cache \
    curl \
    wget \
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

# Exponer puerto
EXPOSE 8080

# Variables de entorno
ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE=prod \
    TZ=UTC

# Healthcheck mejorado
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Cambiar a usuario no-root
USER appuser

# Punto de entrada
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
