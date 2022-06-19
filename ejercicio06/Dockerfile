FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest
COPY passwordapi.jar /app/
WORKDIR /app
EXPOSE 8080
CMD ["java", "-jar", "passwordapi.jar"]