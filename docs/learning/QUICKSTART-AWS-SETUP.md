# AWS Setup Quick Start

This guide walks you through automating AWS infrastructure setup after completing Steps 1-2 of the [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md).

## Prerequisites

Before you start, complete these manual steps:

1. ✅ Create AWS root account at https://aws.amazon.com
2. ✅ Enable MFA on root account (required for security)
3. ✅ Create AWS Organization (Steps 1-2 of infrastructure guide)
4. ✅ Ensure you're logged in to the **Management Account**

## Installation

### 1. Install Required Tools

```bash
# AWS CLI v2
# macOS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows - Download: https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify
aws --version  # Should show version 2.x.x
```

```bash
# jq (JSON processor)
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y jq

# CentOS/RHEL
sudo yum install -y jq

# Windows (with Chocolatey)
choco install jq

# Verify
jq --version  # Should show version 1.x
```

### 2. Authenticate with AWS

```bash
# Option A: Using root account credentials (not recommended for production)
aws configure

# Option B: Using IAM user with console access (recommended)
# 1. Create IAM user with AdministratorAccess policy
# 2. Generate access key
# 3. Run: aws configure

# Option C: Check if already authenticated
aws sts get-caller-identity
```

## Run the Automation

### Option 1: Full Automation (Recommended)

Run all setup steps in sequence:

```bash
cd /home/drovani/inavor-shuttle/scripts/aws-setup

# Preview changes first (no actual changes made)
./run-all.sh --dry-run

# If preview looks good, run for real
./run-all.sh
```

**Time required:** 10-15 minutes for automated steps + 15-20 minutes for interactive Identity Center setup

### Option 2: Step-by-Step Automation

Run each script individually for more control:

```bash
cd /home/drovani/inavor-shuttle/scripts/aws-setup

# Step 1: Create AWS accounts and CloudTrail
./setup.sh

# Step 2: Set up Identity Center (interactive)
./setup-identity-center.sh

# Step 3: Configure AWS CLI (interactive if portal URL not provided)
./setup-cli-profiles.sh

# Step 4: Generate environment files
./setup-env.sh
```

### Option 3: Specify Portal URL Upfront

If you already know your Identity Center portal URL (from AWS Console → Identity Center → Dashboard):

```bash
cd /home/drovani/inavor-shuttle/scripts/aws-setup

# Preview
./run-all.sh --dry-run --portal-url https://d-123456789.awsapps.com/start

# Run
./run-all.sh --portal-url https://d-123456789.awsapps.com/start
```

This skips the interactive Identity Center setup.

## What Gets Created

### AWS Accounts

Five new AWS accounts are created:

| Name                  | Email                                     | Purpose                                  |
| --------------------- | ----------------------------------------- | ---------------------------------------- |
| Shared-Services       | shared-services@rovaniprojects.com        | CI/CD, monitoring, shared infrastructure |
| Security              | security@rovaniprojects.com               | CloudTrail logs, compliance, audit       |
| InavorShuttle-Dev     | inavor-shuttle-dev@rovaniprojects.com     | Development environment                  |
| InavorShuttle-Staging | inavor-shuttle-staging@rovaniprojects.com | Staging environment (optional)           |
| InavorShuttle-Prod    | inavor-shuttle-prod@rovaniprojects.com    | Production environment (optional)        |

### Infrastructure

- **CloudTrail**: Centralized audit logging for all accounts
- **IAM Identity Center**: Single sign-on for developer access
- **AWS CLI Profiles**: Pre-configured profiles for easy account switching
- **CDK Bootstrap**: CloudFormation resources for Infrastructure as Code

### Configuration Files

Three files are created (all gitignored):

```
.env.aws-accounts       # Account IDs for reference
cdk/.env               # CDK deployment configuration
.env.local             # Application environment variables
```

## Next Steps After Setup

### 1. Verify Everything Works

```bash
# List all accounts
aws organizations list-accounts

# Test CLI access (requires SSO login first)
aws sso login --profile inavor-dev
aws sts get-caller-identity --profile inavor-dev
```

### 2. Share with Team

1. Go to IAM Identity Center → Dashboard
2. Copy the "AWS access portal URL" (looks like: `https://d-123456789.awsapps.com/start`)
3. Share this URL with all developers on your team
4. Have them:
   - Log in with their Identity Center username
   - Set their password
   - Run: `aws sso login --profile default`

### 3. Deploy Infrastructure

```bash
# Bootstrap CDK (one-time)
cdk bootstrap

# Deploy DynamoDB tables and other infrastructure
cd cdk
npm install
cdk deploy InavorShuttle-dev
```

### 4. Start Development

```bash
# Install dependencies
npm install

# Set up database
npm run setup

# Start development server
npm run dev

# Server runs at http://localhost:3000
```

## Troubleshooting

### "Unable to locate credentials"

```bash
# Make sure you're authenticated
aws sts get-caller-identity

# If that fails, authenticate
aws configure
```

### "jq: command not found"

Install jq using the installation instructions above.

### "Account creation timed out"

AWS account creation can take a few minutes. Run the script again—it will detect existing accounts.

### Identity Center portal URL not found

Manually get it from AWS Console:

1. Go to https://console.aws.amazon.com
2. Search for "IAM Identity Center"
3. Go to Dashboard
4. Copy the "AWS access portal URL"

### Script permission denied

Make scripts executable:

```bash
chmod +x scripts/aws-setup/*.sh
```

## Customization

### Use Different AWS Region

```bash
# Set region for all scripts
export AWS_REGION=eu-west-1
./run-all.sh

# Or specify per-script
./setup.sh --region eu-west-1
```

### Skip Certain Steps

```bash
# Skip account creation (if accounts already exist)
./run-all.sh --skip-accounts

# Skip CloudTrail setup
./run-all.sh --skip-cloudtrail

# Skip interactive Identity Center setup
./run-all.sh --skip-identity-center

# Combine multiple skips
./run-all.sh --skip-accounts --skip-cloudtrail
```

### Preview Before Applying

```bash
# See exactly what will be created without making changes
./run-all.sh --dry-run

# Review output, then run for real
./run-all.sh
```

## Cost Considerations

Expected monthly costs with this setup:

- **DynamoDB (dev)**: ~$5-10
- **S3 (CloudTrail logs)**: ~$1-3
- **CloudWatch Logs**: ~$2-5
- **Identity Center**: Free (included with AWS Organizations)
- **Total**: ~$8-18/month

These costs are minimal during development. Review AWS Budgets (created in the setup) monthly.

## Security Best Practices

✅ **DO:**

- Use Identity Center instead of sharing AWS credentials
- Enable MFA on all user accounts
- Store `.env.aws-accounts` in a secure location (don't commit to Git)
- Review CloudTrail logs regularly
- Set up billing alerts

❌ **DON'T:**

- Use root account for daily work
- Store AWS credentials in code or environment variables
- Share AWS access keys (use Identity Center instead)
- Enable public access to S3 buckets
- Ignore CloudTrail logs

## Advanced: CI/CD Integration

To enable automated deployments from GitHub:

1. See `.github/deploy-secrets-guide.md` (created by `setup-env.sh`)
2. Configure OIDC for GitHub Actions (recommended)
3. Or add AWS credentials as GitHub Actions secrets
4. Deploy automatically on push to `main`

## Documentation

For more detailed information:

- **Full Setup Guide**: `/docs/learning/aws-infrastructure-setup-guide.md`
- **Script Details**: `/scripts/aws-setup/README.md`
- **Architecture Plan**: `/docs/comprehensive-implementation-plan.md`
- **AWS Documentation**: https://docs.aws.amazon.com/

## Support & Questions

- AWS Support: https://console.aws.amazon.com/support/
- AWS CLI Documentation: https://docs.aws.amazon.com/cli/
- AWS CDK Documentation: https://docs.aws.amazon.com/cdk/
- This Project: See `/docs/` folder

---

**Total Time to Complete:**

- Automated setup: 10-15 minutes
- Interactive steps: 15-20 minutes
- **Total: 25-35 minutes**

**Status:** Production-ready scripts tested on Linux, macOS, WSL2

**Last Updated:** 2025-11-12
