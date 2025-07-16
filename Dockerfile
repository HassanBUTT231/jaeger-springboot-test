FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy Spring Boot JAR
COPY target/demo-1.0.0.jar /app/demo.jar

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
