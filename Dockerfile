# Dockerfile

# --- 1. 빌드(Build) 단계 ---
# AWS Public ECR에서 Amazon Corretto 17 (Amazon Linux 2 기반) 이미지를 가져옵니다.
FROM public.ecr.aws/amazoncorretto/amazon-corretto:17-al2-jdk as builder

WORKDIR /workspace

# 그래들 래퍼와 빌드 설정 파일을 먼저 복사합니다.
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

# 의존성을 먼저 다운로드하여 빌드 속도를 향상시킵니다.
RUN ./gradlew dependencies

# 소스 코드를 복사합니다.
COPY src ./src

# 애플리케이션을 빌드합니다.
RUN ./gradlew build -x test


# --- 2. 실행(Runtime) 단계 ---
# 더 가벼운 JRE 이미지를 AWS Public ECR에서 가져옵니다.
FROM public.ecr.aws/amazoncorretto/amazon-corretto:17-al2-jre

WORKDIR /app

# 빌드 단계에서 생성된 JAR 파일을 복사합니다.
COPY --from=builder /workspace/build/libs/*.jar app.jar

# 8080 포트를 외부에 노출합니다.
EXPOSE 8080

# 컨테이너가 시작될 때 실행할 명령어를 정의합니다.
ENTRYPOINT ["java", "-jar", "app.jar"]