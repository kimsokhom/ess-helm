# --------------------------------------------------------------
# Dockerfile for ESS‑helm on Railway (clone → render)
# --------------------------------------------------------------

# 1️⃣ Use a tiny Alpine base
FROM alpine:3.20

# 2️⃣ Install the tools we need:
#    - bash (for the entrypoint script)
#    - curl (to download Helm)
#    - ca-certificates (HTTPS trust)
#    - git (to clone the chart repo)
RUN apk add --no-cache \
        bash \
        curl \
        ca-certificates \
        git && \
    # 3️⃣ Download and install Helm (v3.14.0 at time of writing)
    curl -fsSL https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64

# -----------------------------------------------------------------
# 4️⃣ Clone the ESS‑helm repository (the whole repo)
# -----------------------------------------------------------------
WORKDIR /chart
RUN git clone https://github.com/kimsokhom/ess-helm.git . \
    && git checkout main   # you can lock to a tag/commit if you wish

# -----------------------------------------------------------------
# 5️⃣ Copy your custom values file (keep it in the same repo)
# -----------------------------------------------------------------
COPY values.yaml /app/values.yaml

WORKDIR /app

# -----------------------------------------------------------------
# 6️⃣ Render the chart – **NOTE THE PATH CHANGE**
# -----------------------------------------------------------------
# The chart lives in: /chart/charts/matrix-stack/
ENTRYPOINT ["bash", "-c", "\
  helm template ess-release /chart/charts/matrix-stack -f /app/values.yaml > rendered.yaml && \
  echo '--- rendered.yaml (full manifest) ---' && cat rendered.yaml && \
  tail -f /dev/null"]