# Dockerfile
FROM debian:12-slim

ARG KUBECTL_VERSION=v1.31.0
# buildx подставит эти аргументы для multi-arch
ARG TARGETOS=linux
ARG TARGETARCH=amd64

ENV HOME=/home/bitnami \
    PATH=/usr/local/bin:$PATH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Минимальные пакеты + очистка слоёв
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg coreutils \
 && rm -rf /var/lib/apt/lists/*

# Скачиваем kubectl и проверяем sha256 как делает Bitnami
RUN curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl \
 && curl -fsSLo /tmp/kubectl.sha256 "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl.sha256" \
 && echo "$(cat /tmp/kubectl.sha256)  /usr/local/bin/kubectl" | sha256sum -c -

# Непривилегированный пользователь (как у Bitnami: uid/gid 1001)
RUN groupadd -g 1001 bitnami \
 && useradd -m -d /home/bitnami -u 1001 -g 1001 bitnami

USER 1001
WORKDIR /home/bitnami

# OCI-лейблы в духе Bitnami
LABEL org.opencontainers.image.title="kubectl" \
      org.opencontainers.image.description="kubectl CLI" \
      org.opencontainers.image.source="https://github.com/kubernetes/kubectl" \
      org.opencontainers.image.vendor="custom" \
      org.opencontainers.image.licenses="Apache-2.0"

ENTRYPOINT ["kubectl"]
CMD ["version", "--client"]