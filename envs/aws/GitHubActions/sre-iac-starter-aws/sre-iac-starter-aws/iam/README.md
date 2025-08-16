# GitHub OIDC で Assume する IAM ロールの作成手順

以下は **最小で動く** ための叩き台です。必要に応じて権限を絞ってください。

## 1) OIDC プロバイダの確認/作成

- コンソール: IAM → Identity providers → `token.actions.githubusercontent.com`
- 無ければ作成（Audience: `sts.amazonaws.com`）

## 2) ロール作成

- 名前例: `sre-iac-starter-oidc`
- 信頼ポリシーに `trust-policy.json` を貼り付け、`<ACCOUNT_ID>`, `<OWNER>`, `<REPO>` を置換

## 3) 権限ポリシーのアタッチ

- 最初は `permissions-policy.json` をカスタムポリシーとして作成してロールにアタッチ
- 動作確認後、サービス別に最小権限へ段階的に絞り込むのがおすすめ

---

## trust-policy.json（例）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:<OWNER>/<REPO>:ref:refs/heads/main",
            "repo:<OWNER>/<REPO>:pull_request"
          ]
        }
      }
    }
  ]
}
```

## permissions-policy.json（例：検証向けでやや広め）

タグ `Project=sre-iac-starter` を前提に、スコープを制限しています。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StsSelf",
      "Effect": "Allow",
      "Action": ["sts:GetCallerIdentity"],
      "Resource": "*"
    },
    {
      "Sid": "ProjectScoped",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "iam:PassRole",
        "iam:CreateServiceLinkedRole",
        "s3:*",
        "dynamodb:*",
        "cloudwatch:*",
        "logs:*",
        "events:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "sre-iac-starter"
        }
      }
    }
  ]
}
```

> 注意：S3 バケットや DynamoDB テーブルなど **作成直後の一部操作でタグ条件が効かない**ケースがあります。
> 必要に応じてリソースレベルやアクションレベルで条件を調整してください。
