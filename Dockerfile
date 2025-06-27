FROM gradle:8.14.2-jdk17 as builder
WORKDIR /app

COPY build.gradle.kts .
COPY settings.gradle.kts .
RUN gradle dependencies

COPY . .
RUN gradle bootJar --no-daemon --parallel --build-cache

FROM eclipse-temurin:21-jre-alpine

# 创建并切换用户
RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring
WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]