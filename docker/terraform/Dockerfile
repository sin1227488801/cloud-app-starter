FROM hashicorp/terraform:1.9.5
WORKDIR /workspace
# Optional: add awscli/azure-cli if you want in-container auth flows
# RUN apk add --no-cache bash curl jq python3 py3-pip && pip install awscli
ENTRYPOINT ["terraform"]
