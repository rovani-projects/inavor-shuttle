# AWS Infrastructure Setup Guide

**Organization**: Rovani Projects, Inc.
**Project**: Inavor Shuttle (Multi-Account Organization)
**Purpose**: Complete AWS Organization setup from scratch for multi-client, multi-developer environments
**Created**: 2025-11-10
**Updated**: 2025-11-12
**Status**: Multi-Account Organization Setup

---

## Overview

This guide walks through setting up a **production-grade AWS Organization** from the ground up, designed for a software agency managing multiple client projects. This enables multiple developers to work safely on different client projects while maintaining complete isolation, compliance, and cost tracking.

**Architecture You'll Create**:

```
Rovani Projects AWS Organization (admin@rovaniprojects.com)
├── Management Account
│   └── Billing, AWS Organization control, cross-account permissions
├── Shared Services Account
│   └── CI/CD pipelines, centralized monitoring, shared tools
├── Security Account
│   └── CloudTrail logs, AWS Config, compliance aggregation
├── Client A - Dev Account
├── Client A - Staging Account
├── Client A - Production Account
├── Client B - Dev Account
├── Client B - Staging Account
├── Client B - Production Account
└── Internal Projects Account
    └── Experiments, internal tools, Rovani-owned infrastructure
```

**What You'll Set Up**:

- AWS root account with appropriate security controls
- AWS Organization with multi-account structure
- IAM Identity Center for centralized developer access
- Security and Shared Services accounts
- Cross-account roles for secure developer access
- CloudTrail and CloudWatch Logs aggregation
- Cost allocation tags and consolidated billing
- AWS CLI and CDK installed and configured
- First client account with DynamoDB tables
- Verification of deployed resources and security

**Time Required**: 3-4 hours (first-time setup from scratch)

---

## Prerequisites

Before you begin, ensure you have:

- [ ] Email address for AWS root account (use org email like admin@rovaniprojects.com)
- [ ] Credit card on file (required for account activation)
- [ ] Phone number for identity verification
- [ ] Node.js 20.x or later installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] Terminal/command line access
- [ ] MFA device (phone with authenticator app like Google Authenticator or Authy)
- [ ] Basic understanding of AWS services and organizational structure

---

## Step 1: Create AWS Root Account

This is your organization's primary AWS account. Treat it carefully—you'll only use it for organization management and rarely for actual work.

### 1.1 Create the Root Account

1. Go to https://aws.amazon.com
2. Click "Create an AWS Account"
3. Follow the registration process:
   - **Email address**: Use organization email (e.g., `admin@rovaniprojects.com`)
   - **Account name**: `Rovani-Projects-Root` or your organization name
   - **AWS Region**: Choose primary region (e.g., `us-east-2`)
   - Enter credit card information (you'll qualify for free tier)
   - Verify identity via phone call
   - Select support plan: **Business** support recommended for production use

### 1.2 Sign in and Secure Root Account

1. Navigate to https://console.aws.amazon.com
2. Sign in with root credentials (email + password)
3. **Enable MFA on root account** (CRITICAL):
   - Click your account name (top-right) → **Security Credentials**
   - Scroll to "Multi-factor authentication (MFA)" section
   - Click **Assign MFA device**
   - Choose **Virtual authenticator app** (Google Authenticator, Authy, etc.)
   - Follow prompts to scan QR code and save backup codes
   - **WARNING**: Save backup codes in secure location (password manager)

### 1.3 Review Security Status

1. Go to **IAM** → **Dashboard**
2. Review "Security Status" checklist:
   - ✅ MFA enabled (just did this)
   - ✅ Root access keys deleted (delete if any exist)
   - ✅ Create individual IAM users
   - ✅ Use groups to assign permissions
   - ✅ Apply an IAM password policy
   - ✅ Enable CloudTrail

**Action**: Delete root access keys if any exist (never use them).

---

## Step 2: Set Up AWS Organization

AWS Organization allows you to manage multiple accounts as a single entity with consolidated billing.

### 2.1 Enable AWS Organization

1. In AWS Console, search for "AWS Organizations"
2. Click "Create an organization"
3. Choose **All features** (not just consolidated billing)
   - This gives you full organizational controls, SCPs (Service Control Policies), and more
4. Review terms and click "Create organization"

Expected: You'll see your root account listed as the **Management Account**

### 2.2 Create Organization Structure

You now have an "Organization" with your root account as the **Management Account**. Keep this account for organization and billing only—don't use it for development.

### 2.3 Enable CloudTrail for Organization

Centralized audit logging is critical for compliance and security.

1. In AWS Console, search for "CloudTrail"
2. Click **Trails** (left sidebar)
3. Click **Create trail**
4. Configure:
   - **Trail name**: `OrganizationTrail`
   - **Storage location**: Select "Create new S3 bucket"
   - **S3 bucket name**: `rovani-organization-cloudtrail-logs-{random}` (AWS will auto-generate a unique name—just use the default)
   - **Log file SSE-KMS encryption**: Leave **unchecked** (S3 encrypts automatically)
   - Under **Additional settings** (expand):
     - **Log file validation**: Check ✅ Enabled
     - **SNS notification delivery**: Leave unchecked (optional)
5. Click **Save Changes** to continue with CloudWatch Logs setup
6. Under **CloudWatch Logs**:
   - **Enabled**: Check ✅
   - **New or existing log group**: Select "New"
   - **Log group name**: `OrganizationTrail`
   - **IAM role**: Select "New"
   - **Role name**: `CloudTrailRoleForCloudWatchLogs`
7. Click **Save changes** to review
8. Check **Enable for all accounts in my organization**: ✅ Check this box
9. Click **Create trail**

This creates an audit log of all AWS API calls across your organization.

---

## ⚡ Automation: Steps 3-15 (Recommended)

**Rather than manually clicking through Steps 3-15, you can automate everything with scripts.**

### Quick Start (Automated)

After completing Steps 1-2 above, run:

```bash
cd scripts/aws-setup
./run-all.sh --dry-run    # Preview changes
./run-all.sh              # Execute automation
```

**Time**: 25-35 minutes (vs 45-60 minutes manual)
**Result**: All accounts, CloudTrail, Identity Center, CLI, and environment files configured

### What Gets Automated

| Step | Task                      | Time      | Automated            |
| ---- | ------------------------- | --------- | -------------------- |
| 3-5  | Create 5 AWS accounts     | 5-10 min  | ✅ Yes               |
| 6    | Identity Center setup     | 15-20 min | ⚠️ Interactive guide |
| 7-9  | AWS CLI + CDK bootstrap   | 2-3 min   | ✅ Yes               |
| 10   | Environment configuration | <1 min    | ✅ Yes               |

### Automation Prerequisites

```bash
# Install AWS CLI v2 (if not already installed)
# See: https://aws.amazon.com/cli/ - follow the steps for:
# 1. Complete all prerequisites (already done in above steps)
# 2. Installing or updating to the latest version of the AWS CLI
# 3. After you have access to the AWS CLI, configure your AWS CLI with your IAM credentials for first time use.

# Install jq (JSON processor)
brew install jq           # macOS
sudo apt-get install jq   # Ubuntu/Debian

# Authenticate with AWS (Management Account)
aws configure
# or
aws sso login --profile default
```

### Running the Automation Scripts

```bash
cd /home/drovani/inavor-shuttle/scripts/aws-setup

# Preview all changes (no changes made)
./run-all.sh --dry-run

# Execute the automation
./run-all.sh

# With specific region
./run-all.sh --region eu-west-1

# With Identity Center portal URL (to skip interactive prompts)
./run-all.sh --portal-url https://d-123456789.awsapps.com/start

# Get help
./run-all.sh --help
```

**Important Notes:**

- The automation is idempotent (safe to run multiple times)
- Existing resources are detected and skipped
- Identity Center setup requires manual AWS Console interaction (the script provides guided instructions)
- All generated `.env` files are gitignored

### What the Scripts Create

**5 AWS Accounts:**

- Shared-Services (CI/CD, monitoring)
- Security (CloudTrail, compliance)
- InavorShuttle-Dev (development)
- InavorShuttle-Staging (staging, optional)
- InavorShuttle-Prod (production, optional)

**Infrastructure:**

- CloudTrail organization-wide audit logging
- IAM Identity Center for SSO
- AWS CLI profiles for all accounts
- CDK bootstrap in all accounts

**Configuration Files (gitignored):**

- `.env.aws-accounts` - Account IDs
- `cdk/.env` - CDK variables
- `.env.local` - Application config
- `.github/deploy-secrets-guide.md` - CI/CD guide

### Full Documentation

For detailed information about the automation scripts, see:

- **Quick Start**: `docs/learning/QUICKSTART-AWS-SETUP.md`
- **Script Details**: `scripts/aws-setup/README.md`
- **Integration Guide**: `docs/learning/INTEGRATION-GUIDE.md`

---

### Manual Alternative (Steps 3-15 Below)

If you prefer to do this manually, follow the instructions below. Otherwise, **skip to "Step 16: Verify Everything Works"**.

---

## Step 3: Create Shared Services Account

The Shared Services account hosts CI/CD, monitoring, and centralized logging—shared infrastructure that all projects use.

### 3.1 Create the Account

From your Management Account:

1. Go to **AWS Organizations** → **AWS Accounts**
2. Click **Create an AWS account**
3. Configure:
   - **Email**: `shared-services@rovaniprojects.com`
   - **Account name**: `Shared-Services`
   - **Role name**: `OrganizationAccountAccessRole` (leave default)
4. Click **Create**

Wait 2-3 minutes for account creation.

### 3.2 Access the New Account

1. In Organizations, find the **Shared-Services** account ID (12-digit number)
2. Copy the account ID
3. Click your account name (top-right) → **Switch role**
4. Fill in:
   - **Account**: Paste the Shared Services account ID
   - **Role**: `OrganizationAccountAccessRole`
   - **Display name**: `Shared-Services`
5. Click **Switch role**

You're now in the Shared Services account. Set up an email/password for this account when you get the invitation email.

---

## Step 4: Create Security Account

The Security account is a centralized location for CloudTrail logs, AWS Config rules, and compliance scanning. All other accounts will forward their logs here.

### 4.1 Create the Account

From your Management Account:

1. Go to **AWS Organizations** → **AWS Accounts**
2. Click **Create an AWS account**
3. Configure:
   - **Email**: `security@rovaniprojects.com`
   - **Account name**: `Security`
   - **Role name**: `OrganizationAccountAccessRole`
4. Click **Create**

Wait 2-3 minutes for account creation.

### 4.2 Create CloudTrail S3 Bucket in Security Account

Switch to the Security account (same process as 3.2).

1. Go to **S3**
2. Click **Create bucket**
3. Configure:
   - **Bucket name**: `rovani-security-cloudtrail-{random}` (globally unique)
   - **Region**: Your primary region (e.g., `us-east-2`)
   - **Block Public Access**: Yes (keep all enabled)
4. Click **Create**

### 4.3 Add Bucket Policy

1. Click the bucket you just created
2. Go to **Permissions** tab
3. Click **Bucket Policy**
4. Paste this policy (replace `MANAGEMENT-ACCOUNT-ID` with your root account ID):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::rovani-security-cloudtrail-{random}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::rovani-security-cloudtrail-{random}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
```

5. Click **Save**

This allows CloudTrail from all accounts to write logs to this bucket.

---

## Step 5: Create Inavor Shuttle - Dev Account

Create a dedicated Dev account for the Inavor Shuttle project. Staging and Production accounts can be added later when you're ready to launch.

### 5.1 Create the Dev Account

From your Management Account:

1. Go to **AWS Organizations** → **AWS Accounts**
2. Click **Create an AWS account**
3. Configure:
   - **Email**: `inavor-shuttle-dev@rovaniprojects.com`
   - **Account name**: `InavorShuttle-Dev`
   - **Role name**: `OrganizationAccountAccessRole`
4. Click **Create**

Wait 2-3 minutes for the account to be created. Save the **Account ID** for this account (you'll need it in later steps).

**Note**: Staging and Production accounts can be created later when you're ready to deploy beyond development.

---

## Step 6: Set Up IAM Identity Center

IAM Identity Center (formerly AWS SSO) provides a single login portal for all developers to access the accounts they need, without managing individual IAM users in each account.

### 6.1 Enable Identity Center

From your Management Account:

1. Search for "IAM Identity Center"
2. Click **Enable IAM Identity Center**
3. Choose region: Select your primary region (e.g., `us-east-2`)
4. Review and accept terms

Wait 5-10 minutes for enablement.

### 6.2 Create Identity Center Users

1. Go back to **IAM Identity Center**
2. Click **Users** (left sidebar)
3. Click **Create user**
4. Configure for your first developer:
   - **Username**: `john.doe` (or your developer's name)
   - **Email**: `john@rovaniprojects.com`
   - **First/Last name**: Populate
   - Click **Next**
5. **Send email invitation**: Yes
6. Click **Create user**

Repeat for each developer on your team.

### 6.3 Create Groups

1. Click **Groups** (left sidebar)
2. Click **Create group**
3. Create groups:
   - **Group name**: `Developers`
   - **Description**: "Software developers—access to dev/staging accounts"
   - Click **Create group**
4. Add users: Check the developers you created
5. Repeat for other groups: `DevOps`, `Client-A-Team`, etc.

### 6.4 Set Up Permission Sets

Permission Sets define what actions users can perform in each account.

1. Click **Permission sets** (left sidebar)
2. Click **Create permission set**
3. Create for "Developer" users:
   - **Permission set name**: `DeveloperAccess`
   - **Session duration**: 1 hour
   - **Relay state**: Leave blank
   - Click **Next**
   - Choose **Attach AWS managed policies**:
     - `AdministratorAccess` (for dev environment)
   - Click **Create**

4. Repeat for restricted access:
   - **Permission set name**: `ReadOnlyAccess`
   - **AWS managed policies**: `ReadOnlyAccess`
   - Use for production readers (e.g., DevOps reviewing metrics)

### 6.5 Assign Accounts to Users/Groups

1. Click **AWS accounts** (left sidebar)
2. Click **InavorShuttle-Dev** account
3. Click **Assign users**
4. Select `Developers` group
5. Select permission set: `DeveloperAccess`
6. Click **Submit**

Also assign:

- **Shared-Services** account with `DevOps` group + `DeveloperAccess`

**Note**: Staging and Production account assignments can be added later when those accounts are created.

### 6.6 Get User Portal URL

1. Click **Dashboard** (left sidebar)
2. Copy the "AWS access portal URL" (something like `https://d-123456789.awsapps.com/start`)
3. Share this with your team

Developers will log in here with their Identity Center username/password and see the accounts they can access.

---

## Step 7: Install AWS CLI and Configure with Identity Center

Now set up your local development environment to access these accounts.

### 7.1 Install AWS CLI v2

**macOS**:

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux**:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**:
Download and run: https://awscli.amazonaws.com/AWSCLIV2.msi

### 7.2 Verify Installation

```bash
aws --version
# Expected output: aws-cli/2.x.x Python/3.x.x ...
```

### 7.3 Configure AWS CLI with Identity Center

1. Run:

```bash
aws configure sso
```

2. Answer prompts:
   - **SSO session name**: `rovani` (or your org name)
   - **SSO start URL**: Paste the portal URL from Step 6.6
   - **SSO region**: Your primary region (e.g., `us-east-2`)
   - **SSO registration scopes**: Leave blank (just press Enter)

3. Browser will open for login:
   - Sign in with your Identity Center credentials
   - Allow CLI access
   - Browser closes automatically

4. Back in terminal, answer remaining prompts:
   - **CLI default client Region**: `us-east-2`
   - **CLI default output format**: `json`
   - **CLI profile name**: `default` (or use descriptive name like `rovani-dev`)

### 7.4 Test CLI Access

```bash
# List who you are logged in as
aws sts get-caller-identity

# Expected output shows your account ID and assumed role
```

If successful, you're now authenticated via Identity Center!

### 7.5 Create CLI Profiles for Each Account

For easy switching between accounts, create named profiles:

```bash
# Edit ~/.aws/config to add profiles for each account
# (or run aws configure sso for each)

# Example ~/.aws/config:
[profile default]
sso_session = rovani
sso_account_id = 123456789012  # Management account ID
sso_role_name = DeveloperAccess
region = us-east-2
output = json

[profile inavor-dev]
sso_session = rovani
sso_account_id = 210987654321  # InavorShuttle-Dev account ID
sso_role_name = DeveloperAccess
region = us-east-2
output = json

[profile shared-services]
sso_session = rovani
sso_account_id = 321098765432  # Shared-Services account ID
sso_role_name = DeveloperAccess
region = us-east-2
output = json
```

Then use profiles:

```bash
# Set profile for a single command
aws sts get-caller-identity --profile inavor-dev

# Or set environment variable for all commands in a session
export AWS_PROFILE=inavor-dev
aws sts get-caller-identity
```

**Note**: Add profiles for `inavor-staging` and `inavor-prod` later when those accounts are created.

---

## Step 8: Install AWS CDK

AWS CDK is Infrastructure as Code tool for deploying your application infrastructure.

### 8.1 Install CDK CLI Globally

```bash
npm install -g aws-cdk
```

### 8.2 Verify Installation

```bash
cdk --version
# Expected: 2.x.x (build ...)
```

---

## Step 9: Bootstrap CDK in Each Account

CDK requires a one-time bootstrap to set up CloudFormation resources in each account.

### 9.1 Bootstrap Management Account

```bash
# Use your default profile (Management Account)
cdk bootstrap aws://MANAGEMENT-ACCOUNT-ID/us-east-2
```

### 9.2 Bootstrap Shared Services Account

```bash
export AWS_PROFILE=shared-services
cdk bootstrap aws://SHARED-SERVICES-ACCOUNT-ID/us-east-2
```

### 9.3 Bootstrap Client A - Dev Account

```bash
export AWS_PROFILE=client-a-dev
cdk bootstrap aws://CLIENT-A-DEV-ACCOUNT-ID/us-east-2
```

Repeat for Staging and Production accounts.

---

## Step 10: Configure Project Environment Variables

Set up the CDK project to know which accounts to deploy to.

### 10.1 Create .env File

```bash
cd /home/drovani/inavor-shuttle/cdk
cp .env.example .env
```

### 10.2 Edit .env File

```env
# Organization Configuration
ORGANIZATION_MANAGEMENT_ACCOUNT_ID=123456789012
ORGANIZATION_SHARED_SERVICES_ACCOUNT_ID=210987654321
ORGANIZATION_SECURITY_ACCOUNT_ID=321098765432

# Primary Region
AWS_REGION=us-east-2

# Inavor Shuttle - Dev Account
INAVOR_SHUTTLE_DEV_ACCOUNT_ID=111111111111
INAVOR_SHUTTLE_ENVIRONMENT=dev

# Optional: Override for specific deployment
# AWS_PROFILE=inavor-dev
```

**Note**: Add `INAVOR_SHUTTLE_STAGING_ACCOUNT_ID` and `INAVOR_SHUTTLE_PROD_ACCOUNT_ID` later when creating those accounts.

**Important**: Never commit `.env` to Git (it's in `.gitignore`)

---

## Step 11: Deploy DynamoDB Tables to Inavor Shuttle - Dev

Now deploy the infrastructure to the Inavor Shuttle dev account.

### 11.1 Ensure You're in the Right Account

```bash
export AWS_PROFILE=inavor-dev
aws sts get-caller-identity
# Verify account ID matches INAVOR_SHUTTLE_DEV_ACCOUNT_ID
```

### 11.2 Synthesize CloudFormation Template

```bash
cd /home/drovani/inavor-shuttle/cdk
cdk synth
```

Expected: Outputs a CloudFormation template in YAML format (no deployment yet).

### 11.3 Review Changes (Diff)

```bash
cdk diff InavorShuttle-dev
```

Expected output showing new resources to be created:

```
Stack InavorShuttle-dev
Resources
[+] AWS::DynamoDB::Table ShopsTable
[+] AWS::DynamoDB::Table JobsTable
[+] AWS::DynamoDB::Table ImportHistoryTable
[+] AWS::IAM::Role LambdaExecutionRole
[+] AWS::IAM::Role AppRunnerExecutionRole
```

### 11.4 Deploy to AWS

```bash
cdk deploy InavorShuttle-dev
```

You'll be prompted to approve IAM changes:

```
Do you wish to deploy these changes (y/n)? y
```

Type `y` and press Enter.

**Deployment process** (takes 2-5 minutes):

```
InavorShuttle-dev: deploying...
InavorShuttle-dev: creating CloudFormation changeset...

 ✅  InavorShuttle-dev

✨  Deployment time: 123.45s

Outputs:
InavorShuttle-dev.ShopsTableName = InavorShuttle-dev-shops
InavorShuttle-dev.ShopsTableArn = arn:aws:dynamodb:us-east-2:111111111111:table/InavorShuttle-dev-shops
InavorShuttle-dev.JobsTableName = InavorShuttle-dev-jobs
InavorShuttle-dev.JobsTableArn = arn:aws:dynamodb:us-east-2:111111111111:table/InavorShuttle-dev-jobs
...
```

Save these outputs for your application configuration.

---

## Step 12: Verify Deployed Resources

### 12.1 Verify DynamoDB Tables

```bash
export AWS_PROFILE=client-a-dev

# List all DynamoDB tables
aws dynamodb list-tables

# Describe the Shops table
aws dynamodb describe-table --table-name InavorShuttle-dev-shops

# Describe the Jobs table (with GSIs)
aws dynamodb describe-table --table-name InavorShuttle-dev-jobs
```

**What to verify**:

- ✅ Table status: `ACTIVE`
- ✅ Billing mode: `PAY_PER_REQUEST`
- ✅ Point-in-time recovery: `Enabled`
- ✅ Encryption: `Enabled` (AWS managed key)
- ✅ Jobs table has 2 GSIs: `shopDomain-createdAt-index` and `status-createdAt-index`
- ✅ Jobs and ImportHistory tables have TTL enabled

### 12.2 Verify via AWS Console

1. Go to https://console.aws.amazon.com
2. Switch to Client A - Dev account (use Identity Center portal)
3. Go to **DynamoDB** → **Tables**
4. You should see:
   - `InavorShuttle-dev-shops`
   - `InavorShuttle-dev-jobs`
   - `InavorShuttle-dev-import-history`
5. Click on `InavorShuttle-dev-jobs`
6. Click **Indexes** tab - verify 2 GSIs exist
7. Click **Additional settings** tab - verify TTL is enabled on `expiresAt`

### 12.3 Verify CloudFormation Stack

```bash
export AWS_PROFILE=client-a-dev

# Describe the stack
aws cloudformation describe-stacks --stack-name InavorShuttle-dev

# View stack resources
aws cloudformation list-stack-resources --stack-name InavorShuttle-dev
```

---

## Step 13: Test Basic Operations

### 13.1 Insert Test Data into Shops Table

```bash
export AWS_PROFILE=client-a-dev

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

### 13.2 Retrieve Test Data

```bash
aws dynamodb get-item \
  --table-name InavorShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'
```

Expected: Returns the item you just inserted

### 13.3 Insert Test Job

```bash
aws dynamodb put-item \
  --table-name InavorShuttle-dev-jobs \
  --item '{
    "jobId": {"S": "01HKJ2NDEKTSV4RRFFQ69G5FAV"},
    "shopDomain": {"S": "test-shop.myshopify.com"},
    "type": {"S": "IMPORT"},
    "status": {"S": "QUEUED"},
    "createdAt": {"N": "1699564800000"},
    "expiresAt": {"N": "1707340800000"}
  }'
```

### 13.4 Query Jobs by Shop (GSI Test)

```bash
aws dynamodb query \
  --table-name InavorShuttle-dev-jobs \
  --index-name shopDomain-createdAt-index \
  --key-condition-expression "shopDomain = :shopDomain" \
  --expression-attribute-values '{":shopDomain": {"S": "test-shop.myshopify.com"}}'
```

Expected: Returns the test job

### 13.5 Clean Up Test Data

```bash
# Delete test shop
aws dynamodb delete-item \
  --table-name InavorShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'

# Delete test job
aws dynamodb delete-item \
  --table-name InavorShuttle-dev-jobs \
  --key '{"jobId": {"S": "01HKJ2NDEKTSV4RRFFQ69G5FAV"}}'
```

---

## Step 14: Set Up Cost Allocation Tags

Cost allocation tags help you track spending per client and environment.

### 14.1 Create Tag Keys (Management Account)

1. Switch to **Management Account** (no profile or `export AWS_PROFILE=default`)
2. Go to **Billing and Cost Management** → **Cost Allocation Tags**
3. Click **Create new tags**
4. Add these tags:
   - **Tag key**: `client` (values: `ClientA`, `ClientB`, etc.)
   - **Tag key**: `environment` (values: `dev`, `staging`, `prod`)
   - **Tag key**: `team` (values: `platform`, `app`, `devops`)
   - **Tag key**: `cost-center` (values: your internal departments)
5. Click **Create tags**

### 14.2 Enable Tag Activation

1. Go to **Cost Allocation Tags**
2. Find the tags you just created (under "User-Defined" section)
3. Click **Activate** for each tag

Tags become available for cost allocation after 24 hours.

### 14.3 Apply Tags to Resources

When deploying infrastructure, add tags to all resources. Update your CDK code:

```typescript
// Example in your CDK stack
const shopsTable = new Table(this, "ShopsTable", {
  partitionKey: { name: "domain", type: AttributeType.STRING },
  // ... other config
  tags: {
    client: "ClientA",
    environment: "dev",
    team: "platform",
  },
});
```

---

## Step 15: Set Up Billing Alerts

Monitor spending to prevent surprise bills.

### 15.1 Enable Billing Alerts

From **Management Account**:

1. Go to **Billing and Cost Management** → **Billing Preferences**
2. Check:
   - ✅ "Receive Billing Alerts"
   - ✅ "Receive Free Tier Usage Alerts"
3. Click **Save preferences**

### 15.2 Create Budget Alert

1. Go to **Budgets**
2. Click **Create a budget**
3. Configure:
   - **Budget type**: Spending budget
   - **Budget name**: `monthly-limit`
   - **Budgeted amount**: $500 (or your limit)
   - **Time period**: Monthly
4. Click **Next**
5. Set alert threshold: 80% of budget ($400)
6. Add email: Your email address
7. Click **Create**

---

## Troubleshooting

### Issue: "Unable to locate credentials" with Identity Center

**Cause**: AWS CLI SSO session expired or not configured

**Solution**:

```bash
aws sso login --profile client-a-dev
# Browser opens for login, then your credentials are cached
```

### Issue: "User is not authorized to perform: dynamodb:\*"

**Cause**: Your Identity Center permission set doesn't include DynamoDB access

**Solution**:

1. Go to **IAM Identity Center**
2. Click **Permission sets** → Find the permission set
3. Add policy: `AmazonDynamoDBFullAccess`
4. Save and redeploy to the account

### Issue: CDK bootstrap fails with "Access Denied"

**Cause**: Identity Center session expired or no access to the account

**Solution**:

```bash
# Re-authenticate
aws sso login --profile client-a-dev

# Retry bootstrap
export AWS_PROFILE=client-a-dev
cdk bootstrap aws://ACCOUNT-ID/us-east-2
```

### Issue: DynamoDB tables show "Creating" for >5 minutes

**Cause**: AWS is provisioning (rare), or network issue

**Solution**: Check CloudFormation events:

```bash
export AWS_PROFILE=client-a-dev
aws cloudformation describe-stack-events --stack-name InavorShuttle-dev
```

---

## Cost Considerations

### Expected Monthly Costs (Phase 1 - Dev Only)

With the current setup (Management, Shared Services, Security, and Inavor Shuttle Dev accounts):

- **DynamoDB (on-demand)**: ~$5-10/month (dev account, minimal usage)
- **S3 (CloudTrail logs)**: ~$1-3/month (centralized in Security account)
- **CloudWatch Logs**: ~$2-5/month (across all accounts)
- **Identity Center**: $0 (included with AWS Organizations)
- **Total**: ~$8-18/month

Costs will increase as you add Staging and Production accounts later.

### Cost Optimization

1. **Use Free Tier**:
   - DynamoDB: 25 GB storage free (first 12 months)
   - S3: 5 GB storage free (first 12 months)
   - CloudWatch: 10 GB logs free per month

2. **Delete unused resources**:

   ```bash
   # Destroy a stack when no longer needed
   export AWS_PROFILE=inavor-dev
   cdk destroy InavorShuttle-dev
   ```

3. **Monitor with Budgets**:
   - Set alerts at 50%, 80%, 100% of budgeted amount
   - Review monthly bills in **Billing and Cost Management**

4. **Right-size instances**:
   - Start with on-demand DynamoDB, switch to provisioned if predictable load
   - Use Savings Plans for compute-heavy workloads

---

## Adding Staging and Production Accounts (Later)

When you're ready to launch beyond development, follow this checklist for Staging and Production:

### Checklist for Adding New Environments

1. **Create accounts in AWS Organizations** (refer to Step 5)
   - Create `InavorShuttle-Staging` with email `inavor-shuttle-staging@rovaniprojects.com`
   - Create `InavorShuttle-Prod` with email `inavor-shuttle-prod@rovaniprojects.com`

2. **Assign to developers via Identity Center** (refer to Step 6.5)
   - Assign `InavorShuttle-Staging` to Developers group with `DeveloperAccess`
   - Assign `InavorShuttle-Prod` to appropriate group with `ReadOnlyAccess` or custom restricted role

3. **Create CLI profiles** (refer to Step 7.5)
   - Add `[profile inavor-staging]` section to `~/.aws/config`
   - Add `[profile inavor-prod]` section to `~/.aws/config`

4. **Bootstrap CDK in each account** (refer to Step 9)
   - Run CDK bootstrap for staging account
   - Run CDK bootstrap for prod account

5. **Update .env file** (refer to Step 10.2)
   - Add `INAVOR_SHUTTLE_STAGING_ACCOUNT_ID`
   - Add `INAVOR_SHUTTLE_PROD_ACCOUNT_ID`

6. **Deploy infrastructure**
   - Run `cdk deploy` for staging and production environments

---

## Onboarding New Developers

When adding a new developer to your team:

1. **Create Identity Center user**:
   - Go to **IAM Identity Center** → **Users** → **Create user**
   - Provide email and name

2. **Add to groups**:
   - Assign to `Developers` group (or `DevOps` if needed)

3. **Share access portal URL**:
   - https://d-123456789.awsapps.com/start (from Identity Center dashboard)

4. **Developer configures CLI**:
   - Run `aws configure sso` with the portal URL
   - Creates profiles in `~/.aws/config`

5. **Developer gains access**:
   - Can now use `aws` commands with `--profile` flag
   - Can access AWS Console via Identity Center portal

---

## Security Best Practices

### Don't Do

- ❌ Never use root account for day-to-day work
- ❌ Never store AWS credentials in code or .env files
- ❌ Never share access keys (use Identity Center instead)
- ❌ Never enable public access to S3 buckets

### Do

- ✅ Use Identity Center for all developer access
- ✅ Enable MFA on all user accounts
- ✅ Enable CloudTrail for audit logging
- ✅ Use least-privilege IAM roles
- ✅ Rotate credentials every 90 days
- ✅ Use AWS Secrets Manager for application secrets

---

## Next Steps

After completing this guide:

1. **Use Automation (Recommended)**:
   - If you used scripts: Skip to step 3 below
   - If you did manual setup: Run `scripts/aws-setup/run-all.sh` to fill in any missing pieces

2. **Deploy Application Infrastructure**:

   ```bash
   npm install -g aws-cdk
   cd cdk
   npm install
   cdk deploy InavorShuttle-dev
   ```

3. **Start Development**:

   ```bash
   npm install
   npm run setup
   npm run dev
   ```

4. **Add More Developers**:
   - Create Identity Center users
   - Assign to groups (Developers, DevOps, etc.)
   - Share portal URL

5. **Create More Accounts** (Later):
   - Repeat Step 5 to create Staging/Production accounts
   - Use `scripts/aws-setup/setup.sh --skip-accounts` to automate the rest

6. **Proceed to Phase 1 Infrastructure Issues**:
   - Issue #4: S3 Bucket Setup (PHASE-1-INFRA-003)
   - Issue #5: SQS Queue Setup (PHASE-1-INFRA-004)
   - Issue #6: Lambda Function Setup (PHASE-1-JOB-001)

7. **Set up CI/CD** (Future):
   - Configure GitHub Actions in Shared Services account
   - Use OIDC for secure credential-free deployments
   - Deploy on push to `main` branch

8. **Monitor and Optimize**:
   - Review monthly bills in Billing and Cost Management
   - Check CloudTrail logs in Security account
   - Update permission sets as needed

---

## Additional Resources

### Automation Scripts

- **Scripts Directory**: `scripts/aws-setup/`
- **Main Script**: `scripts/aws-setup/run-all.sh` (execute this)
- **Script Documentation**: `scripts/aws-setup/README.md`

### Automation Documentation

- **Quick Start**: `docs/learning/QUICKSTART-AWS-SETUP.md`
- **Integration Guide**: `docs/learning/INTEGRATION-GUIDE.md`
- **Summary**: `docs/learning/AWS-AUTOMATION-SUMMARY.txt`

### Project Documentation

- Database Schema: `/docs/database-schema.md`
- Comprehensive Plan: `/docs/comprehensive-implementation-plan.md`
- Phase 1 Issues: `/docs/phase-1-issues-summary.md`

### AWS Documentation

- [AWS Organizations](https://docs.aws.amazon.com/organizations/)
- [IAM Identity Center](https://docs.aws.amazon.com/singlesignon/)
- [AWS CDK Developer Guide](https://docs.aws.amazon.com/cdk/)
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/dynamodb/)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [CloudTrail User Guide](https://docs.aws.amazon.com/awscloudtrail/)

### Support

- AWS Support: https://console.aws.amazon.com/support/
- AWS Community Forums: https://forums.aws.amazon.com/
- Stack Overflow (tag: amazon-web-services): https://stackoverflow.com/

---

## Checklist: Complete Setup

Before proceeding to application development, confirm:

**AWS Organization & Security**:

- [ ] AWS root account created with MFA enabled
- [ ] AWS Organization enabled with "All features"
- [ ] CloudTrail enabled for organization-wide audit logging
- [ ] Security account created with CloudTrail S3 bucket

**Shared Infrastructure**:

- [ ] Shared Services account created
- [ ] Identity Center enabled in Management Account
- [ ] Identity Center users created for all developers
- [ ] Developer groups created and configured
- [ ] Permission sets created (DeveloperAccess, ReadOnlyAccess, etc.)

**Project Accounts**:

- [ ] InavorShuttle-Dev account created and bootstrapped
- [ ] InavorShuttle-Dev assigned in Identity Center for team access

**CLI & Local Setup**:

- [ ] AWS CLI v2 installed (`aws --version` works)
- [ ] AWS CLI configured with Identity Center (`aws sso login --profile client-a-dev`)
- [ ] AWS profiles created in `~/.aws/config` for each account
- [ ] AWS CDK installed globally (`cdk --version` works)
- [ ] CDK bootstrapped in all three client accounts

**Infrastructure Deployed**:

- [ ] `.env` file configured in `cdk/` directory
- [ ] DynamoDB tables deployed to Client A - Dev (`cdk deploy` succeeded)
- [ ] DynamoDB tables verified (tables exist and are ACTIVE)
- [ ] IAM roles created for Lambda and App Runner
- [ ] CloudFormation stack shows `CREATE_COMPLETE` status

**Cost & Monitoring**:

- [ ] Cost allocation tags created and activated
- [ ] Billing alerts enabled
- [ ] Budget created with alerts at 80% threshold
- [ ] CloudTrail logs aggregated in Security account

**Documentation**:

- [ ] Team shared with IAM Identity Center portal URL
- [ ] AWS account IDs documented and accessible to team
- [ ] CLI profile names consistent across team
- [ ] Onboarding process documented for new developers

If all checkboxes are complete, you're ready to proceed with application development! 🚀

---

**Document Version**: 2.0.0 (Multi-Account Organization)
**Last Updated**: 2025-11-12
**Status**: Complete multi-account organization setup
**Related Issues**: #2 (PHASE-1-INFRA-001), #3 (PHASE-1-INFRA-002)
