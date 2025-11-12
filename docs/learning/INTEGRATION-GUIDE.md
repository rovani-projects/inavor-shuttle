# AWS Automation Integration Guide

This document explains how the AWS automation scripts integrate with the existing infrastructure setup documentation and project structure.

## Document Relationships

```
docs/learning/aws-infrastructure-setup-guide.md
    ↓ (Steps 1-2: Manual setup)
QUICKSTART-AWS-SETUP.md
    ↓ (Steps 3-15: Automated scripts)
scripts/aws-setup/
    ├── run-all.sh                 (Master orchestration)
    ├── setup.sh                   (Account creation + CloudTrail)
    ├── setup-identity-center.sh   (Interactive Identity Center guide)
    ├── setup-cli-profiles.sh      (CLI configuration)
    ├── setup-env.sh               (Environment files)
    └── README.md                  (Detailed script documentation)
```

## What's Automated

### Previously Manual (Documented in Guide)

Steps 1-2 of the infrastructure guide required clicking through:

- AWS account creation
- AWS Organization setup

**Status:** Still requires manual action ✓ (necessary for security)

### Now Automated (Scripts)

Steps 3-15 of the infrastructure guide are now automated:

| Step  | Description                       | Automated         | Script                     |
| ----- | --------------------------------- | ----------------- | -------------------------- |
| 3     | Create Shared Services Account    | ✅                | `setup.sh`                 |
| 4     | Create Security Account           | ✅                | `setup.sh`                 |
| 5     | Create Inavor Shuttle Dev Account | ✅                | `setup.sh`                 |
| 6     | Set Up IAM Identity Center        | ⚠️ Interactive    | `setup-identity-center.sh` |
| 7     | Install AWS CLI & Configure       | ✅                | `setup-cli-profiles.sh`    |
| 8     | Install AWS CDK                   | Manual (separate) | -                          |
| 9     | Bootstrap CDK                     | ✅                | `setup.sh`                 |
| 10    | Configure Project Environment     | ✅                | `setup-env.sh`             |
| 11    | Deploy DynamoDB Tables            | Manual (separate) | -                          |
| 12-13 | Verify Deployed Resources         | Manual            | -                          |
| 14    | Set Up Billing Alerts             | Partial           | `setup.sh`                 |
| 15    | Security Best Practices           | Guide only        | -                          |

### Why Some Steps Remain Manual

1. **AWS CDK Installation**: OS-specific, better done independently
2. **DynamoDB Deployment**: Requires CDK project ready (in `/cdk`)
3. **Verification**: Important for users to see success directly
4. **Billing Alerts**: Requires AWS Budgets access (fine-grained permission control)

These are kept separate for flexibility and safety.

## Quick Rundown

### For New Projects

1. Follow [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md) Steps 1-2 (manual)
2. Run [QUICKSTART-AWS-SETUP.md](/QUICKSTART-AWS-SETUP.md) using the scripts
3. Deploy infrastructure separately with CDK

### For Existing Projects

If you've already done manual setup:

```bash
# View what scripts would do (no changes)
scripts/aws-setup/run-all.sh --dry-run

# Run scripts (they detect existing accounts)
scripts/aws-setup/run-all.sh --skip-accounts --skip-cloudtrail
```

## File Organization

### New Files Created

```
/
├── QUICKSTART-AWS-SETUP.md              # Quick-start guide (read this first)
├── INTEGRATION-GUIDE.md                 # This file
│
└── scripts/aws-setup/
    ├── run-all.sh                       # Master automation script
    ├── setup.sh                         # Account creation + CloudTrail
    ├── setup-identity-center.sh         # Interactive Identity Center guide
    ├── setup-cli-profiles.sh            # AWS CLI configuration
    ├── setup-env.sh                     # Environment file generation
    └── README.md                        # Detailed script documentation
```

### Generated Files (Gitignored)

```
.env.aws-accounts                       # Account IDs (generated)
cdk/.env                                # CDK configuration (generated)
.env.local                              # App environment (generated)
.github/deploy-secrets-guide.md         # CI/CD setup guide (generated)
```

## Usage Scenarios

### Scenario 1: Fresh AWS Setup

```bash
# 1. Create AWS account and organization (manual, see infrastructure guide)

# 2. Authenticate with management account
aws configure  # or aws sso login

# 3. Run the full automation
cd scripts/aws-setup
./run-all.sh

# 4. Install CDK
npm install -g aws-cdk

# 5. Deploy infrastructure
cd cdk
npm install
cdk deploy
```

### Scenario 2: Add New Team Member

```bash
# 1. Create Identity Center user (manual)
# AWS Console → Identity Center → Users → Create user

# 2. Add to Developers group (manual)

# 3. Developer configures CLI
aws configure sso  # or use scripts/aws-setup/setup-cli-profiles.sh

# 4. Developer can now deploy
cdk deploy
```

### Scenario 3: Migrate Existing Setup

```bash
# If you've already done manual setup:

cd scripts/aws-setup

# 1. Preview what scripts would do
./run-all.sh --dry-run

# 2. Skip already-completed steps
./run-all.sh --skip-accounts --skip-cloudtrail

# 3. Let scripts fill in remaining configuration
```

### Scenario 4: Different Region

```bash
# Deploy to different region (e.g., eu-west-1)

export AWS_REGION=eu-west-1
scripts/aws-setup/run-all.sh
```

## Integration with Existing Documentation

### How Scripts Relate to Infrastructure Guide

The automation scripts implement the manual steps from the infrastructure guide:

```
Infrastructure Guide (Manual)          →  Automation Scripts
Step 3-5: Create accounts              →  setup.sh
Step 6: Identity Center setup          →  setup-identity-center.sh
Step 7-9: CLI & CDK bootstrap          →  setup.sh + setup-cli-profiles.sh
Step 10: Environment configuration     →  setup-env.sh
Step 11+: Verification & monitoring    →  (manual verification guide)
```

### Reading Order

1. **Start here**: [QUICKSTART-AWS-SETUP.md](/QUICKSTART-AWS-SETUP.md) (5 min)
2. **For context**: [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md) (20 min)
3. **For scripts**: [scripts/aws-setup/README.md](/scripts/aws-setup/README.md) (10 min)
4. **For architecture**: [Comprehensive Implementation Plan](/docs/comprehensive-implementation-plan.md) (30 min)

## Architecture Flow

```
┌─────────────────────────────────────────────────────────┐
│ Step 1-2: Manual AWS Setup (Infrastructure Guide)     │
│  - Create AWS account                                   │
│  - Enable organization                                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ QUICKSTART-AWS-SETUP.md (Read this)                    │
│  - Overview of automation                               │
│  - Installation steps                                   │
│  - Quick commands                                       │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ scripts/aws-setup/run-all.sh (Execute)                 │
│                                                         │
│  ├─→ setup.sh                                           │
│  │   - Create 5 AWS accounts                            │
│  │   - Set up CloudTrail                                │
│  │   - Bootstrap CDK                                    │
│  │                                                       │
│  ├─→ setup-identity-center.sh (Interactive)             │
│  │   - Create users                                     │
│  │   - Create groups                                    │
│  │   - Create permission sets                           │
│  │   - Assign accounts                                  │
│  │                                                       │
│  ├─→ setup-cli-profiles.sh                              │
│  │   - Configure AWS CLI                                │
│  │   - Create named profiles                            │
│  │                                                       │
│  └─→ setup-env.sh                                       │
│      - Generate .env files                              │
│      - Create CI/CD guide                               │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ Generated Files                                         │
│  - .env.aws-accounts (Account IDs)                      │
│  - cdk/.env (CDK variables)                             │
│  - .env.local (App config)                              │
│  - .github/deploy-secrets-guide.md (CI/CD setup)       │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ Next: Deploy Infrastructure                            │
│  - npm install -g aws-cdk                               │
│  - cd cdk && npm install                                │
│  - cdk deploy                                           │
└─────────────────────────────────────────────────────────┘
```

## Environment Variables

The automation creates three `.env` files:

### `.env.aws-accounts` (Reference)

```env
MANAGEMENT_ACCOUNT_ID=123456789012
SHARED_SERVICES_ACCOUNT_ID=210987654321
SECURITY_ACCOUNT_ID=321098765432
INAVOR_DEV_ACCOUNT_ID=111111111111
INAVOR_STAGING_ACCOUNT_ID=222222222222
INAVOR_PROD_ACCOUNT_ID=333333333333
```

**Used by:** Scripts and documentation
**Safe to share:** Account IDs are not sensitive (already public in AWS Organization)

### `cdk/.env` (CDK Configuration)

```env
ORGANIZATION_MANAGEMENT_ACCOUNT_ID=123456789012
ORGANIZATION_SHARED_SERVICES_ACCOUNT_ID=210987654321
# ... (same as above, plus region)
AWS_REGION=us-east-2
INAVOR_SHUTTLE_ENVIRONMENT=dev
```

**Used by:** CDK deployment
**Safety:** Gitignored (no secrets, but avoid sharing)

### `.env.local` (Application Runtime)

```env
AWS_REGION=us-east-2
AWS_ACCOUNT_ID=111111111111
SHOPS_TABLE=InavorShuttle-dev-shops
# ... (app configuration)
SHOPIFY_API_KEY=your-api-key-here  # ADD MANUALLY
SHOPIFY_API_SECRET=your-api-secret-here  # ADD MANUALLY
```

**Used by:** Application runtime
**Safety:** Gitignored (contains secrets)
**Important:** Add real Shopify credentials manually after generation

## Error Handling

### If Script Fails

The scripts are idempotent (safe to run multiple times):

```bash
# If script fails, you can:

# 1. Review what went wrong
./run-all.sh --verbose

# 2. Run again (it will skip already-created resources)
./run-all.sh

# 3. Or skip the failed step and continue
./run-all.sh --skip-accounts  # if account creation already done
```

### If You Need to Retry

```bash
# Preview what will happen
./run-all.sh --dry-run

# Run for real
./run-all.sh

# It will:
# - Skip existing accounts
# - Not recreate already-configured resources
# - Safely continue from where it left off
```

## Performance

Expected execution times:

| Step                  | Time                                 |
| --------------------- | ------------------------------------ |
| Account creation      | 3-5 min per account (5-10 min total) |
| CloudTrail setup      | 1 min                                |
| Identity Center setup | 15-20 min (interactive, manual)      |
| CLI configuration     | 2-3 min                              |
| Environment files     | <1 min                               |
| **Total**             | **25-35 min**                        |

## Security Considerations

### What Scripts Handle

✅ Uses AWS Organizations for isolation
✅ Creates separate accounts per environment
✅ Sets up CloudTrail for audit logging
✅ Configures Identity Center for SSO
✅ Uses IAM roles with least privilege

### What You Must Handle

❌ Keep `.env.aws-accounts` secure (don't commit)
❌ Add Shopify API credentials to `.env.local` manually
❌ Store `.env.local` in a secret manager for production
❌ Rotate credentials every 90 days
❌ Monitor CloudTrail logs regularly

## Troubleshooting Integration Issues

### Scripts Don't Find AWS CLI

```bash
# Check installation
aws --version

# Or install it
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Account IDs Not Saved

```bash
# Check if file was created
ls -la .env.aws-accounts

# If not created, script failed. Check for errors:
./scripts/aws-setup/setup.sh --verbose
```

### CLI Profiles Not Working

```bash
# Re-authenticate
aws sso login --profile default

# Test access
aws sts get-caller-identity --profile inavor-dev
```

### Environment Files Wrong Account

The scripts read from `.env.aws-accounts`. If wrong:

```bash
# Edit manually
nano cdk/.env

# Or regenerate
./scripts/aws-setup/setup-env.sh
```

## Contributing to Scripts

To improve these scripts:

1. Test changes with `--dry-run` first
2. Ensure idempotency (safe to run multiple times)
3. Update README.md with changes
4. Keep error messages helpful
5. Maintain CLAUDE.md compatibility

## Support Resources

- **Automation Scripts**: [scripts/aws-setup/README.md](/scripts/aws-setup/README.md)
- **Quick Start**: [QUICKSTART-AWS-SETUP.md](/QUICKSTART-AWS-SETUP.md)
- **Full Infrastructure Guide**: [aws-infrastructure-setup-guide.md](/docs/learning/aws-infrastructure-setup-guide.md)
- **Project Architecture**: [comprehensive-implementation-plan.md](/docs/comprehensive-implementation-plan.md)

---

**Integration Guide Version:** 1.0
**Last Updated:** 2025-11-12
**Status:** Production-Ready

For questions or improvements, see the project documentation or contact the development team.
