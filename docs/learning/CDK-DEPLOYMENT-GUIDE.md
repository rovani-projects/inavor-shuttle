# CDK Deployment Guide for Inavor Shuttle

**Purpose**: Deploy DynamoDB tables and IAM roles to AWS using AWS CDK
**Status**: Ready for deployment
**Last Updated**: 2025-11-12

---

## Overview

This guide walks through deploying the Inavor Shuttle infrastructure to AWS using AWS CDK. The deployment includes:

- **DynamoDB Tables**:
  - ShopsTable (merchant information)
  - JobsTable (import job tracking with Global Secondary Indexes)
  - ImportHistoryTable (historical import records)

- **IAM Roles**:
  - LambdaExecutionRole (for Lambda functions)
  - AppRunnerExecutionRole (for App Runner service)

---

## Prerequisites

Before deploying, ensure you have completed the AWS Infrastructure Setup:

- ✅ AWS root account created and secured with MFA
- ✅ AWS Organization enabled with all features
- ✅ Five AWS accounts created (Management, Shared Services, Security, Inavor Dev, Inavor Staging, Inavor Prod)
- ✅ IAM Identity Center enabled with users and permission sets
- ✅ AWS CLI v2 installed (`aws --version`)
- ✅ AWS CLI profiles configured in `~/.aws/config`
- ✅ `.env` file in `cdk/` directory with account IDs

**See**: [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md)

---

## Step 1: Verify Prerequisites

### Check AWS CLI Installation

```bash
aws --version
# Expected: aws-cli/2.x.x ...
```

### Check AWS CLI Profiles

```bash
aws configure list --profile inavor-dev
# Expected: Shows profile configuration with account ID 834821259107 (or your Inavor Dev account)
```

### Check CDK Installation

```bash
cdk --version
# Expected: 2.x.x (build ...)
```

If CDK is not installed globally:

```bash
npm install -g aws-cdk
```

### Check Environment Configuration

```bash
cd /home/drovani/inavor-shuttle/cdk
cat .env
# Expected output:
# INAVOR_SHUTTLE_DEV_ACCOUNT_ID=834821259107
# AWS_REGION=us-east-2
# ... other variables
```

---

## Step 2: Authenticate with AWS Identity Center

Your AWS CLI SSO token may have expired. Re-authenticate:

```bash
# For development account
aws sso login --profile inavor-dev

# For staging account
aws sso login --profile inavor-staging

# For production account
aws sso login --profile inavor-prod
```

This will open a browser window for authentication. After logging in, your credentials are cached locally.

**Verify authentication**:

```bash
export AWS_PROFILE=inavor-dev
aws sts get-caller-identity
# Expected output:
# {
#   "UserId": "...",
#   "Account": "834821259107",
#   "Arn": "arn:aws:iam::834821259107:role/..."
# }
```

---

## Step 3: Synthesize CloudFormation Template

Generate the CloudFormation template without deploying:

```bash
cd /home/drovani/inavor-shuttle/cdk
cdk synth InavorShuttle-dev
```

This generates the CloudFormation template in JSON/YAML format. You can review it in:
- `cdk.out/InavorShuttle-dev.template.json`

---

## Step 4: Review Changes (Diff)

See what resources will be created:

```bash
cdk diff InavorShuttle-dev
```

**Expected output**:

```
Stack InavorShuttle-dev
Resources
[+] AWS::DynamoDB::Table ShopsTable
[+] AWS::DynamoDB::Table JobsTable
[+] AWS::DynamoDB::Table ImportHistoryTable
[+] AWS::IAM::Role LambdaExecutionRole
[+] AWS::IAM::Role AppRunnerExecutionRole
[+] AWS::IAM::Policy LambdaExecutionRoleDefaultPolicy
[+] AWS::IAM::Policy AppRunnerExecutionRoleDefaultPolicy
```

---

## Step 5: Deploy to AWS

### Dry Run (Recommended First)

```bash
cd /home/drovani/inavor-shuttle/cdk
cdk deploy InavorShuttle-dev --dry-run
```

This shows what would be deployed without actually deploying.

### Full Deployment

```bash
cd /home/drovani/inavor-shuttle/cdk
cdk deploy InavorShuttle-dev
```

**During deployment**, you'll see:

```
✨  Synthesis time: 2.01s

 ✅ InavorShuttle-dev

✨ Deployment time: 123.45s

Outputs:
InavorShuttle-dev.ShopsTableName = InavorShuttle-dev-shops
InavorShuttle-dev.ShopsTableArn = arn:aws:dynamodb:us-east-2:834821259107:table/InavorShuttle-dev-shops
InavorShuttle-dev.JobsTableName = InavorShuttle-dev-jobs
InavorShuttle-dev.JobsTableArn = arn:aws:dynamodb:us-east-2:834821259107:table/InavorShuttle-dev-jobs
InavorShuttle-dev.ImportHistoryTableName = InavorShuttle-dev-import-history
InavorShuttle-dev.ImportHistoryTableArn = arn:aws:dynamodb:us-east-2:834821259107:table/InavorShuttle-dev-import-history
InavorShuttle-dev.LambdaExecutionRoleArn = arn:aws:iam::834821259107:role/InavorShuttle-dev-lambda-execution-role
InavorShuttle-dev.AppRunnerExecutionRoleArn = arn:aws:iam::834821259107:role/InavorShuttle-dev-apprunner-execution-role
```

**Deployment time**: 2-5 minutes

### Deploy with Automatic Approval

To skip the approval prompt:

```bash
cdk deploy InavorShuttle-dev --require-approval never
```

---

## Step 6: Verify Deployment

### List DynamoDB Tables

```bash
export AWS_PROFILE=inavor-dev
aws dynamodb list-tables
```

**Expected output**:

```json
{
  "TableNames": [
    "InavorShuttle-dev-shops",
    "InavorShuttle-dev-jobs",
    "InavorShuttle-dev-import-history"
  ]
}
```

### Describe Tables

```bash
# Shops table
aws dynamodb describe-table --table-name InavorShuttle-dev-shops \
  --query 'Table.{Name:TableName,Status:TableStatus,BillingMode:BillingModeSummary.BillingMode}' \
  --output table

# Jobs table (with GSIs)
aws dynamodb describe-table --table-name InavorShuttle-dev-jobs \
  --query 'Table.{Name:TableName,Status:TableStatus,GSIs:GlobalSecondaryIndexes[*].IndexName}' \
  --output table
```

### Check IAM Roles

```bash
aws iam get-role --role-name InavorShuttle-dev-lambda-execution-role
aws iam get-role --role-name InavorShuttle-dev-apprunner-execution-role
```

### Via AWS Console

1. Go to https://console.aws.amazon.com
2. Switch to **Inavor Shuttle - Dev** account (using Identity Center portal)
3. Navigate to **DynamoDB** → **Tables**
4. Verify tables exist and status is **ACTIVE**
5. Click on **InavorShuttle-dev-jobs** → **Indexes** tab
6. Verify 2 Global Secondary Indexes:
   - `shopDomain-createdAt-index`
   - `status-createdAt-index`

---

## Deploying to Other Environments

### Staging Environment

```bash
# Set environment variable
export ENVIRONMENT=staging

# Deploy
cdk deploy InavorShuttle-staging --require-approval never
```

### Production Environment

```bash
# Set environment variable
export ENVIRONMENT=prod

# Deploy
cdk deploy InavorShuttle-prod --require-approval never
```

---

## Troubleshooting

### Error: "Need to perform AWS calls for account XXX, but no credentials have been configured"

**Cause**: AWS credentials have expired or SSO token has expired

**Solution**:

```bash
# Re-authenticate with Identity Center
aws sso login --profile inavor-dev

# Verify authentication
aws sts get-caller-identity --profile inavor-dev

# Retry deployment
export AWS_PROFILE=inavor-dev
cdk deploy InavorShuttle-dev
```

### Error: "User is not authorized to perform: dynamodb:CreateTable"

**Cause**: Your IAM permission set doesn't include DynamoDB permissions

**Solution**:

1. Go to **IAM Identity Center** in AWS Console
2. Find **DeveloperAccess** permission set
3. Add policy: `AmazonDynamoDBFullAccess`
4. Wait 5 minutes for permission propagation
5. Re-authenticate: `aws sso login --profile inavor-dev`
6. Retry deployment

### Error: "User is not authorized to perform: iam:CreateRole"

**Cause**: Your IAM permission set doesn't include IAM permissions

**Solution**:

1. Go to **IAM Identity Center** in AWS Console
2. Find **DeveloperAccess** permission set
3. Add policy: `IAMFullAccess` or `IAMReadOnlyAccess`
4. Wait 5 minutes and retry

### Error: "Stack with id InavorShuttle-dev already exists"

**Cause**: Stack was already deployed

**Solution**: To update the stack, just run `cdk deploy` again. CDK will compute changes and deploy updates.

### Warning: "aws-cdk-lib.aws_dynamodb deprecated pointInTimeRecovery"

This warning should NOT appear in version 2.1031.1 with the fixed code. If it does, ensure you've updated the CDK stack files to use `pointInTimeRecoverySpecification` instead of `pointInTimeRecovery`.

---

## Next Steps After Deployment

Once the DynamoDB tables and IAM roles are successfully deployed:

1. **Verify Application Access** (Phase 1 - INFRA-003):
   - Set up S3 bucket for import files
   - Configure bucket lifecycle policies
   - Test file upload/download

2. **Set Up SQS Queue** (Phase 1 - INFRA-004):
   - Create FIFO queue for job processing
   - Configure Lambda to poll messages
   - Test job submission

3. **Deploy Lambda Functions** (Phase 1 - JOB-001):
   - Create Lambda function skeleton
   - Configure environment variables
   - Test with sample data

4. **Update Application Configuration**:
   - Add table names to application config
   - Update IAM role ARNs in deployment
   - Test DynamoDB access from application

5. **Set Up Monitoring** (Phase 1 - OPS-001):
   - Enable CloudWatch metrics
   - Create CloudWatch alarms
   - Set up log groups

---

## Useful CDK Commands

```bash
# List all stacks in the CDK app
cdk list

# Show stack outputs
cdk output InavorShuttle-dev

# Destroy a stack (DELETE TABLES!)
cdk destroy InavorShuttle-dev

# Update a specific stack
cdk deploy InavorShuttle-dev

# Deploy all stacks
cdk deploy

# Watch mode (auto-redeploy on changes)
cdk watch

# Acknowledge CDK notices
cdk acknowledge 34892
```

---

## Cost Monitoring

After deployment, monitor your AWS costs:

1. Go to **Billing and Cost Management** console
2. Review **Cost Explorer**
3. Expected monthly costs for dev environment:
   - DynamoDB on-demand: ~$5-10/month (minimal usage)
   - DynamoDB backup/PITR: ~$1-2/month
   - CloudWatch Logs: ~$1/month
   - Total: ~$7-13/month

Enable billing alerts to prevent unexpected charges:

```bash
aws ce create-budget \
  --account-id 834821259107 \
  --budget-name "inavor-shuttle-dev-monthly" \
  --budget-limit "100.00" \
  --budget-period MONTHLY
```

---

## Related Documentation

- [AWS Infrastructure Setup Guide](/docs/learning/aws-infrastructure-setup-guide.md)
- [AWS Automation Summary](/docs/learning/AWS-AUTOMATION-SUMMARY.txt)
- [Integration Guide](/docs/learning/INTEGRATION-GUIDE.md)
- [Quick Start AWS Setup](/docs/learning/QUICKSTART-AWS-SETUP.md)
- [CDK README](/cdk/README.md)

---

## Support

If you encounter issues:

1. Check the **Troubleshooting** section above
2. Review CDK logs: `cdk deploy --debug InavorShuttle-dev 2>&1 | tee deploy.log`
3. Check CloudFormation events in AWS Console:
   - Go to **CloudFormation** → **Stacks** → **InavorShuttle-dev** → **Events**
4. Check IAM permissions in **IAM Identity Center**

---

**Document Version**: 1.0
**Last Updated**: 2025-11-12
**Status**: Deployment-ready
