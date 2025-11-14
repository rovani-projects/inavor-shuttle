#!/bin/bash

##############################################################################
# AWS CLI Profile Setup
#
# Purpose: Configures AWS CLI profiles for all accounts
# Usage: ./setup-cli-profiles.sh [--portal-url https://...]
#
# Creates profiles for Identity Center access to each account
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
AWS_REGION="${AWS_REGION:-us-east-2}"
SSO_SESSION_NAME="rovani"

# Load account IDs
if [ -f "$PROJECT_ROOT/.env.aws-accounts" ]; then
    source "$PROJECT_ROOT/.env.aws-accounts"
else
    error "Account IDs file not found at $PROJECT_ROOT/.env.aws-accounts"
    exit 1
fi

# Parse portal URL argument
PORTAL_URL=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --portal-url)
            PORTAL_URL="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

setup_sso_session() {
    log "Setting up AWS CLI SSO session..."

    if [ -z "$PORTAL_URL" ]; then
        echo "IAM Identity Center Portal URL not provided."
        echo ""
        echo "To find your portal URL:"
        echo "1. Go to https://console.aws.amazon.com (Management Account)"
        echo "2. Navigate to: IAM Identity Center → Dashboard"
        echo "3. Copy the 'AWS access portal URL'"
        echo ""
        read -p "Enter your Identity Center portal URL: " PORTAL_URL
    fi

    if [ -z "$PORTAL_URL" ]; then
        error "Portal URL is required"
        exit 1
    fi

    log "Configuring AWS CLI with SSO..."
    aws configure sso --profile default <<< "$PORTAL_URL
$AWS_REGION


$AWS_REGION
json
default"

    success "SSO session configured"
}

create_profile() {
    local profile_name=$1
    local account_id=$2
    local role_name=${3:-DeveloperAccess}

    log "Creating profile: $profile_name"

    mkdir -p ~/.aws

    # Append profile to AWS config
    cat >> ~/.aws/config <<EOF

[profile $profile_name]
sso_session = $SSO_SESSION_NAME
sso_account_id = $account_id
sso_role_name = $role_name
region = $AWS_REGION
output = json
EOF
}

create_profiles() {
    log "Creating AWS CLI profiles..."

    # Backup existing config
    if [ -f ~/.aws/config ]; then
        cp ~/.aws/config ~/.aws/config.backup
        warning "Backed up existing AWS config to ~/.aws/config.backup"
    fi

    # Create config file with SSO session
    cat > ~/.aws/config <<EOF
[default]
region = $AWS_REGION
output = json

[sso-session $SSO_SESSION_NAME]
sso_start_url = $PORTAL_URL
sso_region = $AWS_REGION
sso_registration_scopes = sso:account:access

[profile default]
sso_session = $SSO_SESSION_NAME
sso_account_id = $MANAGEMENT_ACCOUNT_ID
sso_role_name = DeveloperAccess
region = $AWS_REGION
output = json
EOF

    # Create profiles for each account
    create_profile "shared-services" "$SHARED_SERVICES_ACCOUNT_ID" "SharedServicesAccess"
    create_profile "security" "$SECURITY_ACCOUNT_ID" "ReadOnlyAccess"
    create_profile "inavor-dev" "$INAVOR_DEV_ACCOUNT_ID" "DeveloperAccess"

    if [ -n "$INAVOR_STAGING_ACCOUNT_ID" ] && [ "$INAVOR_STAGING_ACCOUNT_ID" != "" ]; then
        create_profile "inavor-staging" "$INAVOR_STAGING_ACCOUNT_ID" "DeveloperAccess"
    fi

    if [ -n "$INAVOR_PROD_ACCOUNT_ID" ] && [ "$INAVOR_PROD_ACCOUNT_ID" != "" ]; then
        create_profile "inavor-prod" "$INAVOR_PROD_ACCOUNT_ID" "ReadOnlyAccess"
    fi

    success "AWS CLI profiles created in ~/.aws/config"
}

test_profiles() {
    log "Testing AWS CLI profiles..."
    echo ""

    echo "Testing default profile:"
    if aws sts get-caller-identity --profile default &>/dev/null 2>&1; then
        echo "  ✓ Default profile works (may need SSO login)"
    else
        echo "  ✗ Default profile not yet authenticated"
        echo "    Run: aws sso login"
    fi

    echo ""
    echo "To authenticate with Identity Center:"
    echo "  aws sso login --profile default"
    echo ""
    echo "Then test profile access:"
    echo "  aws sts get-caller-identity --profile default"
    echo "  aws sts get-caller-identity --profile inavor-dev"
    echo ""
}

print_usage() {
    log "Usage of AWS CLI profiles:"
    echo ""
    echo "Log in to Identity Center:"
    echo "  aws sso login --profile default"
    echo ""
    echo "Use profiles in commands:"
    echo "  aws sts get-caller-identity --profile inavor-dev"
    echo "  aws dynamodb list-tables --profile inavor-dev"
    echo ""
    echo "Set default profile for a session:"
    echo "  export AWS_PROFILE=inavor-dev"
    echo "  aws sts get-caller-identity  # Uses inavor-dev profile"
    echo ""
}

main() {
    echo ""
    echo -e "${BLUE}╔═════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     AWS CLI Profile Setup                   ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -z "$PORTAL_URL" ]; then
        log "No portal URL provided, interactive mode required"
        setup_sso_session
    else
        log "Using provided portal URL"
    fi

    echo ""
    create_profiles
    echo ""
    test_profiles
    echo ""
    print_usage
}

main
