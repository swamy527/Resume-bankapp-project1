FROM maven:3.9.9-amazoncorretto-17-debian AS build

WORKDIR /opt/shipping

COPY pom.xml /opt/shipping/

COPY src /opt/shipping/src/

RUN mvn package -DskipTests

FROM eclipse-temurin:17-jdk-alpine

EXPOSE 8080

ENV APP_HOME /usr/src/app

COPY --from=build /opt/shipping/target/*.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

CMD ["java", "-jar", "app.jar"]
