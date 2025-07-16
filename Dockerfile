# =======================
# Stage 1: Build with Maven
# =======================
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# =======================
# Stage 2: Run the app
# =======================
FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY --from=builder /app/target/demo-1.0.0.jar demo.jar

# Download OpenTelemetry Java Agent
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar

EXPOSE 8080
ENTRYPOINT java \
  -javaagent:/app/opentelemetry-javaagent.jar \
  -Dotel.service.name=sample-service \
  -Dotel.traces.exporter=otlp \
  -Dotel.exporter.otlp.endpoint=http://jaeger:4318 \
  -Dotel.metrics.exporter=none \
  -jar demo.jar
