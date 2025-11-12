#!/bin/bash

##############################################################################
# Environment Configuration Setup
#
# Purpose: Generates .env files for CDK and application
# Usage: ./setup-env.sh
#
# Creates .env.local for development with all necessary variables
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load account IDs
if [ ! -f "$PROJECT_ROOT/.env.aws-accounts" ]; then
    error "Account IDs file not found. Run setup.sh first."
    exit 1
fi

source "$PROJECT_ROOT/.env.aws-accounts"

create_cdk_env() {
    local cdk_dir="$PROJECT_ROOT/cdk"
    local env_file="$cdk_dir/.env"

    log "Creating CDK .env file..."

    cat > "$env_file" <<EOF
# AWS Organization Configuration
ORGANIZATION_MANAGEMENT_ACCOUNT_ID=$MANAGEMENT_ACCOUNT_ID
ORGANIZATION_SHARED_SERVICES_ACCOUNT_ID=$SHARED_SERVICES_ACCOUNT_ID
ORGANIZATION_SECURITY_ACCOUNT_ID=$SECURITY_ACCOUNT_ID

# Primary Region
AWS_REGION=us-east-2

# Inavor Shuttle Accounts
INAVOR_SHUTTLE_DEV_ACCOUNT_ID=$INAVOR_DEV_ACCOUNT_ID
INAVOR_SHUTTLE_STAGING_ACCOUNT_ID=${INAVOR_STAGING_ACCOUNT_ID:-}
INAVOR_SHUTTLE_PROD_ACCOUNT_ID=${INAVOR_PROD_ACCOUNT_ID:-}

# Environment
INAVOR_SHUTTLE_ENVIRONMENT=dev

# Tags for cost tracking
PROJECT_NAME=inavor-shuttle
COST_CENTER=engineering
TEAM=platform
CLIENT=internal
EOF

    success "Created $env_file"
}

create_app_env() {
    local app_dir="$PROJECT_ROOT"
    local env_file="$app_dir/.env.local"

    log "Creating application .env.local file..."

    cat > "$env_file" <<EOF
# AWS Configuration
AWS_REGION=us-east-2
AWS_ACCOUNT_ID=$INAVOR_DEV_ACCOUNT_ID

# DynamoDB Tables (populated after CDK deploy)
SHOPS_TABLE=InavorShuttle-dev-shops
JOBS_TABLE=InavorShuttle-dev-jobs
IMPORT_HISTORY_TABLE=InavorShuttle-dev-import-history

# S3 Configuration
S3_IMPORTS_BUCKET=inavor-imports-dev
S3_REGION=us-east-2

# SQS Configuration
SQS_JOB_QUEUE_URL=https://sqs.us-east-2.amazonaws.com/$INAVOR_DEV_ACCOUNT_ID/inavor-job-queue-dev

# Shopify Configuration
SHOPIFY_API_KEY=your-api-key-here
SHOPIFY_API_SECRET=your-api-secret-here
SHOPIFY_API_VERSION=2024-10

# Application
NODE_ENV=development
SESSION_SECRET=dev-session-secret-change-in-production
PORT=3000

# Monitoring
LOG_LEVEL=debug
ENABLE_METRICS=true
EOF

    success "Created $env_file"
    warning "Remember to add real Shopify credentials to .env.local"
}

create_github_actions_env() {
    local ci_file="$PROJECT_ROOT/.github/workflows/deploy.yml"

    if [ ! -d "$PROJECT_ROOT/.github/workflows" ]; then
        mkdir -p "$PROJECT_ROOT/.github/workflows"
    fi

    log "Creating GitHub Actions deployment secrets guide..."

    cat > "$PROJECT_ROOT/.github/deploy-secrets-guide.md" <<EOF
# GitHub Actions Deployment Secrets

To enable automated deployments from GitHub, add these secrets to your repository:

## AWS Credentials (OIDC recommended)

### Method 1: OIDC (Recommended)
See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

Configure AWS IAM role trust for GitHub:
\`\`\`json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$INAVOR_DEV_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
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
\`\`\`

### Method 2: Access Keys (Less Secure)
Add to repository secrets:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

## Environment Variables

Add to repository variables:
- AWS_REGION: us-east-2
- AWS_ACCOUNT_ID: $INAVOR_DEV_ACCOUNT_ID
- CDK_DEFAULT_ACCOUNT: $INAVOR_DEV_ACCOUNT_ID
- CDK_DEFAULT_REGION: us-east-2

## Shopify API Credentials

Add to repository secrets:
- SHOPIFY_API_KEY
- SHOPIFY_API_SECRET

Keep these secure and rotate regularly.
EOF

    success "Created deploy-secrets-guide.md"
}

print_summary() {
    echo ""
    echo -e "${GREEN}╔═════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Configuration Files Created             ║${NC}"
    echo -e "${GREEN}╚═════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Files created:"
    echo "  ✓ cdk/.env - CDK infrastructure variables"
    echo "  ✓ .env.local - Application configuration"
    echo "  ✓ .github/deploy-secrets-guide.md - GitHub Actions setup"
    echo ""
    echo "Next steps:"
    echo "  1. Review and update .env.local with real credentials"
    echo "  2. Review .github/deploy-secrets-guide.md for CI/CD setup"
    echo "  3. Run 'npm run setup' to initialize database"
    echo "  4. Run 'npm run dev' to start development server"
    echo ""
}

main() {
    echo ""
    echo -e "${BLUE}╔═════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Environment Configuration               ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════╝${NC}"
    echo ""

    create_cdk_env
    create_app_env
    create_github_actions_env

    print_summary
}

main
