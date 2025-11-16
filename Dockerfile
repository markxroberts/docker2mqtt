FROM debian:stable
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Pre-reqs
RUN apt update && \
    apt install --no-install-recommends -y apt-transport-https ca-certificates curl gnupg gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc &&\
    tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/debian
    Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
    Components: stable
    Signed-By: /etc/apt/keyrings/docker.asc
EOF 
    apt update && \
    apt install --no-install-recommends -y docker-ce-cli python3-paho-mqtt && \
    rm -rf /var/lib/apt/lists/*

# Copy files into place
COPY docker2mqtt /

# Set the entrypoint
ENTRYPOINT ["/docker2mqtt"]
