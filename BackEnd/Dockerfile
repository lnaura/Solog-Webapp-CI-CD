# --- Stage 1: Build ---
FROM amazoncorretto:21-alpine-jdk AS builder

WORKDIR /app 

# 윈도우 사용자를 위한 줄바꿈 변환 도구 설치
RUN apk update && apk add --no-cache dos2unix

COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle . 

RUN dos2unix gradlew

# 실행 권한 부여
RUN chmod +x ./gradlew

# 종속성 다운로드
RUN ./gradlew dependencies --no-daemon || true

# 소스 코드 복사
COPY src src

# 빌드 실행 (테스트 제외)
RUN ./gradlew build -x test --no-daemon

# --- Stage 2: Run ---
FROM amazoncorretto:21-alpine-jdk

WORKDIR /app

EXPOSE 8080

COPY --from=builder /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]