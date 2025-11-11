# AWS Infrastructure Setup Guide

**Project**: Inavor Shuttle
**Purpose**: Manual steps to configure a production-ready AWS environment for Phase 1 infrastructure
**Created**: 2025-11-10
**Status**: Phase 1 - DynamoDB Tables (Issue #3)

---

## Overview

This guide walks through the manual steps required to set up an AWS environment for deploying and testing the Inavor Shuttle application infrastructure. Follow these steps sequentially to establish a working AWS deployment pipeline.

**What You'll Set Up**:
- AWS account with appropriate IAM permissions
- AWS CLI installed and configured
- AWS CDK installed and bootstrapped
- Environment variables for deployment
- DynamoDB tables deployed to AWS
- Verification of deployed resources

**Time Required**: 30-60 minutes (first-time setup)

---

## Prerequisites

Before you begin, ensure you have:
- [ ] An AWS account (create one at https://aws.amazon.com if needed)
- [ ] Credit card on file with AWS (required for account activation)
- [ ] Node.js 20.x or later installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] Terminal/command line access
- [ ] Basic understanding of AWS services

---

## Step 1: AWS Account Setup

### 1.1 Create AWS Account (if needed)

If you don't have an AWS account:

1. Go to https://aws.amazon.com
2. Click "Create an AWS Account"
3. Follow the registration process:
   - Provide email address and account name
   - Enter credit card information (free tier available)
   - Verify identity via phone
   - Select support plan (Basic/Free is sufficient)

### 1.2 Sign in to AWS Console

1. Navigate to https://console.aws.amazon.com
2. Sign in with your root account credentials
3. **Important**: Enable MFA (Multi-Factor Authentication) on root account:
   - Go to IAM → Dashboard → Security Status
   - Click "Activate MFA on your root account"
   - Follow instructions to set up authenticator app

### 1.3 Choose Your AWS Region

Select a region closest to you or your target users:
- **US East (N. Virginia)**: `us-east-1` (default in project)
- **US West (Oregon)**: `us-west-2`
- **EU (Ireland)**: `eu-west-1`
- **Asia Pacific (Sydney)**: `ap-southeast-2`

**Note**: All resources will be created in this region. The project defaults to `us-east-1`.

---

## Step 2: IAM User Creation

**Important**: Never use your root account for day-to-day operations.

### 2.1 Create IAM User for Deployments

1. In AWS Console, navigate to **IAM** (Identity and Access Management)
2. Click **Users** → **Add users**
3. Configure user:
   - **User name**: `inavor-shuttle-deploy` (or your preferred name)
   - **Access type**: Select "Programmatic access" (for AWS CLI/CDK)
   - Click **Next: Permissions**

### 2.2 Attach Policies

For development/testing, attach these managed policies:
- [x] `AdministratorAccess` (full access - **use only for dev/testing**)

For production, use more restrictive policies:
- [x] `AmazonDynamoDBFullAccess`
- [x] `AmazonS3FullAccess`
- [x] `AWSLambda_FullAccess`
- [x] `AmazonSQSFullAccess`
- [x] `AWSAppRunnerFullAccess`
- [x] `IAMFullAccess` (for CDK to create roles)
- [x] `AWSCloudFormationFullAccess` (CDK uses CloudFormation)

**Recommendation for Phase 1**: Start with `AdministratorAccess` for development, then lock down permissions after confirming the deployment works.

### 2.3 Save Access Keys

1. Click **Next** through tags (optional)
2. Click **Create user**
3. **CRITICAL**: Download the CSV with:
   - Access Key ID (e.g., `AKIAIOSFODNN7EXAMPLE`)
   - Secret Access Key (e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
4. Save this file securely (e.g., password manager)
5. **Warning**: You can't view the secret key again after this step

---

## Step 3: Install AWS CLI

The AWS CLI is required for CDK and for manual verification of deployed resources.

### 3.1 Install AWS CLI v2

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
Download and run the installer from:
https://awscli.amazonaws.com/AWSCLIV2.msi

### 3.2 Verify Installation

```bash
aws --version
# Expected output: aws-cli/2.x.x Python/3.x.x ...
```

---

## Step 4: Configure AWS CLI

### 4.1 Run AWS Configure

```bash
aws configure
```

You'll be prompted for:

1. **AWS Access Key ID**: Paste from Step 2.3
   ```
   AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
   ```

2. **AWS Secret Access Key**: Paste from Step 2.3
   ```
   AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

3. **Default region name**: Enter your chosen region
   ```
   Default region name [None]: us-east-1
   ```

4. **Default output format**: Use `json`
   ```
   Default output format [None]: json
   ```

### 4.2 Verify Configuration

```bash
# Test credentials
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/inavor-shuttle-deploy"
}
```

If you see your account details, your CLI is configured correctly.

### 4.3 Save Your AWS Account ID

You'll need this for CDK deployment. From the output above, save:
```
AWS Account ID: 123456789012
```

---

## Step 5: Install AWS CDK

### 5.1 Install CDK CLI Globally

```bash
npm install -g aws-cdk
```

### 5.2 Verify Installation

```bash
cdk --version
# Expected: 2.x.x (build ...)
```

---

## Step 6: Bootstrap CDK in Your AWS Account

CDK requires a one-time bootstrap process to set up resources in your AWS account.

### 6.1 Bootstrap CDK

```bash
# From the project root directory
cd /home/drovani/inavor-shuttle/cdk

# Bootstrap CDK (replace with your account ID and region)
cdk bootstrap aws://123456789012/us-east-1
```

**What this does**:
- Creates an S3 bucket for CDK assets (templates, Lambda code, etc.)
- Creates IAM roles for CloudFormation to assume during deployments
- Sets up ECR repository for container images (if needed)

Expected output:
```
 ⏳  Bootstrapping environment aws://123456789012/us-east-1...
 ✅  Environment aws://123456789012/us-east-1 bootstrapped
```

### 6.2 Verify Bootstrap

```bash
# List CloudFormation stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE

# You should see a stack named "CDKToolkit"
```

---

## Step 7: Configure Environment Variables

### 7.1 Create .env File in CDK Directory

```bash
cd /home/drovani/inavor-shuttle/cdk
```

Create a `.env` file (if it doesn't exist):

```bash
cp .env.example .env
```

### 7.2 Edit .env File

Open `.env` and configure:

```env
# AWS Configuration
AWS_ACCOUNT_ID=123456789012        # Your AWS account ID from Step 4.2
AWS_REGION=us-east-1               # Your chosen region
ENVIRONMENT=dev                     # Environment name (dev, staging, prod)

# Optional: If not set, CDK will use CLI credentials
# AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
# AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Important**: Never commit `.env` to Git (it's already in `.gitignore`)

---

## Step 8: Deploy DynamoDB Tables

Now you're ready to deploy the infrastructure from Issue #3!

### 8.1 Synthesize CloudFormation Template

This generates the CloudFormation template without deploying:

```bash
cd /home/drovani/inavor-shuttle/cdk
cdk synth
```

Expected output: A large CloudFormation template in YAML format

**What to look for**:
- `AWS::DynamoDB::Table` resources for Shops, Jobs, ImportHistory
- `AWS::IAM::Role` resources for Lambda and App Runner
- No errors or warnings

### 8.2 Review Changes (Diff)

See what resources will be created:

```bash
cdk diff InavoreShuttle-dev
```

Expected output:
```
Stack InavoreShuttle-dev
IAM Statement Changes
┌───┬─────────────────────────────────┬────────┬────────────────┐
│   │ Resource                        │ Effect │ Action         │
├───┼─────────────────────────────────┼────────┼────────────────┤
│ + │ ${ShopsTable.Arn}              │ Allow  │ dynamodb:*     │
│ + │ ${JobsTable.Arn}               │ Allow  │ dynamodb:*     │
└───┴─────────────────────────────────┴────────┴────────────────┘
Resources
[+] AWS::DynamoDB::Table ShopsTable
[+] AWS::DynamoDB::Table JobsTable
[+] AWS::DynamoDB::Table ImportHistoryTable
[+] AWS::IAM::Role LambdaExecutionRole
[+] AWS::IAM::Role AppRunnerExecutionRole
```

### 8.3 Deploy to AWS

```bash
cdk deploy InavoreShuttle-dev
```

You'll be prompted to approve IAM changes:
```
Do you wish to deploy these changes (y/n)? y
```

Type `y` and press Enter.

**Deployment process** (takes 2-5 minutes):
```
InavoreShuttle-dev: deploying...
InavoreShuttle-dev: creating CloudFormation changeset...

 ✅  InavoreShuttle-dev

✨  Deployment time: 123.45s

Outputs:
InavoreShuttle-dev.ShopsTableName = InavoreShuttle-dev-shops
InavoreShuttle-dev.ShopsTableArn = arn:aws:dynamodb:us-east-1:123456789012:table/InavoreShuttle-dev-shops
InavoreShuttle-dev.JobsTableName = InavoreShuttle-dev-jobs
InavoreShuttle-dev.JobsTableArn = arn:aws:dynamodb:us-east-1:123456789012:table/InavoreShuttle-dev-jobs
InavoreShuttle-dev.ImportHistoryTableName = InavoreShuttle-dev-import-history
InavoreShuttle-dev.ImportHistoryTableArn = arn:aws:dynamodb:us-east-1:123456789012:table/InavoreShuttle-dev-import-history
InavoreShuttle-dev.LambdaExecutionRoleArn = arn:aws:iam::123456789012:role/InavoreShuttle-dev-lambda-execution-role
InavoreShuttle-dev.AppRunnerExecutionRoleArn = arn:aws:iam::123456789012:role/InavoreShuttle-dev-apprunner-execution-role

Stack ARN:
arn:aws:cloudformation:us-east-1:123456789012:stack/InavoreShuttle-dev/...
```

Save these outputs - you'll need them for application configuration.

---

## Step 9: Verify Deployed Resources

### 9.1 Verify DynamoDB Tables via CLI

Check that tables were created:

```bash
# List all DynamoDB tables
aws dynamodb list-tables

# Describe Shops table
aws dynamodb describe-table --table-name InavoreShuttle-dev-shops

# Describe Jobs table (with GSIs)
aws dynamodb describe-table --table-name InavoreShuttle-dev-jobs

# Describe Import History table
aws dynamodb describe-table --table-name InavoreShuttle-dev-import-history
```

**What to verify**:
- [x] Table status: `ACTIVE`
- [x] Billing mode: `PAY_PER_REQUEST`
- [x] Point-in-time recovery: `Enabled`
- [x] Encryption: `Enabled` (AWS managed key)
- [x] Jobs table has 2 GSIs: `shopDomain-createdAt-index` and `status-createdAt-index`
- [x] Jobs and ImportHistory have TTL enabled

### 9.2 Verify via AWS Console

1. Go to AWS Console → **DynamoDB** → **Tables**
2. You should see:
   - `InavoreShuttle-dev-shops`
   - `InavoreShuttle-dev-jobs`
   - `InavoreShuttle-dev-import-history`
3. Click on `InavoreShuttle-dev-jobs`
4. Click **Indexes** tab - verify 2 GSIs exist
5. Click **Additional settings** tab - verify TTL is enabled on `expiresAt`

### 9.3 Verify IAM Roles

```bash
# List IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `InavoreShuttle`)].RoleName'
```

Expected:
```json
[
    "InavoreShuttle-dev-lambda-execution-role",
    "InavoreShuttle-dev-apprunner-execution-role"
]
```

### 9.4 Verify CloudFormation Stack

```bash
# Describe stack
aws cloudformation describe-stacks --stack-name InavoreShuttle-dev

# View stack resources
aws cloudformation list-stack-resources --stack-name InavoreShuttle-dev
```

---

## Step 10: Test Basic Operations

### 10.1 Insert Test Data into Shops Table

```bash
aws dynamodb put-item \
  --table-name InavoreShuttle-dev-shops \
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

### 10.2 Retrieve Test Data

```bash
aws dynamodb get-item \
  --table-name InavoreShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'
```

Expected: Returns the item you just inserted

### 10.3 Insert Test Job

```bash
aws dynamodb put-item \
  --table-name InavoreShuttle-dev-jobs \
  --item '{
    "jobId": {"S": "01HKJ2NDEKTSV4RRFFQ69G5FAV"},
    "shopDomain": {"S": "test-shop.myshopify.com"},
    "type": {"S": "IMPORT"},
    "status": {"S": "QUEUED"},
    "createdAt": {"N": "1699564800000"},
    "expiresAt": {"N": "1707340800000"}
  }'
```

### 10.4 Query Jobs by Shop (GSI Test)

```bash
aws dynamodb query \
  --table-name InavoreShuttle-dev-jobs \
  --index-name shopDomain-createdAt-index \
  --key-condition-expression "shopDomain = :shopDomain" \
  --expression-attribute-values '{":shopDomain": {"S": "test-shop.myshopify.com"}}'
```

Expected: Returns the test job

### 10.5 Clean Up Test Data

```bash
# Delete test shop
aws dynamodb delete-item \
  --table-name InavoreShuttle-dev-shops \
  --key '{"domain": {"S": "test-shop.myshopify.com"}}'

# Delete test job
aws dynamodb delete-item \
  --table-name InavoreShuttle-dev-jobs \
  --key '{"jobId": {"S": "01HKJ2NDEKTSV4RRFFQ69G5FAV"}}'
```

---

## Troubleshooting

### Issue: "Unable to locate credentials"

**Cause**: AWS CLI not configured or credentials expired

**Solution**:
```bash
aws configure
# Re-enter your access key ID and secret
```

### Issue: "User is not authorized to perform: cloudformation:CreateStack"

**Cause**: IAM user lacks CloudFormation permissions

**Solution**: Attach `AWSCloudFormationFullAccess` policy to your IAM user (see Step 2.2)

### Issue: CDK bootstrap fails with "Access Denied"

**Cause**: IAM user lacks permissions to create CDK resources

**Solution**: Temporarily grant `AdministratorAccess` for bootstrap, then restrict

### Issue: "Resource already exists" during deployment

**Cause**: Previous deployment failed mid-process

**Solution**:
```bash
# View stack events to see what failed
aws cloudformation describe-stack-events --stack-name InavoreShuttle-dev

# Delete the stack and retry
aws cloudformation delete-stack --stack-name InavoreShuttle-dev

# Wait for deletion to complete, then redeploy
cdk deploy InavoreShuttle-dev
```

### Issue: Table status is "CREATING" for more than 5 minutes

**Cause**: AWS is still provisioning (rare, but can happen)

**Solution**: Wait up to 10 minutes. If still stuck, check CloudFormation events:
```bash
aws cloudformation describe-stack-events --stack-name InavoreShuttle-dev
```

---

## Cost Considerations

### Expected Costs (Development)

With minimal usage, expect:
- **DynamoDB**: ~$0-5/month (on-demand, low traffic)
- **S3 (CDK assets)**: ~$0-1/month (small files)
- **CloudWatch Logs**: ~$0-2/month (minimal logging)
- **Total**: ~$0-10/month for development

### Cost Optimization Tips

1. **Use the Free Tier**:
   - DynamoDB: 25 GB storage, 25 read/write capacity units (first 12 months)
   - S3: 5 GB storage (first 12 months)
   - CloudWatch: 10 custom metrics, 5 GB logs (first 12 months)

2. **Clean up when not in use**:
   ```bash
   # Destroy stack to delete all resources
   cdk destroy InavoreShuttle-dev
   ```

3. **Monitor costs**:
   - Set up AWS Budgets: https://console.aws.amazon.com/billing/home#/budgets
   - Create a $10/month budget with email alerts

---

## Next Steps

After completing this guide:

1. **Proceed to Phase 1 Infrastructure Issues**:
   - [ ] Issue #4: S3 Bucket Setup (PHASE-1-INFRA-003)
   - [ ] Issue #5: SQS Queue Setup (PHASE-1-INFRA-004)
   - [ ] Issue #6: Lambda Function Setup (PHASE-1-JOB-001)

2. **Set up CI/CD** (Future):
   - Configure GitHub Actions to deploy on push to `main`
   - Use AWS Secrets Manager for credentials

3. **Create staging/production environments**:
   ```bash
   # Deploy to staging
   ENVIRONMENT=staging cdk deploy InavoreShuttle-staging

   # Deploy to production
   ENVIRONMENT=prod cdk deploy InavoreShuttle-prod
   ```

4. **Explore AWS Console**:
   - DynamoDB: View tables, run queries
   - CloudWatch: View metrics, set alarms
   - IAM: Review roles and policies
   - CloudFormation: View stack resources and events

---

## Additional Resources

### AWS Documentation
- AWS CDK Developer Guide: https://docs.aws.amazon.com/cdk/
- DynamoDB Developer Guide: https://docs.aws.amazon.com/dynamodb/
- IAM Best Practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

### Project Documentation
- Database Schema: `/docs/database-schema.md`
- Comprehensive Plan: `/docs/comprehensive-implementation-plan.md`
- Phase 1 Issues: `/docs/phase-1-issues-summary.md`

### Support
- AWS Support: https://console.aws.amazon.com/support/
- AWS Community Forums: https://forums.aws.amazon.com/
- Stack Overflow (tag: amazon-web-services): https://stackoverflow.com/

---

## Checklist: Verify Your Setup

Before proceeding to the next infrastructure issue, confirm:

- [x] AWS account created and activated
- [x] IAM user created with appropriate permissions
- [x] Access keys generated and saved securely
- [x] AWS CLI installed and configured (`aws sts get-caller-identity` works)
- [x] AWS CDK installed (`cdk --version` works)
- [x] CDK bootstrapped in your AWS account
- [x] `.env` file configured with AWS account ID and region
- [x] DynamoDB tables deployed (`cdk deploy InavoreShuttle-dev` succeeded)
- [x] Tables verified in AWS Console or via CLI
- [x] GSIs exist on Jobs table
- [x] TTL enabled on Jobs and ImportHistory tables
- [x] Test data inserted and retrieved successfully
- [x] CloudFormation stack shows `CREATE_COMPLETE` status

If all checkboxes are complete, you're ready to proceed! 🚀

---

**Document Version**: 1.0.0
**Last Updated**: 2025-11-10
**Related Issues**: #3 (PHASE-1-INFRA-002)
