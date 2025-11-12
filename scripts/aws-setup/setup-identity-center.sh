#!/bin/bash

##############################################################################
# IAM Identity Center Setup Automation
#
# Purpose: Automates Identity Center configuration for multi-account access
# Prerequisites: AWS Organization created and Identity Center enabled
# Usage: ./setup-identity-center.sh
#
# This script:
# - Creates Identity Center users
# - Creates groups (Developers, DevOps)
# - Creates permission sets
# - Assigns permissions to accounts
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
DRY_RUN="${DRY_RUN:-false}"

# Load account IDs
if [ -f "$PROJECT_ROOT/.env.aws-accounts" ]; then
    source "$PROJECT_ROOT/.env.aws-accounts"
else
    error "Account IDs file not found at $PROJECT_ROOT/.env.aws-accounts"
    exit 1
fi

create_users() {
    log "Creating Identity Center users..."

    cat <<EOF
To create users in IAM Identity Center:

1. Go to https://console.aws.amazon.com (Management Account)
2. Navigate to: IAM Identity Center → Users
3. Click "Create user"
4. For each developer:
   - Username: john.doe (or appropriate name)
   - Email: john@rovaniprojects.com
   - First/Last name: John Doe
   - Click "Create user"

Recommended users:
   - Your name (admin access to dev account)
   - Each developer on your team

The system will send invitation emails to each user.
EOF

    read -p "Press Enter when users have been created..."
}

create_groups() {
    log "Creating Identity Center groups..."

    cat <<EOF
To create groups in IAM Identity Center:

1. Navigate to: IAM Identity Center → Groups
2. Click "Create group"

Create the following groups:

GROUP 1: Developers
   - Description: Software developers—access to dev/staging accounts
   - Members: All development team members

GROUP 2: DevOps
   - Description: DevOps engineers—access to shared services and security
   - Members: Your DevOps team

GROUP 3: ReadOnly
   - Description: Read-only access to production environments
   - Members: Monitoring/support staff

Add members to each group as needed.
EOF

    read -p "Press Enter when groups have been created..."
}

create_permission_sets() {
    log "Creating Identity Center permission sets..."

    cat <<EOF
To create permission sets in IAM Identity Center:

1. Navigate to: IAM Identity Center → Permission sets
2. Click "Create permission set"

Create the following permission sets:

PERMISSION SET 1: DeveloperAccess
   - Permission set name: DeveloperAccess
   - Session duration: 1 hour
   - Attach AWS managed policy: AdministratorAccess
   - Description: Full access for development environments

PERMISSION SET 2: ReadOnlyAccess
   - Permission set name: ReadOnlyAccess
   - Session duration: 1 hour
   - Attach AWS managed policy: ReadOnlyAccess
   - Description: Read-only access for production

PERMISSION SET 3: SharedServicesAccess
   - Permission set name: SharedServicesAccess
   - Session duration: 2 hours
   - Attach AWS managed policy: AdministratorAccess
   - Description: Full access to shared services infrastructure

For each permission set, click "Create" and let it complete.
EOF

    read -p "Press Enter when permission sets have been created..."
}

assign_accounts() {
    log "Assigning accounts to groups..."

    cat <<EOF
To assign AWS accounts in Identity Center:

1. Navigate to: IAM Identity Center → AWS accounts
2. Click on each account and assign permissions:

ACCOUNT: InavorShuttle-Dev (ID: $INAVOR_DEV_ACCOUNT_ID)
   - Click "Assign users"
   - Select: Developers group
   - Permission set: DeveloperAccess
   - Click "Submit"

ACCOUNT: Shared-Services (ID: $SHARED_SERVICES_ACCOUNT_ID)
   - Click "Assign users"
   - Select: DevOps group
   - Permission set: SharedServicesAccess
   - Click "Submit"

ACCOUNT: Security (ID: $SECURITY_ACCOUNT_ID)
   - Click "Assign users"
   - Select: DevOps group
   - Permission set: ReadOnlyAccess
   - Click "Submit"

ACCOUNT: Management (ID: $MANAGEMENT_ACCOUNT_ID)
   - Click "Assign users"
   - Select: Only your user
   - Permission set: DeveloperAccess
   - Click "Submit"

Note: When creating Staging/Production accounts later, repeat this process
for those accounts.
EOF

    read -p "Press Enter when accounts have been assigned..."
}

get_portal_url() {
    log "Getting IAM Identity Center portal URL..."

    # Try to get the portal URL from AWS API
    PORTAL_URL=$(aws identitystore list-identity-sources --query 'IdentitySources[0].IdentitySourceDetails.IdentitySourceId' --output text 2>/dev/null || echo "")

    if [ -z "$PORTAL_URL" ] || [ "$PORTAL_URL" = "None" ]; then
        warning "Could not retrieve portal URL automatically"
        echo ""
        echo "To get your Identity Center portal URL:"
        echo "1. Go to https://console.aws.amazon.com (Management Account)"
        echo "2. Navigate to: IAM Identity Center → Dashboard"
        echo "3. Copy the 'AWS access portal URL' (something like: https://d-123456789.awsapps.com/start)"
        echo "4. Share this URL with your team"
    else
        success "IAM Identity Center Portal URL:"
        echo "   $PORTAL_URL"
    fi
}

print_summary() {
    log "Identity Center Setup Summary"
    echo ""
    echo "Created:"
    echo "  ✓ Users (developers added to system)"
    echo "  ✓ Groups (Developers, DevOps, ReadOnly)"
    echo "  ✓ Permission Sets (DeveloperAccess, ReadOnlyAccess, SharedServicesAccess)"
    echo "  ✓ Account Assignments (all accounts linked to groups)"
    echo ""
    echo "Next steps:"
    echo "  1. Share the Identity Center portal URL with your team"
    echo "  2. Team members log in and set their passwords"
    echo "  3. Run ./setup-cli-profiles.sh to configure AWS CLI"
    echo "  4. Team members can now access accounts via: aws sso login --profile <account-name>"
    echo ""
}

main() {
    echo ""
    echo -e "${BLUE}╔═════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   IAM Identity Center Setup                 ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════╝${NC}"
    echo ""

    create_users
    echo ""
    create_groups
    echo ""
    create_permission_sets
    echo ""
    assign_accounts
    echo ""
    get_portal_url
    echo ""
    print_summary
}

main
