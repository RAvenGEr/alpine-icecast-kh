# alpine-icecast-kh
docker image for the karlheyes branch of icecast

docker pull aaronghent/alpine-icecast-kh

docker run -it -p 8000:8000 \
    -e ICECAST_PORT='8000' \
    -e ICECAST_SOURCE_PASSWORD='TestPassword' \
    -e ICECAST_ADMIN_PASSWORD='TestAdminPassword' \
    -e ICECAST_RELAY_PASSWORD='TestRelayPassword' \
    -e ICECAST_HOSTNAME='localhost' \
    -e ICECAST_MAX_SOURCES='1'
    aaronghent/alpine-icecast-kh:latest

https://hub.docker.com/r/aaronghent/alpine-icecast-kh
