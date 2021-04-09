FROM alpine:latest as builder
LABEL maintainer "aaron@ghent.net.nz"

ENV IC_VERSION "2.4.0-kh15"
ENV IC_SHA512SUM "698332967a1a9c0c6b67a1e01f9cefe85741eb2ba62b692877ca4003c9bdcf6a32e90842246ae67c700a0bd2e7760ca53455b4197f46089649b6148b5894cc64"

WORKDIR /usr/local/src

RUN addgroup -S icecast && \
    adduser -S icecast

RUN wget https://github.com/karlheyes/icecast-kh/archive/icecast-$IC_VERSION.tar.gz -O icecast.tar.gz \
    && echo "$IC_SHA512SUM  icecast.tar.gz" | sha512sum -c -

RUN apk add --no-cache \
    g++ make libxslt-dev libxml2-dev libogg-dev libvorbis-dev libtheora-dev \
    openssl-dev curl-dev curl git ca-certificates icecast

RUN tar zxvf icecast.tar.gz \
    && cd "icecast-kh-icecast-$IC_VERSION" \
    && ./configure \
		--prefix=/usr \
		--localstatedir=/var \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
        --with-curl \
    && make \
    && make install \
    && cp examples/icecast_minimal.xml /etc/icecast.xml \
    && chown -R icecast:icecast /etc/icecast.xml \
    && cp -R admin/ /usr/share/icecast/admin/ \ 
    && chown -R icecast:icecast /usr/share/icecast/admin/ \
    && cp -R web/ /usr/share/icecast/web/ \
    && chown -R icecast:icecast /usr/share/icecast/web/

WORKDIR /usr/local/src
RUN rm -rf "icecast-kh-icecast-$IC_VERSION"


FROM alpine:latest  

WORKDIR /home/icecast

RUN apk --no-cache add icecast

COPY --from=builder /usr/bin/icecast /usr/bin/icecast
COPY --from=builder /etc/icecast.xml /etc/icecast.xml
COPY --from=builder /usr/share/icecast/admin/ /usr/share/icecast/admin/
COPY --from=builder /usr/share/icecast/web/ /usr/share/icecast/web/

COPY icecast.xml /etc/icecast.xml

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD icecast -c /etc/icecast.xml