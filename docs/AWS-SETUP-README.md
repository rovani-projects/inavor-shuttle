# AWS Setup Documentation

## Overview

This folder contains the complete AWS setup documentation for the Inavor Shuttle project.

## Documents

### Primary Reference
- **[AWS-SETUP-COMPLETE-GUIDE.md](learning/AWS-SETUP-COMPLETE-GUIDE.md)** - The definitive, start-to-finish guide for setting up AWS from zero

This is the **only comprehensive guide you need**. It covers:
- Creating an AWS root account from scratch
- Setting up a multi-account organization (5 accounts)
- Configuring IAM Identity Center for developer access
- Installing and configuring AWS CLI and CDK
- Deploying infrastructure (DynamoDB tables, S3, SQS, IAM roles)
- Verifying and testing the deployment
- Complete troubleshooting guide

**Use this guide if**: You're setting up AWS infrastructure from zero, or you need a complete reference to understand what was done and why.

---

## Current Status

✅ **AWS Infrastructure: Fully Deployed**

- **Organization**: 5 AWS accounts created and configured
- **Accounts**:
  - Management (866253419755)
  - Shared Services (778948804868)
  - Security (060351707639)
  - Inavor Shuttle - Dev (873925794893) ← **Active Development**
  - Inavor Shuttle - Staging (855025371279)
  - Inavor Shuttle - Prod (256547294520)

- **Developer Access**: IAM Identity Center (SSO) configured
- **Infrastructure**: DynamoDB tables, IAM roles, CloudTrail logging deployed
- **Local Setup**: AWS CLI and CDK configured and working

---

## Important Account ID Note

⚠️ **IMPORTANT**: The development account ID is **873925794893**, not 834821259107 as originally documented. This was corrected after discovering the actual account ID in Identity Center.

See `.env.aws-accounts` for current account IDs.

---

## Quick Start (After Initial Setup)

Once everything is set up, common tasks are:

### Authenticate
```bash
aws sso login --profile inavor-dev
```

### Deploy Infrastructure
```bash
cd cdk
export AWS_PROFILE=inavor-dev
cdk deploy InavorShuttle-dev --require-approval never
```

### Verify Deployment
```bash
export AWS_PROFILE=inavor-dev
aws dynamodb list-tables
```

### Start Development
```bash
npm install
npm run setup
npm run dev
```

---

## Next Steps

1. **Read the Complete Guide**: Review [AWS-SETUP-COMPLETE-GUIDE.md](learning/AWS-SETUP-COMPLETE-GUIDE.md) to understand the full setup
2. **Verify Your Setup**: Run the verification commands in the guide
3. **Proceed to Development**: Start working on Phase 1 issues

---

## Changes Made (2025-11-13)

### Documentation Cleanup
- ❌ Removed outdated guides:
  - `aws-infrastructure-setup-guide.md` (too long and fragmented)
  - `QUICKSTART-AWS-SETUP.md`
  - `CDK-DEPLOYMENT-GUIDE.md`
  - `INTEGRATION-GUIDE.md`
  - `AWS-AUTOMATION-SUMMARY.txt`

- ✅ Created consolidated guide:
  - `AWS-SETUP-COMPLETE-GUIDE.md` (single source of truth)

### Configuration Updates
- Updated `cdk/.env` with correct dev account ID (873925794893)
- Updated `~/.aws/config` to use correct SSO start URL
- Updated `.env.aws-accounts` with actual account IDs

---

## File Reference

| File | Purpose |
|------|---------|
| `docs/learning/AWS-SETUP-COMPLETE-GUIDE.md` | Complete step-by-step setup guide (zero to deployed) |
| `docs/AWS-SETUP-README.md` | This file - overview and navigation |
| `.env.aws-accounts` | Actual AWS account IDs (do not commit) |
| `cdk/.env` | CDK environment variables |

---

## Support

If you encounter issues:
1. Check the **Troubleshooting** section in [AWS-SETUP-COMPLETE-GUIDE.md](learning/AWS-SETUP-COMPLETE-GUIDE.md)
2. Verify account IDs in `.env.aws-accounts`
3. Ensure AWS CLI is configured: `aws sts get-caller-identity --profile inavor-dev`
4. Check CloudFormation stack events in AWS Console

---

**Last Updated**: 2025-11-13
**Status**: AWS infrastructure fully deployed and ready for development
