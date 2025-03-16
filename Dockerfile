FROM alpine:latest AS builder

WORKDIR /usr/local/src

COPY icecast-kh /usr/local/src/icecast-kh

RUN apk add --no-cache \
    g++ make libxslt-dev libxml2-dev libogg-dev libvorbis-dev libtheora-dev \
    openssl-dev curl-dev curl git ca-certificates icecast

RUN cd icecast-kh \
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
    && cp -R admin/ /usr/share/icecast/admin/ \ 
    && cp -R web/ /usr/share/icecast/web/

FROM alpine:latest  

WORKDIR /home/icecast

RUN apk --no-cache add icecast

COPY --from=builder /usr/bin/icecast /usr/bin/icecast
COPY --from=builder /etc/icecast.xml /etc/icecast.xml
COPY --from=builder /usr/share/icecast/admin/ /usr/share/icecast/admin/
COPY --from=builder /usr/share/icecast/web/ /usr/share/icecast/web/

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["icecast", "-c", "/etc/icecast/icecast.xml"]
