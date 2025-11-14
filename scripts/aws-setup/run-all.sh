#!/bin/bash

##############################################################################
# AWS Setup Complete Automation
#
# Purpose: Runs all AWS setup scripts in proper sequence
# Usage: ./run-all.sh [OPTIONS]
#
# Automates the entire setup process from Step 3 onwards
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${CYAN}════════════════════════════════════════════${NC}\n${CYAN}$1${NC}\n${CYAN}════════════════════════════════════════════${NC}\n"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DRY_RUN="${DRY_RUN:-false}"
SKIP_INTERACTIVE="${SKIP_INTERACTIVE:-false}"
AWS_REGION="${AWS_REGION:-us-east-2}"

# Parsed options
SKIP_ACCOUNTS=false
SKIP_CLOUDTRAIL=false
SKIP_IDENTITY_CENTER=false
SKIP_CLI=false
SKIP_ENV=false

print_usage() {
    cat <<EOF
Usage: ./run-all.sh [OPTIONS]

OPTIONS:
    --profile PROFILE            AWS profile name (e.g., my-sso)
    --region REGION              AWS region (default: us-east-2)
    --dry-run                    Preview changes without applying them
    --skip-interactive           Skip interactive steps (use with caution)
    --skip-accounts              Skip account creation
    --skip-cloudtrail            Skip CloudTrail setup
    --skip-identity-center       Skip Identity Center setup
    --skip-cli                   Skip CLI profile setup
    --skip-env                   Skip environment file creation
    --portal-url URL             Identity Center portal URL (for CLI setup)
    --help                       Show this help message

EXAMPLES:
    # Full setup with previews
    ./run-all.sh

    # Setup with AWS SSO profile
    ./run-all.sh --profile my-sso

    # Preview all changes first
    ./run-all.sh --dry-run

    # Full setup with portal URL to avoid interactive steps
    ./run-all.sh --portal-url https://d-123456789.awsapps.com/start

    # Only run specific components
    ./run-all.sh --skip-accounts --skip-cloudtrail

    # Specific region with SSO profile
    ./run-all.sh --profile my-sso --region eu-west-1

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            AWS_PROFILE="$2"
            shift 2
            ;;
        --region)
            AWS_REGION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --skip-interactive)
            SKIP_INTERACTIVE="true"
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
        --skip-identity-center)
            SKIP_IDENTITY_CENTER="true"
            shift
            ;;
        --skip-cli)
            SKIP_CLI="true"
            shift
            ;;
        --skip-env)
            SKIP_ENV="true"
            shift
            ;;
        --portal-url)
            PORTAL_URL="$2"
            shift 2
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

# Export for subscripts
export AWS_PROFILE
export AWS_REGION
export DRY_RUN
export VERBOSE

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  AWS Infrastructure Setup - Full Automation ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$DRY_RUN" = "true" ]; then
        echo -e "${YELLOW}Running in DRY RUN mode - no changes will be made${NC}"
        echo ""
    fi

    echo "Configuration:"
    if [ -n "$AWS_PROFILE" ]; then
        echo "  Profile: $AWS_PROFILE"
    fi
    echo "  Region: $AWS_REGION"
    echo "  Dry Run: $DRY_RUN"
    echo "  Skip Interactive: $SKIP_INTERACTIVE"
    echo ""
}

check_requirements() {
    step "Checking Requirements"

    local missing=0
    local aws_cmd="aws"

    if ! command -v aws &> /dev/null; then
        error "AWS CLI not found. Install from: https://aws.amazon.com/cli/"
        missing=1
    else
        success "AWS CLI installed ($(aws --version | cut -d' ' -f1))"
    fi

    if ! command -v jq &> /dev/null; then
        error "jq not found. Install from: https://stedolan.github.io/jq/"
        missing=1
    else
        success "jq installed"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        error "Missing required tools. Please install them and try again."
        exit 1
    fi

    # Add profile flag if specified
    if [ -n "$AWS_PROFILE" ]; then
        aws_cmd="aws --profile $AWS_PROFILE"
    fi

    # Check AWS credentials
    if ! $aws_cmd sts get-caller-identity &>/dev/null; then
        error "AWS credentials not configured."
        if [ -n "$AWS_PROFILE" ]; then
            error "Profile '$AWS_PROFILE' not found or credentials expired. Run: aws sso login --profile $AWS_PROFILE"
        else
            error "Run: aws configure or aws sso login"
        fi
        exit 1
    fi

    ACCOUNT_ID=$($aws_cmd sts get-caller-identity --query Account --output text)
    success "AWS authenticated to account: $ACCOUNT_ID"
}

run_step() {
    local step_num=$1
    local step_name=$2
    local script=$3
    local skip_var=$4
    shift 4
    local args=("$@")

    if [ "${!skip_var}" = "true" ]; then
        warning "Step $step_num: $step_name (SKIPPED)"
        return 0
    fi

    step "Step $step_num: $step_name"

    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        error "Script not found: $SCRIPT_DIR/$script"
        return 1
    fi

    log "Running $script..."

    if [ "$DRY_RUN" = "true" ]; then
        bash "$SCRIPT_DIR/$script" "${args[@]}" --dry-run || return 1
    else
        bash "$SCRIPT_DIR/$script" "${args[@]}" || return 1
    fi

    success "Step $step_num completed"
}

run_all() {
    print_header
    check_requirements

    # Step 1: Account creation and infrastructure
    run_step 1 "Create AWS Accounts" "setup.sh" "SKIP_ACCOUNTS" \
        --region "$AWS_REGION"

    if [ $? -ne 0 ]; then
        error "Step 1 failed. Aborting."
        exit 1
    fi

    # Step 2: Identity Center setup
    if [ "$SKIP_IDENTITY_CENTER" != "true" ] && [ "$SKIP_INTERACTIVE" != "true" ]; then
        step "Step 2: Configure Identity Center"
        log "This step requires manual AWS Console interaction."
        log "Running interactive guide..."
        bash "$SCRIPT_DIR/setup-identity-center.sh"
        success "Step 2 completed"
    elif [ "$SKIP_IDENTITY_CENTER" != "true" ]; then
        warning "Step 2: Configure Identity Center (SKIPPED - use --skip-identity-center to suppress this message)"
    fi

    # Step 3: CLI profile setup
    cli_args=(--region "$AWS_REGION")
    if [ -n "$PORTAL_URL" ]; then
        cli_args+=(--portal-url "$PORTAL_URL")
    fi

    run_step 3 "Configure AWS CLI Profiles" "setup-cli-profiles.sh" "SKIP_CLI" \
        "${cli_args[@]}"

    # Step 4: Environment configuration
    run_step 4 "Create Environment Files" "setup-env.sh" "SKIP_ENV"

    # Summary
    print_summary
}

print_summary() {
    step "Setup Complete!"

    if [ "$DRY_RUN" = "true" ]; then
        echo -e "${YELLOW}DRY RUN: No changes were applied${NC}"
        echo ""
        echo "To apply these changes, run:"
        echo "  ./run-all.sh"
        return 0
    fi

    echo -e "${GREEN}AWS infrastructure setup completed successfully!${NC}"
    echo ""

    local accounts_file="$PROJECT_ROOT/.env.aws-accounts"
    if [ -f "$accounts_file" ]; then
        echo "Account IDs saved to: $accounts_file"
        echo ""
        echo "Created accounts:"
        grep -E "ACCOUNT_ID=" "$accounts_file" | sed 's/ACCOUNT_ID=/  ✓ /' || true
        echo ""
    fi

    echo "Next steps:"
    echo ""
    echo "1. Team members should:"
    echo "   a. Receive the Identity Center portal URL"
    echo "   b. Log in and set their password"
    echo "   c. Run: aws sso login --profile default"
    echo ""
    echo "2. Deploy infrastructure:"
    echo "   cd cdk"
    echo "   npm install"
    echo "   cdk deploy"
    echo ""
    echo "3. Start development:"
    echo "   npm install"
    echo "   npm run setup"
    echo "   npm run dev"
    echo ""
    echo "4. For more information, see:"
    echo "   - scripts/aws-setup/README.md (automation guide)"
    echo "   - docs/learning/aws-infrastructure-setup-guide.md (full guide)"
    echo ""

    success "Setup ready for development!"
}

main() {
    run_all
}

main
