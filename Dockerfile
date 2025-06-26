FROM gradle:8.14.2-jdk17 as builder
WORKDIR /app

COPY build.gradle.kts .
COPY settings.gradle.kts .
RUN gradle dependencies

COPY . .
RUN gradle bootJar

FROM amazoncorretto:21-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
