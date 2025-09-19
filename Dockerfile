# Dockerfile

# --- 1. 빌드단계 ---
# AWS Corretto JDK17을 기반으로 빌드환경 설정
FROM amazoncorretto:17-alpine-jdk as builder

WORKDIR /workspace

# 그래들 래퍼와 빌드 설정 파일을 먼저 복사
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

#의존성을 먼저 다운로드하여 빌드속도 향상
RUN ./gradlew dependencies

#소스코드 복사
COPY src ./src

#애플리케이션 빌드
RUN ./gradlew build -x test

# --- 2. 실행(Runtime) 단계 ---
# 더 가벼운 JRE 이미지를 기반으로 최종 실행 환경을 설정
FROM amazoncorretto:17-alpine-jre

WORKDIR /app

# 빌드단계에서 생성된 JAR 파일 복사
COPY --from=builder /workplace/build/libs/*.jar app.jar

#8080포트를 외부에 노출
EXPOSE 8080

#컨테이너가 시작될 때 실행할 명령어 정의
ENTRYPOINT ["java", "-jar", "app.jar"]