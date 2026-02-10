# ===============================
# BUILD STAGE (Maven + Java 21)
# ===============================
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy only pom.xml first (better layer caching)
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# ===============================
# RUNTIME STAGE (Lightweight JRE)
# ===============================
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/eurekaserver-0.0.1-SNAPSHOT.jar app.jar

# Expose Eureka port
EXPOSE 7070

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
