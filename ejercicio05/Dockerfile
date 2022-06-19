FROM openjdk:8
COPY passwordapi.jar /app/
WORKDIR /app
CMD ["java", "-jar", "passwordapi.jar"]
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD [ "curl", "http://localhost:8090/bad/"]
