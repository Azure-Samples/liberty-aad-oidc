# both java8 & java11 images are supported
# comment line 3 and uncomment line 4 to build the application image with java11
FROM openliberty/open-liberty:kernel-java8-openj9-ubi
#FROM openliberty/open-liberty:kernel-java11-openj9-ubi

COPY --chown=1001:0 postgresql-42.3.9.jar /opt/ol/wlp/usr/shared/resources/
COPY --chown=1001:0 javaee-cafe/src/main/liberty/config/server.xml /config/
COPY --chown=1001:0 javaee-cafe/target/javaee-cafe.war /config/apps/

RUN configure.sh
