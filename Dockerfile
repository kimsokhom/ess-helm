# ---- Dockerfile ----
# 1️⃣ Start from a tiny Linux base image
FROM alpine:3.20

# 2️⃣ Install utilities + Helm binary
RUN apk add --no-cache bash curl ca-certificates && \
    curl -fsSL https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64

# 3️⃣ Clone the chart repo (use the branch/tag you need)
WORKDIR /chart
RUN git clone https://github.com/kimsokhom/ess-helm.git . \
    && git checkout main   # or a specific tag/commit

# 4️⃣ Copy your custom values file (the one you keep in the repo)
COPY values.yaml /app/values.yaml

WORKDIR /app
ENTRYPOINT ["bash", "-c", "\
  helm template ess-release /chart -f /app/values.yaml > rendered.yaml && \
  echo '--- rendered.yaml ---' && cat rendered.yaml && \
  tail -f /dev/null"]