FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Asegurar que se use la versión más reciente del driver MongoDB
COPY src ./src
RUN mvn -B -q -DskipTests dependency:resolve
RUN mvn -B -q -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd -ms /bin/bash appuser && chown -R appuser:appuser /app
COPY --from=builder --chown=appuser:appuser /app/target/*.jar app.jar

EXPOSE 8080

# IMPORTANTE: No establecer SPRING_PROFILES_ACTIVE por defecto aquí
# Deja que lo tome del .env o docker-compose
ENV JAVA_OPTS=""

# Healthcheck mejorado
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
    CMD wget -qO- http://localhost:8080/actuator/health || exit 1

USER appuser
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]