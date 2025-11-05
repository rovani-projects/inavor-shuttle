# Inavor Shuttle - AWS CDK Infrastructure

This directory contains the AWS Cloud Development Kit (CDK) configuration for the Inavor Shuttle application.

## Overview

The CDK project manages all AWS infrastructure for the Inavor Shuttle Shopify product import application, including:

- **DynamoDB**: Multi-tenant data storage (shops, jobs, usage tracking)
- **S3**: Import files, logs, and exports
- **SQS**: FIFO queue for async job processing
- **Lambda**: Job processing functions
- **IAM**: Roles and policies for service integration
- **CloudWatch**: Monitoring and alarms

## Prerequisites

- Node.js 20.x or higher
- AWS CLI configured with credentials
- AWS CDK CLI installed globally: `npm install -g aws-cdk`

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and update with your values:

```bash
cp .env.example .env
```

Edit `.env`:
```env
ENVIRONMENT=dev
AWS_ACCOUNT_ID=your-account-id
AWS_REGION=us-east-1
```

### 3. Build the CDK Project

```bash
npm run build
```

### 4. Synthesize the CloudFormation Template

```bash
npx cdk synth
```

This generates the CloudFormation template without deploying anything.

### 5. Deploy to AWS

```bash
npx cdk deploy
```

## Useful Commands

- `npm run build` - Compile TypeScript to JavaScript
- `npm run watch` - Watch for changes and compile automatically
- `npm run test` - Run unit tests
- `npx cdk synth` - Emit the synthesized CloudFormation template
- `npx cdk diff` - Compare deployed stack with current code
- `npx cdk deploy` - Deploy the stack to AWS
- `npx cdk destroy` - Destroy the stack (careful!)
- `npx cdk docs` - Open CDK documentation

## Project Structure

```
cdk/
├── bin/
│   └── cdk.ts                    # Main entry point
├── lib/
│   ├── inavor-shuttle-stack.ts   # Main stack definition
│   └── constructs/               # Reusable CDK constructs (future)
├── test/
│   └── cdk.test.ts               # Stack tests
├── .env.example                  # Environment template
├── cdk.json                       # CDK configuration
├── package.json                  # Dependencies
└── tsconfig.json                 # TypeScript configuration
```

## Phase 1 Infrastructure

This CDK setup is the foundation for Phase 1 (MVP) of the Inavor Shuttle project. The following resources will be added:

### Week 1-2: Infrastructure & Authentication

1. **PHASE-1-INFRA-001** ✅ AWS Account & CDK Project Setup (this file)
2. **PHASE-1-INFRA-002** DynamoDB Table Creation & Configuration
3. **PHASE-1-INFRA-003** S3 Bucket Setup with Lifecycle Policies
4. **PHASE-1-INFRA-004** SQS Queue Setup (FIFO + DLQ)
5. **PHASE-1-AUTH-001** Shopify OAuth Implementation
6. **PHASE-1-AUTH-002** Embedded App Authentication Verification
7. **PHASE-1-AUTH-003** Shop Install/Uninstall Webhook Handlers

## Development Workflow

1. Create a new branch for your infrastructure feature:
   ```bash
   git checkout -b feature/PHASE-1-INFRA-002-dynamodb
   ```

2. Make changes to the CDK stack in `lib/inavor-shuttle-stack.ts` or create new construct files

3. Test locally (when applicable):
   ```bash
   npm run test
   npm run build
   npx cdk synth  # Verify CloudFormation is valid
   ```

4. Deploy to dev/staging (when ready):
   ```bash
   ENVIRONMENT=dev npx cdk deploy
   ```

5. Create a pull request with your changes

## Environment-Specific Deployments

To deploy to different environments, set the `ENVIRONMENT` variable:

```bash
# Development
ENVIRONMENT=dev npx cdk deploy

# Staging
ENVIRONMENT=staging npx cdk deploy

# Production (use with caution!)
ENVIRONMENT=prod npx cdk deploy
```

## Important Notes

- **State Management**: CDK maintains a CloudFormation stack in AWS. Use `cdk diff` before deploying to review changes.
- **IAM Permissions**: Ensure your AWS credentials have permissions to create the resources defined in the stack.
- **Cost**: Monitor AWS costs, especially for DynamoDB and S3. Set up billing alarms in CloudWatch.
- **Destroy**: Use `cdk destroy` to remove resources, but be careful with production environments.

## Documentation

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [CDK API Reference](https://docs.aws.amazon.com/cdk/api/)
- [Inavor Shuttle Implementation Plan](/docs/comprehensive-implementation-plan.md)
- [GitHub Issues Breakdown](/docs/github-issues-breakdown.md)

## Support

For questions or issues:
- Check the [Comprehensive Implementation Plan](../docs/comprehensive-implementation-plan.md)
- Review the [GitHub Issues](https://github.com/rovani-projects/inavor-shuttle/issues)
- See the [CLAUDE.md](../CLAUDE.md) for project guidelines
