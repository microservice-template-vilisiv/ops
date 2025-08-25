# Use OpenJDK 17 lightweight base image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory
WORKDIR /app

# Copy the built jar from target folder
COPY target/source-code-1.0-SNAPSHOT.jar ./hikari-service.jar

# Expose the port your service listens on
EXPOSE 8088

# Run the application
CMD ["java", "-jar", "hikari-service.jar"]
