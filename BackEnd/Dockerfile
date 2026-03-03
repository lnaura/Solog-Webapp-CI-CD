FROM amazoncorretto:21-alpine-jdk AS builder
WORKDIR /app 

RUN apk update && apk add --no-cache dos2unix

COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle . 

RUN dos2unix gradlew

RUN chmod +x ./gradlew

RUN ./gradlew dependencies --no-daemon || true

COPY src src

RUN ./gradlew build -x test --no-daemon

# --- Stage 2: Run ---
FROM amazoncorretto:21-alpine-jdk

WORKDIR /app

EXPOSE 8080

COPY --from=builder /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]