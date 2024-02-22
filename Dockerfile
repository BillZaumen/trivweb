FROM eclipse-temurin:17-jdk-alpine AS build

RUN mkdir /usr/share/bzdev
COPY tmp/libbzdev-base.jar /usr/share/bzdev
COPY tmp/libbzdev-ejws.jar /usr/share/bzdev
COPY trivweb.jar /usr/share/bzdev

RUN jlink --module-path /usr/share/bzdev --add-modules trivweb \
    --output /opt/trivweb --compress=2 --no-header-files --no-man-pages

RUN rm -rf /opt/java/openjdk /usr/share/bzdev
RUN strip /opt/trivweb/lib/*.so

FROM scratch

COPY --from=build / /

ENV PATH=/opt/trivweb/bin:$PATH

EXPOSE 80/tcp

WORKDIR usr/app

CMD [ "java", "-m", "trivweb" ]
