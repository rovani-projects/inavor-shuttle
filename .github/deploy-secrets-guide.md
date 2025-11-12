# GitHub Actions Deployment Secrets

To enable automated deployments from GitHub, add these secrets to your repository:

## AWS Credentials (OIDC recommended)

### Method 1: OIDC (Recommended)
See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

Configure AWS IAM role trust for GitHub:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::834821259107:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YourOrg/inavor-shuttle:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### Method 2: Access Keys (Less Secure)
Add to repository secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

## Environment Variables

Add to repository variables:
- AWS_REGION: us-east-2
- AWS_ACCOUNT_ID: 834821259107
- CDK_DEFAULT_ACCOUNT: 834821259107
- CDK_DEFAULT_REGION: us-east-2

## Shopify API Credentials

Add to repository secrets:
- SHOPIFY_API_KEY
- SHOPIFY_API_SECRET

Keep these secure and rotate regularly.
