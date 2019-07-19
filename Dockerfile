# This is dockerimage for bakalari_webapp
# Petr Šťastný <petr.stastny01@gmail.com>
# https://github.com/SoptikHa2/bakalari_webapp

FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

CMD []
ENTRYPOINT ["/usr/bin/dart", "web/webapp/main.dart"]
