# Complete AWS Setup Guide: From Zero to Production-Ready

**Organization**: Rovani Projects, Inc.
**Project**: Inavor Shuttle - Shopify Product Import Application
**Purpose**: Complete AWS infrastructure setup for multi-account, multi-developer environments
**Status**: Comprehensive step-by-step guide (assumes zero AWS experience)
**Last Updated**: 2025-11-13
**Estimated Time**: 4-6 hours (first-time setup)

---

## Table of Contents

1. [Prerequisites & Planning](#prerequisites--planning)
2. [Phase 1: AWS Organization Setup](#phase-1-aws-organization-setup)
3. [Phase 2: Developer Access & Authentication](#phase-2-developer-access--authentication)
4. [Phase 3: Local Development Environment](#phase-3-local-development-environment)
5. [Phase 4: Infrastructure Deployment](#phase-4-infrastructure-deployment)
6. [Phase 5: Verification & Testing](#phase-5-verification--testing)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites & Planning

### What You'll Need

- **Email address** for AWS root account (use organization email, e.g., `admin@rovaniprojects.com`)
- **Credit card** on file (AWS requires this; you'll qualify for free tier)
- **Phone number** for identity verification
- **MFA device** (smartphone with authenticator app like Google Authenticator or Authy)
- **Node.js 20.x+** installed locally (`node --version`)
- **npm** installed (`npm --version`)
- **Terminal/command-line access**
- **Terminal access to the codebase** at `/home/drovani/inavor-shuttle/`

### What You'll Build

```
Rovani Projects AWS Organization
├── Management Account (Billing & Organization Control)
├── Shared Services Account (CI/CD, Monitoring)
├── Security Account (CloudTrail Logs, Compliance)
├── Inavor Shuttle - Dev (Development Environment)
├── Inavor Shuttle - Staging (Optional - Staging Environment)
└── Inavor Shuttle - Prod (Optional - Production Environment)
```

### Expected Costs

**Development Phase (First 3 Months)**:
- DynamoDB (on-demand): ~$5-10/month
- S3 (CloudTrail logs): ~$1-3/month
- CloudWatch Logs: ~$2-5/month
- **Total**: ~$8-18/month (covered by AWS Free Tier)

---

## Phase 1: AWS Organization Setup

### Step 1.1: Create AWS Root Account

1. Go to **https://aws.amazon.com**
2. Click **Create an AWS Account**
3. Follow the registration process:
   - **Email**: Use organization email (e.g., `admin@rovaniprojects.com`)
   - **Account Name**: `Rovani-Projects-Root`
   - **Region**: `us-east-2`
   - **Credit Card**: Provide valid payment method
   - **Identity Verification**: Complete phone verification
   - **Support Plan**: Choose **Business** (recommended for production)

### Step 1.2: Secure the Root Account with MFA

1. Navigate to **https://console.aws.amazon.com**
2. Sign in with your root credentials
3. Click your account name (top-right) → **Security Credentials**
4. Scroll to **Multi-Factor Authentication (MFA)**
5. Click **Assign MFA device**
6. Choose **Virtual authenticator app** (Google Authenticator, Authy, etc.)
7. Scan the QR code and save backup codes in a secure location
8. Complete MFA setup

### Step 1.3: Enable AWS Organization

1. In AWS Console, search for **AWS Organizations**
2. Click **Create an organization**
3. Choose **All features** (not just consolidated billing)
4. Accept terms and create organization
5. Verify: You should see your root account listed as the **Management Account**

### Step 1.4: Enable Organization-Wide CloudTrail Logging

1. Search for **CloudTrail** in AWS Console
2. Click **Trails** (left sidebar)
3. Click **Create trail**
4. Configure:
   - **Trail name**: `OrganizationTrail`
   - **Storage location**: Create new S3 bucket (use default name)
   - **Log file validation**: ✅ Enabled
   - **CloudWatch Logs**: ✅ Enabled (create new log group)
5. Check: **Enable for all accounts in my organization** ✅
6. Click **Create trail**

**Result**: All AWS API calls across your organization are now logged for audit purposes.

---

## Phase 2: Developer Access & Authentication

### Step 2.1: Create Additional AWS Accounts

From your Management Account, create these accounts:

#### Shared Services Account
1. Go to **AWS Organizations** → **AWS Accounts**
2. Click **Create an AWS account**
3. Configure:
   - **Email**: `shared-services@rovaniprojects.com`
   - **Account name**: `Shared-Services`
4. Click **Create** (wait 2-3 minutes)

#### Security Account
1. Repeat process:
   - **Email**: `security@rovaniprojects.com`
   - **Account name**: `Security`

#### Inavor Shuttle - Dev Account
1. Repeat process:
   - **Email**: `inavor-shuttle-dev@rovaniprojects.com`
   - **Account name**: `InavorShuttle-Dev`
2. **Save the Account ID** (12-digit number) - you'll need this later

#### Optional: Staging & Production Accounts
1. Create `InavorShuttle-Staging` with email `inavor-shuttle-staging@rovaniprojects.com`
2. Create `InavorShuttle-Prod` with email `inavor-shuttle-prod@rovaniprojects.com`

**Result**: You now have a multi-account organization with complete isolation between environments.

### Step 2.2: Set Up IAM Identity Center (SSO)

This allows developers to log in once and access all accounts without managing individual IAM users.

1. In Management Account, search for **IAM Identity Center**
2. Click **Enable IAM Identity Center**
3. Choose region: `us-east-2`
4. Accept terms and enable (wait 5-10 minutes)

### Step 2.3: Create Identity Center Users

1. Go to **IAM Identity Center** → **Users**
2. Click **Create user**
3. For each developer, configure:
   - **Username**: `john.doe` (or developer name)
   - **Email**: `john@rovaniprojects.com`
   - **First/Last name**: Populate
   - **Send email invitation**: Yes
4. Click **Create user**

**Important**: Save the Identity Center portal URL (appears on Identity Center dashboard - looks like `https://d-123456789.awsapps.com/start`)

### Step 2.4: Set Up Permission Sets

Permission Sets define what developers can do in each account.

1. Go to **IAM Identity Center** → **Permission sets**
2. Click **Create permission set**
3. Create **DeveloperAccess**:
   - **Name**: `DeveloperAccess`
   - **Session duration**: 1 hour
   - **Attach policy**: `AdministratorAccess`
   - Click **Create**

4. Create **ReadOnlyAccess** (optional for production viewers):
   - **Name**: `ReadOnlyAccess`
   - **Attach policy**: `ReadOnlyAccess`
   - Click **Create**

### Step 2.5: Assign Account Access to Users

1. Go to **IAM Identity Center** → **AWS accounts**
2. Click **InavorShuttle-Dev**
3. Click **Assign users**
4. Check your username
5. Select permission set: `DeveloperAccess`
6. Click **Submit**

**Repeat for other environments** as needed.

**Result**: Developers can now log in to the Identity Center portal and access assigned accounts with appropriate permissions.

---

## Phase 3: Local Development Environment

### Step 3.1: Install AWS CLI v2

The AWS CLI allows you to manage AWS from the terminal.

**macOS**:
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux (Ubuntu/Debian)**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**: Download https://awscli.amazonaws.com/AWSCLIV2.msi

**Verify**:
```bash
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x ...
```

### Step 3.2: Install AWS CDK

AWS CDK is the Infrastructure as Code tool for deploying infrastructure.

```bash
npm install -g aws-cdk
cdk --version
# Expected: 2.x.x
```

### Step 3.3: Fix the AWS CLI SSO Configuration

The AWS CLI config file may have an incorrect SSO start URL. Fix it now:

1. Open `~/.aws/config` in your editor
2. Find the `[sso-session rovani]` section
3. Update the `sso_start_url` to your Identity Center portal URL:
   ```
   [sso-session rovani]
   sso_start_url = https://rovaniprojects.awsapps.com/start
   sso_region = us-east-2
   sso_registration_scopes = sso:account:access
   ```

### Step 3.4: Configure AWS CLI with Identity Center

1. Authenticate with SSO:
   ```bash
   aws sso login --profile inavor-dev
   ```

2. A browser window will open. Log in with your Identity Center credentials.

3. Return to terminal and verify access:
   ```bash
   aws sts get-caller-identity --profile inavor-dev
   ```

**Expected output**:
```json
{
    "UserId": "AROA4W6QJLRG7VTGVZV7W:username",
    "Account": "873925794893",
    "Arn": "arn:aws:sts::873925794893:assumed-role/AWSReservedSSO_AdministratorAccess_xxxxx/username"
}
```

### Step 3.5: Update AWS CLI Profiles

Edit `~/.aws/config` to ensure all profiles point to the correct account IDs:

```ini
[sso-session rovani]
sso_start_url = https://rovaniprojects.awsapps.com/start
sso_region = us-east-2
sso_registration_scopes = sso:account:access

[profile default]
sso_session = rovani
sso_account_id = 866253419755
sso_role_name = DeveloperAccess
region = us-east-2
output = json

[profile inavor-dev]
sso_session = rovani
sso_account_id = 873925794893
sso_role_name = AdministratorAccess
region = us-east-2
output = json

[profile inavor-staging]
sso_session = rovani
sso_account_id = 855025371279
sso_role_name = DeveloperAccess
region = us-east-2
output = json

[profile inavor-prod]
sso_session = rovani
sso_account_id = 256547294520
sso_role_name = ReadOnlyAccess
region = us-east-2
output = json
```

**Note**: Replace account IDs with your actual account IDs.

---

## Phase 4: Infrastructure Deployment

### Step 4.1: Update CDK Configuration

1. Navigate to the project CDK directory:
   ```bash
   cd /home/drovani/inavor-shuttle/cdk
   ```

2. Update `.env` file with your actual account IDs:
   ```bash
   # File: cdk/.env
   ORGANIZATION_MANAGEMENT_ACCOUNT_ID=866253419755
   ORGANIZATION_SHARED_SERVICES_ACCOUNT_ID=778948804868
   ORGANIZATION_SECURITY_ACCOUNT_ID=060351707639

   AWS_REGION=us-east-2

   INAVOR_SHUTTLE_DEV_ACCOUNT_ID=873925794893
   INAVOR_SHUTTLE_STAGING_ACCOUNT_ID=855025371279
   INAVOR_SHUTTLE_PROD_ACCOUNT_ID=256547294520

   INAVOR_SHUTTLE_ENVIRONMENT=dev

   PROJECT_NAME=inavor-shuttle
   COST_CENTER=engineering
   TEAM=platform
   CLIENT=internal
   ```

### Step 4.2: Bootstrap CDK (One-Time Setup)

CDK requires a one-time bootstrap in each account to set up CloudFormation resources.

```bash
export AWS_PROFILE=inavor-dev
cdk bootstrap
```

### Step 4.3: Deploy Infrastructure

Deploy the DynamoDB tables, S3 buckets, SQS queues, and IAM roles:

```bash
export AWS_PROFILE=inavor-dev
cdk deploy InavorShuttle-dev --require-approval never
```

**Expected output** (takes 2-5 minutes):
```
✅  InavorShuttle-dev

Outputs:
InavorShuttle-dev.ShopsTableName = InavorShuttle-dev-shops
InavorShuttle-dev.JobsTableName = InavorShuttle-dev-jobs
InavorShuttle-dev.ImportHistoryTableName = InavorShuttle-dev-import-history
InavorShuttle-dev.LambdaExecutionRoleArn = arn:aws:iam::873925794893:role/InavorShuttle-dev-lambda-execution-role
InavorShuttle-dev.AppRunnerExecutionRoleArn = arn:aws:iam::873925794893:role/InavorShuttle-dev-apprunner-execution-role
```

---

## Phase 5: Verification & Testing

### Step 5.1: Verify DynamoDB Tables

```bash
export AWS_PROFILE=inavor-dev

# List all tables
aws dynamodb list-tables

# Expected output:
# {
#     "TableNames": [
#         "InavorShuttle-dev-import-history",
#         "InavorShuttle-dev-jobs",
#         "InavorShuttle-dev-shops"
#     ]
# }
```

### Step 5.2: Verify Table Configuration

```bash
export AWS_PROFILE=inavor-dev

# Check ShopsTable
aws dynamodb describe-table --table-name InavorShuttle-dev-shops \
  --query 'Table.{Status:TableStatus,BillingMode:BillingModeSummary.BillingMode,PITR:PointInTimeRecoveryDescription.PointInTimeRecoveryStatus}'

# Check JobsTable with Global Secondary Indexes
aws dynamodb describe-table --table-name InavorShuttle-dev-jobs \
  --query 'Table.{Status:TableStatus,GSIs:GlobalSecondaryIndexes[*].IndexName,TTL:TimeToLiveDescription.AttributeName}'
```

**Expected**:
- Status: `ACTIVE`
- Billing Mode: `PAY_PER_REQUEST`
- PITR: `ENABLED`
- JobsTable GSIs: `shopDomain-createdAt-index`, `status-createdAt-index`
- TTL: `expiresAt`

### Step 5.3: Verify IAM Roles

```bash
export AWS_PROFILE=inavor-dev

aws iam list-roles --query 'Roles[?contains(RoleName, `InavorShuttle-dev`)].RoleName'

# Expected output:
# [
#     "InavorShuttle-dev-apprunner-execution-role",
#     "InavorShuttle-dev-lambda-execution-role"
# ]
```

### Step 5.4: Verify CloudFormation Stack

```bash
export AWS_PROFILE=inavor-dev

aws cloudformation describe-stacks --stack-name InavorShuttle-dev \
  --query 'Stacks[0].{Status:StackStatus,CreatedTime:CreationTime}'

# Expected Status: CREATE_COMPLETE
```

### Step 5.5: Test DynamoDB Operations

**Insert test data**:
```bash
export AWS_PROFILE=inavor-dev

aws dynamodb put-item \
  --table-name InavorShuttle-dev-shops \
  --item '{
    "domain": {"S": "test-shop.myshopify.com"},
    "name": {"S": "Test Shop"},
    "plan": {"S": "FREE"},
    "billingStatus": {"S": "ACTIVE"},
    "installedAt": {"N": "1699564800000"},
    "createdAt": {"N": "1699564800000"},
    "updatedAt": {"N": "1699564800000"}
  }'
```

**Retrieve test data**:
```bash
aws dynamodb get-item \
  --table-name InavorShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'

# Expected: Returns the item you inserted
```

**Clean up**:
```bash
aws dynamodb delete-item \
  --table-name InavorShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'
```

---

## Troubleshooting

### "No access" / "ForbiddenException" when running AWS CLI commands

**Cause**: Your Identity Center user doesn't have permission to the account.

**Solution**:
1. Go to **IAM Identity Center** in AWS Console
2. Click **AWS accounts** → **InavorShuttle-Dev**
3. Click **Assign users** and assign yourself with `AdministratorAccess` permission set
4. Wait 5-10 minutes for permissions to propagate
5. Re-authenticate:
   ```bash
   aws sso logout --profile inavor-dev
   aws sso login --profile inavor-dev
   ```

### "Could not resolve host: d-ssoins-6684d3a599ba5927.awsapps.com"

**Cause**: Incorrect SSO start URL in `~/.aws/config`

**Solution**: Update `~/.aws/config` with the correct Identity Center portal URL:
```ini
[sso-session rovani]
sso_start_url = https://rovaniprojects.awsapps.com/start  # Use your actual portal URL
sso_region = us-east-2
```

### "Unable to assume role in target account"

**Cause**: CDK is trying to deploy to wrong account ID.

**Solution**:
1. Check `cdk/.env` has the correct account ID for `INAVOR_SHUTTLE_DEV_ACCOUNT_ID`
2. Verify with: `aws sts get-caller-identity --profile inavor-dev`
3. Update `.env` if needed and retry deployment

### "User is not authorized to perform: cloudformation:CreateStack"

**Cause**: Your Identity Center role doesn't have CloudFormation permissions.

**Solution**:
1. Ensure your permission set has `AdministratorAccess` (or includes CloudFormation permissions)
2. Go to **IAM Identity Center** → **Permission sets** → Select your permission set
3. Verify `AdministratorAccess` policy is attached
4. Re-authenticate and retry

### CDK deployment hangs or is very slow

**Cause**: Network issue or CloudFormation processing.

**Solution**:
1. Check CloudFormation console for stack events
2. Wait 5-10 minutes (CloudFormation can be slow)
3. If stuck for >15 minutes, cancel and check CloudFormation events:
   ```bash
   export AWS_PROFILE=inavor-dev
   aws cloudformation describe-stack-events --stack-name InavorShuttle-dev
   ```

---

## Next Steps

### After Successful Deployment

1. **Start Application Development**:
   ```bash
   cd /home/drovani/inavor-shuttle
   npm install
   npm run setup
   npm run dev
   ```

2. **Add More Developers**:
   - Create Identity Center users for each team member
   - Assign to developer groups with appropriate permissions
   - Share the Identity Center portal URL

3. **Create Staging & Production Accounts** (when ready):
   - Repeat Phase 1, Steps 2.1 for creating new accounts
   - Repeat Phase 2, Steps 2.5 for assigning access
   - Update CDK `.env` with new account IDs
   - Deploy: `cdk deploy InavorShuttle-staging`

4. **Set Up CI/CD** (future phase):
   - Configure GitHub Actions in Shared Services account
   - Use OIDC for secure credential-less deployments
   - Automate deployments on push to `main` branch

5. **Monitor Infrastructure**:
   - Review CloudTrail logs regularly
   - Check CloudWatch metrics for DynamoDB tables
   - Monitor spending in Billing and Cost Management

---

## Quick Reference: Common Commands

```bash
# Authenticate with SSO
aws sso login --profile inavor-dev

# Check who you are
aws sts get-caller-identity --profile inavor-dev

# List DynamoDB tables
aws dynamodb list-tables --profile inavor-dev

# Deploy infrastructure
cd /home/drovani/inavor-shuttle/cdk
export AWS_PROFILE=inavor-dev
cdk deploy InavorShuttle-dev --require-approval never

# Destroy infrastructure (for testing/cleanup)
cdk destroy InavorShuttle-dev

# Start development server
cd /home/drovani/inavor-shuttle
npm run dev
```

---

## Security Best Practices

✅ **DO**:
- Use Identity Center for all developer access
- Enable MFA on all user accounts
- Keep CloudTrail logging enabled
- Review CloudTrail logs regularly
- Use least-privilege IAM roles
- Rotate credentials every 90 days

❌ **DON'T**:
- Use root account for daily work
- Store AWS credentials in code or environment variables
- Share AWS access keys (use Identity Center instead)
- Enable public access to S3 buckets
- Disable CloudTrail logging

---

## Summary

**You've successfully set up**:
- ✅ AWS multi-account organization with 5+ accounts
- ✅ IAM Identity Center for centralized developer access
- ✅ AWS CLI configured with SSO authentication
- ✅ DynamoDB tables for shops, jobs, and import history
- ✅ IAM roles for Lambda and App Runner
- ✅ CloudTrail audit logging for compliance
- ✅ Development environment ready for application deployment

**Infrastructure is now ready for Phase 1 development work**.

---

**Document Version**: 1.0
**Last Updated**: 2025-11-13
**Status**: Complete - Start-to-Finish AWS Setup Guide
