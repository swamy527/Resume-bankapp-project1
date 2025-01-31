## Java jar Mysql 

To ovveride existing values to connect database, like password and service name use the following environment variables

SPRING_DATASOURCE_URL
- jdbc:mysql://mysql-service:3306/bankappdb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true


SPRING_DATASOURCE_PASSWORD
- password: Test@123

SPRING_DATASOURCE_USERNAME
- user: root

- databasename: bankappdb
