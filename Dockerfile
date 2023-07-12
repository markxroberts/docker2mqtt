FROM debian:stable
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Pre-reqs
RUN apt update && \
    apt install --no-install-recommends -y apt-transport-https ca-certificates curl gnupg gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install --no-install-recommends -y docker-ce docker-ce-cli python3-paho-mqtt && \
    rm -rf /var/lib/apt/lists/*

# Copy files into place
COPY docker2mqtt /

# Set the entrypoint
ENTRYPOINT ["/docker2mqtt"]
