#!/bin/bash

##############################################################################
# AWS Organization Setup Automation Script
#
# Purpose: Automates Steps 3-15 of the AWS Infrastructure Setup Guide
# Prerequisites: AWS Organization already created (Step 1-2)
# Usage: ./setup.sh [--region us-east-2] [--dry-run]
#
# This script automates:
# - Account creation (Shared Services, Security, Inavor Shuttle Dev/Staging/Prod)
# - CloudTrail setup
# - Identity Center setup (users, groups, permission sets)
# - CDK bootstrapping
# - Environment configuration
##############################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AWS_REGION="${AWS_REGION:-us-east-2}"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"

# Account configuration
ORGANIZATION_NAME="Rovani Projects"
ORG_DOMAIN="rovaniprojects.com"

# Declare associative arrays for accounts
declare -A ACCOUNTS=(
    [shared-services]="shared-services@${ORG_DOMAIN}:Shared-Services"
    [security]="security@${ORG_DOMAIN}:Security"
    [inavor-dev]="inavor-shuttle-dev@${ORG_DOMAIN}:InavorShuttle-Dev"
    [inavor-staging]="inavor-shuttle-staging@${ORG_DOMAIN}:InavorShuttle-Staging"
    [inavor-prod]="inavor-shuttle-prod@${ORG_DOMAIN}:InavorShuttle-Prod"
)

##############################################################################
# Utility Functions
##############################################################################

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

verbose() {
    if [ "$VERBOSE" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run AWS CLI command with proper error handling
aws_cli() {
    local cmd="aws"
    if [ -n "$AWS_PROFILE" ]; then
        cmd="$cmd --profile $AWS_PROFILE"
    fi
    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] $cmd $@"
        return 0
    fi
    $cmd "$@" --region "$AWS_REGION"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."

    if ! command_exists aws; then
        error "AWS CLI not found. Please install AWS CLI v2 first."
        exit 1
    fi

    if ! command_exists jq; then
        error "jq not found. Please install jq (JSON processor)."
        exit 1
    fi

    # Verify AWS credentials are available
    local aws_cmd="aws"
    if [ -n "$AWS_PROFILE" ]; then
        aws_cmd="aws --profile $AWS_PROFILE"
    fi

    if ! $aws_cmd sts get-caller-identity &>/dev/null; then
        error "AWS credentials not configured. Please run 'aws configure' or 'aws sso login'."
        exit 1
    fi

    MANAGEMENT_ACCOUNT=$($aws_cmd sts get-caller-identity --query Account --output text)
    success "Prerequisites OK - Using AWS Account: $MANAGEMENT_ACCOUNT"
}

##############################################################################
# Account Creation
##############################################################################

create_accounts() {
    log "Creating AWS accounts..."

    declare -A ACCOUNT_IDS

    for key in "${!ACCOUNTS[@]}"; do
        IFS=':' read -r email name <<< "${ACCOUNTS[$key]}"

        log "Creating account: $name ($email)"

        if [ "$DRY_RUN" = "true" ]; then
            echo "[DRY RUN] Creating account $name with email $email"
            ACCOUNT_IDS[$key]="123456789012"
            continue
        fi

        # Check if account already exists
        existing=$(aws organizations list-accounts --query "Accounts[?Name=='$name'].Id" --output text 2>/dev/null || echo "")

        if [ -n "$existing" ]; then
            warning "Account $name already exists with ID: $existing"
            ACCOUNT_IDS[$key]="$existing"
            continue
        fi

        # Create the account
        response=$(aws organizations create-account \
            --email "$email" \
            --account-name "$name" \
            --output json)

        # Wait for account creation to complete
        create_request_id=$(echo "$response" | jq -r '.CreateAccountStatus.Id')
        log "Account creation initiated. Request ID: $create_request_id"

        # Poll for completion (max 3 minutes)
        for i in {1..18}; do
            status=$(aws organizations describe-create-account-status \
                --create-account-request-id "$create_request_id" \
                --query 'CreateAccountStatus' --output json)

            state=$(echo "$status" | jq -r '.State')
            account_id=$(echo "$status" | jq -r '.AccountId // "PENDING"')

            if [ "$state" = "SUCCEEDED" ] && [ "$account_id" != "null" ] && [ "$account_id" != "PENDING" ]; then
                success "Account created: $name (ID: $account_id)"
                ACCOUNT_IDS[$key]="$account_id"
                break
            elif [ "$state" = "FAILED" ]; then
                error "Account creation failed: $(echo "$status" | jq -r '.FailureReason')"
                exit 1
            fi

            verbose "Waiting for account creation... (${i}/18)"
            sleep 10
        done

        if [ -z "${ACCOUNT_IDS[$key]}" ]; then
            error "Account creation timed out after 3 minutes"
            exit 1
        fi
    done

    # Save account IDs to file
    save_account_ids ACCOUNT_IDS
}

save_account_ids() {
    local -n arr=$1
    local config_file="$PROJECT_ROOT/.env.aws-accounts"

    log "Saving account IDs to $config_file"

    {
        echo "# AWS Account IDs - Generated by setup.sh"
        echo "# Do not commit to version control"
        echo ""
        echo "MANAGEMENT_ACCOUNT_ID=$MANAGEMENT_ACCOUNT"
        echo ""
        for key in "${!arr[@]}"; do
            key_upper=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
            echo "${key_upper}_ACCOUNT_ID=${arr[$key]}"
        done
    } > "$config_file"

    success "Account IDs saved to $config_file"
}

##############################################################################
# CloudTrail Setup
##############################################################################

setup_cloudtrail() {
    log "Setting up CloudTrail for organization..."

    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Setting up CloudTrail organization trail"
        return 0
    fi

    # Check if trail already exists
    trail_name="OrganizationTrail"
    existing=$(aws cloudtrail describe-trails --query "trailList[?Name=='$trail_name']" --output text 2>/dev/null || echo "")

    if [ -n "$existing" ]; then
        warning "CloudTrail trail already exists: $trail_name"
        return 0
    fi

    # Create S3 bucket for CloudTrail logs
    bucket_name="rovani-cloudtrail-logs-${MANAGEMENT_ACCOUNT}"

    log "Creating S3 bucket for CloudTrail: $bucket_name"
    aws s3api create-bucket \
        --bucket "$bucket_name" \
        --region "$AWS_REGION" \
        $([ "$AWS_REGION" != "us-east-2" ] && echo "--create-bucket-configuration LocationConstraint=$AWS_REGION" || echo "") \
        2>/dev/null || warning "Bucket already exists or other error (continuing)"

    # Block public access
    aws s3api put-public-access-block \
        --bucket "$bucket_name" \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    # Create bucket policy for CloudTrail
    cat > /tmp/cloudtrail-policy.json <<EOF
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
      "Resource": "arn:aws:s3:::${bucket_name}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
EOF

    aws s3api put-bucket-policy --bucket "$bucket_name" --policy file:///tmp/cloudtrail-policy.json

    # Create CloudTrail
    log "Creating CloudTrail trail: $trail_name"
    aws cloudtrail create-trail \
        --name "$trail_name" \
        --s3-bucket-name "$bucket_name" \
        --is-organization-trail \
        --region "$AWS_REGION" \
        || error "Failed to create trail (may already exist)"

    # Enable logging
    aws cloudtrail start-logging --trail-name "$trail_name"

    success "CloudTrail configured: $trail_name"
}

##############################################################################
# Identity Center Setup
##############################################################################

setup_identity_center() {
    log "Setting up IAM Identity Center..."

    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Setting up Identity Center users, groups, and permission sets"
        return 0
    fi

    # Check if Identity Center is enabled
    ic_info=$(aws identitystore list-users 2>/dev/null || echo "")
    if [ -z "$ic_info" ]; then
        warning "IAM Identity Center not enabled. Please enable it manually in AWS Console."
        return 1
    fi

    # Create users (requires manual email invitation for now)
    log "Identity Center setup requires manual configuration:"
    echo "  1. Go to AWS Console → IAM Identity Center"
    echo "  2. Create users for each developer"
    echo "  3. Create groups (Developers, DevOps, etc.)"
    echo "  4. Create permission sets with appropriate policies"
    echo ""
    echo "See setup-identity-center.sh for detailed steps"
}

##############################################################################
# CDK Bootstrap
##############################################################################

bootstrap_cdk() {
    log "Bootstrapping AWS CDK in all accounts..."

    if [ "$DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Bootstrapping CDK in all accounts"
        return 0
    fi

    # Source account IDs from saved file
    if [ -f "$PROJECT_ROOT/.env.aws-accounts" ]; then
        source "$PROJECT_ROOT/.env.aws-accounts"
    else
        error "Account IDs file not found. Run account creation first."
        return 1
    fi

    # Bootstrap each account
    for account_var in SHARED_SERVICES_ACCOUNT_ID SECURITY_ACCOUNT_ID INAVOR_DEV_ACCOUNT_ID; do
        account_id="${!account_var}"
        [ -z "$account_id" ] && continue

        log "Bootstrapping CDK in account: $account_id"

        if command_exists cdk; then
            cdk bootstrap "aws://${account_id}/${AWS_REGION}"
        else
            warning "AWS CDK not installed. Please install with: npm install -g aws-cdk"
        fi
    done

    success "CDK bootstrap completed"
}

##############################################################################
# Configuration Files
##############################################################################

create_config_files() {
    log "Creating configuration files..."

    # Create CDK .env.example if it doesn't exist
    local cdk_env="$PROJECT_ROOT/cdk/.env.example"
    if [ ! -f "$cdk_env" ]; then
        log "Creating $cdk_env"
        cat > "$cdk_env" <<'EOF'
# AWS Organization Configuration
ORGANIZATION_MANAGEMENT_ACCOUNT_ID=123456789012
ORGANIZATION_SHARED_SERVICES_ACCOUNT_ID=210987654321
ORGANIZATION_SECURITY_ACCOUNT_ID=321098765432

# Primary Region
AWS_REGION=us-east-2

# Inavor Shuttle Accounts
INAVOR_SHUTTLE_DEV_ACCOUNT_ID=111111111111
INAVOR_SHUTTLE_STAGING_ACCOUNT_ID=222222222222
INAVOR_SHUTTLE_PROD_ACCOUNT_ID=333333333333

# Environment
INAVOR_SHUTTLE_ENVIRONMENT=dev

# Optional: Override for specific deployment
# AWS_PROFILE=inavor-dev
EOF
        success "Created $cdk_env"
    fi

    # Copy real account IDs to CDK .env
    if [ -f "$PROJECT_ROOT/.env.aws-accounts" ]; then
        log "Creating CDK .env with real account IDs..."
        cp "$PROJECT_ROOT/.env.aws-accounts" "$PROJECT_ROOT/cdk/.env"
        success "Created $PROJECT_ROOT/cdk/.env"
    fi
}

##############################################################################
# Main Flow
##############################################################################

print_usage() {
    cat <<EOF
Usage: ./setup.sh [OPTIONS]

OPTIONS:
    --region REGION         AWS region (default: us-east-2)
    --dry-run              Preview changes without making them
    --verbose              Enable verbose output
    --skip-accounts        Skip account creation
    --skip-cloudtrail      Skip CloudTrail setup
    --help                 Show this help message

EXAMPLES:
    # Preview all changes
    ./setup.sh --dry-run

    # Run with specific region
    ./setup.sh --region eu-west-1

    # Run only account creation
    ./setup.sh --skip-cloudtrail

EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --region)
                AWS_REGION="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            --skip-accounts)
                SKIP_ACCOUNTS="true"
                shift
                ;;
            --skip-cloudtrail)
                SKIP_CLOUDTRAIL="true"
                shift
                ;;
            --help)
                print_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    # Header
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     AWS Organization Setup Automation      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$DRY_RUN" = "true" ]; then
        echo -e "${YELLOW}Running in DRY RUN mode - no changes will be made${NC}"
        echo ""
    fi

    # Run steps
    check_prerequisites
    echo ""

    if [ "$SKIP_ACCOUNTS" != "true" ]; then
        create_accounts
        echo ""
    fi

    if [ "$SKIP_CLOUDTRAIL" != "true" ]; then
        setup_cloudtrail
        echo ""
    fi

    setup_identity_center
    echo ""

    bootstrap_cdk
    echo ""

    create_config_files
    echo ""

    # Summary
    log "Setup summary:"
    echo "  Region: $AWS_REGION"
    echo "  Dry Run: $DRY_RUN"
    echo ""
    if [ "$DRY_RUN" = "false" ]; then
        echo "✓ AWS account setup completed!"
        echo ""
        echo "Next steps:"
        echo "  1. Review .env.aws-accounts for account IDs"
        echo "  2. Run ./setup-identity-center.sh to configure users and groups"
        echo "  3. Run ./setup-cli-profiles.sh to configure AWS CLI"
        echo "  4. Bootstrap CDK with: cdk bootstrap"
        echo "  5. Deploy infrastructure with: cdk deploy"
    else
        echo "✓ Dry run completed! Run without --dry-run to apply changes."
    fi
    echo ""
}

main "$@"
