# ---- Dockerfile ----
# 1️⃣ Start from a tiny Linux base image
FROM alpine:3.20

# 2️⃣ Install utilities + Helm binary
RUN apk add --no-cache bash curl ca-certificates && \
    curl -fsSL https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-amd64

# 3️⃣ (Optional) Install kubectl if you later want to talk to a real K8s cluster
# RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
#     chmod +x kubectl && mv kubectl /usr/local/bin/

# 4️⃣ Copy your Helm values file (we’ll create it next)
COPY values.yaml /app/values.yaml

WORKDIR /app

# 5️⃣ ENTRYPOINT – what runs when Railway starts the container
#    • Add the chart repo
#    • Update repo index
#    • Render the chart to a file called rendered.yaml
#    • Keep the container alive so Railway can show the logs
ENTRYPOINT ["bash", "-c", "\
  helm repo add ess-repo https://github.com/kimsokhom/ess-helm.git && \
  helm repo update && \
  helm template ess-release ess-repo/ess-chart -f /app/values.yaml > rendered.yaml && \
  echo '--- Rendered manifest saved as rendered.yaml ---' && \
  cat rendered.yaml && \
  tail -f /dev/null"]