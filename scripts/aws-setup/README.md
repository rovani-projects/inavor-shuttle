# AWS Setup Automation Scripts

This directory contains scripts to automate the AWS infrastructure setup process described in [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md).

## Overview

After completing **Steps 1-2** of the AWS Infrastructure Setup Guide (creating AWS root account and enabling AWS Organization), these scripts automate the remaining steps:

- **Step 3-5**: Account creation (Shared Services, Security, Inavor Shuttle Dev/Staging/Prod)
- **Step 6**: Identity Center setup (users, groups, permission sets, account assignments)
- **Step 7-9**: AWS CLI configuration and CDK bootstrapping
- **Step 10-15**: Environment configuration, CloudTrail, billing alerts, and verification

## Quick Start

### Prerequisites

Before running these scripts, ensure you have:

1. ✅ AWS root account created (Step 1 of infrastructure guide)
2. ✅ AWS Organization enabled (Step 2 of infrastructure guide)
3. ✅ AWS CLI v2 installed: `aws --version`
4. ✅ jq installed: `jq --version` (JSON processor)
5. ✅ Authenticated with management account: `aws sts get-caller-identity`

### Installation

```bash
# Clone or navigate to the project
cd /home/drovani/inavor-shuttle

# Make scripts executable (already done)
chmod +x scripts/aws-setup/*.sh
```

### Execution Order

Run the scripts in this order:

#### 1. Create AWS Accounts and Infrastructure

```bash
scripts/aws-setup/setup.sh
```

This script:

- Creates AWS accounts (Shared Services, Security, Inavor Shuttle Dev/Staging/Prod)
- Sets up CloudTrail for organization-wide audit logging
- Bootstraps AWS CDK in each account
- Saves account IDs to `.env.aws-accounts`

**Options:**

```bash
# Preview changes without applying them
./scripts/aws-setup/setup.sh --dry-run

# Run with specific region
./scripts/aws-setup/setup.sh --region eu-west-1

# Enable verbose output
./scripts/aws-setup/setup.sh --verbose

# Skip certain steps
./scripts/aws-setup/setup.sh --skip-cloudtrail
```

**Time required:** 5-10 minutes (account creation can take a few minutes per account)

#### 2. Set Up Identity Center (Interactive)

```bash
scripts/aws-setup/setup-identity-center.sh
```

This script guides you through:

- Creating Identity Center users for developers
- Creating groups (Developers, DevOps, ReadOnly)
- Creating permission sets with appropriate AWS managed policies
- Assigning accounts to groups with permission sets

**Note:** This step requires manual AWS Console interaction. The script provides detailed instructions.

**Time required:** 15-20 minutes

#### 3. Configure AWS CLI Profiles

```bash
scripts/aws-setup/setup-cli-profiles.sh [--portal-url https://d-xxxxx.awsapps.com/start]
```

This script:

- Configures AWS CLI for Identity Center access
- Creates named profiles for each account
- Sets up SSO session for seamless authentication

**If you know your Identity Center portal URL:**

```bash
scripts/aws-setup/setup-cli-profiles.sh --portal-url https://d-123456789.awsapps.com/start
```

**Time required:** 2-3 minutes

#### 4. Create Environment Configuration Files

```bash
scripts/aws-setup/setup-env.sh
```

This script creates:

- `cdk/.env` - CDK deployment variables
- `.env.local` - Application environment variables
- `.github/deploy-secrets-guide.md` - GitHub Actions setup instructions

**Time required:** 1 minute

### Full Automated Setup

Run all scripts sequentially:

```bash
cd scripts/aws-setup

# Step 1: Create accounts
./setup.sh

# Step 2: Identity Center setup (interactive)
./setup-identity-center.sh

# Step 3: CLI profiles (will prompt for portal URL if needed)
./setup-cli-profiles.sh

# Step 4: Environment configuration
./setup-env.sh
```

## What Gets Created

### AWS Accounts

| Account               | Email                                     | Purpose                           |
| --------------------- | ----------------------------------------- | --------------------------------- |
| Management            | (existing)                                | Organization and billing control  |
| Shared-Services       | shared-services@rovaniprojects.com        | CI/CD, monitoring, shared tools   |
| Security              | security@rovaniprojects.com               | CloudTrail logs, compliance       |
| InavorShuttle-Dev     | inavor-shuttle-dev@rovaniprojects.com     | Development environment           |
| InavorShuttle-Staging | inavor-shuttle-staging@rovaniprojects.com | Staging environment (optional)    |
| InavorShuttle-Prod    | inavor-shuttle-prod@rovaniprojects.com    | Production environment (optional) |

### Infrastructure

- **CloudTrail**: Organization-wide audit logging to S3
- **Identity Center**: Centralized access management for all developers
- **CDK Bootstrap**: CloudFormation resources for AWS CDK deployments
- **AWS CLI Profiles**: Named profiles for easy account switching

### Configuration Files

| File                              | Purpose                                |
| --------------------------------- | -------------------------------------- |
| `.env.aws-accounts`               | All AWS account IDs (gitignored)       |
| `cdk/.env`                        | CDK deployment variables (gitignored)  |
| `.env.local`                      | Application configuration (gitignored) |
| `.github/deploy-secrets-guide.md` | GitHub Actions secrets setup           |

## Troubleshooting

### "Unable to locate credentials"

**Cause:** AWS CLI not authenticated

**Solution:**

```bash
# Login with your AWS root account or Identity Center
aws sso login --profile default

# Or configure with AWS credentials
aws configure
```

### "jq: command not found"

**Cause:** jq JSON processor not installed

**Solution:**

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

### "Account creation timed out"

**Cause:** AWS account creation taking longer than expected (rare)

**Solution:**

1. Wait a few more minutes
2. Check AWS Organizations console manually
3. Rerun the script—it will detect existing accounts

### "CreateAccountStatus.Id"" is missing

**Cause:** AWS API response format changed or permission issue

**Solution:**

```bash
# Check your permissions
aws iam get-user

# Try the script again with --verbose
./setup.sh --verbose
```

### Identity Center not enabled

**Cause:** Identity Center must be enabled before running setup

**Solution:**

1. Go to AWS Console → IAM Identity Center
2. Click "Enable IAM Identity Center"
3. Wait 10 minutes for enablement
4. Rerun `setup-identity-center.sh`

### AWS CLI profile not working

**Cause:** SSO session expired or profile misconfigured

**Solution:**

```bash
# Re-authenticate
aws sso login --profile inavor-dev

# Test the profile
aws sts get-caller-identity --profile inavor-dev
```

## Customization

### Change Organization Name or Domain

Edit the script file (e.g., `setup.sh`):

```bash
# Near the top of the file
ORGANIZATION_NAME="Your Organization"
ORG_DOMAIN="yourdomain.com"
```

### Create Additional Accounts

Manually create accounts in AWS Console, or extend the `ACCOUNTS` array in `setup.sh`:

```bash
declare -A ACCOUNTS=(
    [shared-services]="shared-services@${ORG_DOMAIN}:Shared-Services"
    [security]="security@${ORG_DOMAIN}:Security"
    [your-client]="client@${ORG_DOMAIN}:ClientAccount"  # Add this
)
```

### Customize Permission Sets

Edit `setup-identity-center.sh` to create custom permission sets with different AWS managed policies.

### Use Different AWS Region

All scripts support `--region` flag:

```bash
./setup.sh --region eu-west-1
./setup-cli-profiles.sh --region eu-west-1
```

Or set environment variable:

```bash
export AWS_REGION=eu-west-1
./setup.sh
```

## Post-Setup Next Steps

After running all scripts:

1. **Verify Infrastructure**:

   ```bash
   # List accounts
   aws organizations list-accounts

   # Test CLI access to each account
   aws sts get-caller-identity --profile inavor-dev
   aws sts get-caller-identity --profile shared-services
   ```

2. **Share with Team**:
   - Share the Identity Center portal URL from setup output
   - Share AWS account IDs from `.env.aws-accounts`
   - Have team members run: `aws configure sso` with the portal URL

3. **Deploy Infrastructure**:

   ```bash
   cd cdk
   npm install
   cdk deploy InavorShuttle-dev
   ```

4. **Start Development**:
   ```bash
   npm install
   npm run setup
   npm run dev
   ```

## Security Best Practices

- ✅ **Never commit** `.env.aws-accounts` or `.env.local` to Git
- ✅ **Use Identity Center** instead of sharing AWS credentials
- ✅ **Enable MFA** on all Identity Center users
- ✅ **Rotate credentials** every 90 days
- ✅ **Monitor CloudTrail** logs in the Security account
- ✅ **Set up billing alerts** to prevent cost overruns

## Support

For issues with:

- **AWS Infrastructure**: See [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md)
- **AWS CLI**: https://docs.aws.amazon.com/cli/
- **AWS CDK**: https://docs.aws.amazon.com/cdk/
- **Inavor Shuttle**: See project documentation in `/docs/`

## Script Details

### setup.sh

**Main orchestration script** for account creation and infrastructure setup.

**Functions:**

- Account creation (5 accounts)
- CloudTrail setup
- CDK bootstrap
- Configuration file generation

**Usage:**

```bash
./setup.sh [OPTIONS]

OPTIONS:
    --region REGION         AWS region (default: us-east-2)
    --dry-run              Preview changes without making them
    --verbose              Enable verbose output
    --skip-accounts        Skip account creation
    --skip-cloudtrail      Skip CloudTrail setup
    --help                 Show help message
```

### setup-identity-center.sh

**Interactive guide** for Identity Center configuration.

Provides step-by-step instructions for:

- Creating users
- Creating groups
- Creating permission sets
- Assigning accounts to groups

**No command-line options.** Run and follow prompts.

### setup-cli-profiles.sh

**Configures AWS CLI** for Identity Center authentication.

**Functions:**

- Creates SSO session configuration
- Creates named profiles for each account
- Tests profile connectivity

**Usage:**

```bash
./setup-cli-profiles.sh [--portal-url https://...]
```

### setup-env.sh

**Generates configuration files** for CDK and application.

**Creates:**

- `cdk/.env` - CDK variables with account IDs
- `.env.local` - Application environment variables
- `.github/deploy-secrets-guide.md` - CI/CD guide

**No options.** Reads from `.env.aws-accounts`.

## File Structure

```
scripts/aws-setup/
├── setup.sh                      # Main orchestration script
├── setup-identity-center.sh      # Identity Center interactive setup
├── setup-cli-profiles.sh         # AWS CLI profile configuration
├── setup-env.sh                  # Environment file generation
└── README.md                     # This file

Generated files:
├── .env.aws-accounts            # Account IDs (gitignored)
├── cdk/.env                      # CDK variables (gitignored)
└── .env.local                    # App environment (gitignored)
```

## Version History

- **v1.0.0** (2025-11-12): Initial release with account creation, Identity Center, CLI setup
- Future: Add automated cost monitoring, backup strategies, disaster recovery

## Contributing

To improve these scripts:

1. Test changes in `--dry-run` mode first
2. Update this README with new features
3. Add error handling for new edge cases
4. Keep scripts idempotent (safe to run multiple times)

## License

These scripts are part of the Inavor Shuttle project (Rovani Projects, Inc.)

---

**Last Updated:** 2025-11-12
**Status:** Production Ready
**Tested On:** Linux, macOS, WSL2
