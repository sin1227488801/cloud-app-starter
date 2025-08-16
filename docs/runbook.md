# Runbook (MVP)
- Start with LOCAL state to avoid backend bootstrap issues.
- Prove Azure `apply/destroy` first, then port to AWS.
- Dockerize Terraform early to pin TF version.
- Switch to remote state (Azure Storage / S3+DynamoDB) after MVP.
- Keep variables minimal; increase only when needed.
