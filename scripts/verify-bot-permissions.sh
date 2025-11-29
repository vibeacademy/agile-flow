#!/bin/bash

# Bot Permissions Verification Script
# Part of Epic #1 - Bot Account Infrastructure Setup (Issue #5)
#
# Verifies that va-worker and va-reviewer have correct permissions
# and are properly restricted from destructive actions.

# Don't use set -e as we handle errors manually in tests

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="vibeacademy/agile-flow"
MAIN_BRANCH="main"

# Counters
PASS=0
FAIL=0
SKIP=0

# Store original account
ORIGINAL_ACCOUNT=""

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${BLUE}Bot Permissions Verification Script${NC}              ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((FAIL++))
}

skip() {
    echo -e "${YELLOW}○ SKIP:${NC} $1"
    ((SKIP++))
}

info() {
    echo -e "${BLUE}→${NC} $1"
}

cleanup() {
    # Restore original account if we changed it
    if [ -n "$ORIGINAL_ACCOUNT" ]; then
        gh auth switch --user "$ORIGINAL_ACCOUNT" 2>/dev/null || true
    fi
}

trap cleanup EXIT

get_active_account() {
    gh auth status 2>&1 | grep "Active account: true" -B3 | grep "account" | head -1 | sed 's/.*account //' | sed 's/ .*//'
}

switch_to_account() {
    local account=$1
    gh auth switch --user "$account" 2>/dev/null || return 1
    return 0
}

check_account_exists() {
    local account=$1
    gh auth status 2>&1 | grep -q "account $account" && return 0 || return 1
}

# =============================================================================
# Tests
# =============================================================================

test_va_worker_exists() {
    info "Checking if va-worker account exists..."
    if check_account_exists "va-worker"; then
        pass "va-worker account exists in gh CLI"
    else
        fail "va-worker account not found in gh CLI"
    fi
}

test_va_reviewer_exists() {
    info "Checking if va-reviewer account exists..."
    if check_account_exists "va-reviewer"; then
        pass "va-reviewer account exists in gh CLI"
    else
        fail "va-reviewer account not found in gh CLI"
    fi
}

test_va_worker_scopes() {
    info "Checking va-worker PAT scopes..."

    local status=$(gh auth status 2>&1)
    local va_worker_section=$(echo "$status" | grep -A5 "account va-worker")

    if echo "$va_worker_section" | grep -q "repo" && \
       echo "$va_worker_section" | grep -q "read:org" && \
       echo "$va_worker_section" | grep -q "project"; then
        pass "va-worker has required scopes (repo, read:org, project)"
    else
        fail "va-worker missing required scopes"
        echo "  Current scopes: $(echo "$va_worker_section" | grep "Token scopes")"
    fi
}

test_va_reviewer_scopes() {
    info "Checking va-reviewer PAT scopes..."

    local status=$(gh auth status 2>&1)
    local va_reviewer_section=$(echo "$status" | grep -A5 "account va-reviewer")

    if echo "$va_reviewer_section" | grep -q "repo" && \
       echo "$va_reviewer_section" | grep -q "read:org" && \
       echo "$va_reviewer_section" | grep -q "project"; then
        pass "va-reviewer has required scopes (repo, read:org, project)"
    else
        fail "va-reviewer missing required scopes"
        echo "  Current scopes: $(echo "$va_reviewer_section" | grep "Token scopes")"
    fi
}

test_va_worker_repo_access() {
    info "Testing if va-worker can access repository..."

    if ! switch_to_account "va-worker"; then
        fail "va-worker repo access test (auth switch failed)"
        return
    fi

    if gh repo view "$REPO" --json name -q '.name' >/dev/null 2>&1; then
        pass "va-worker can access repository"
    else
        fail "va-worker cannot access repository"
    fi
}

test_va_worker_pr_api_access() {
    info "Testing if va-worker can access PR API (needed to create PRs)..."

    if ! switch_to_account "va-worker"; then
        fail "va-worker PR API test (auth switch failed)"
        return
    fi

    if gh pr list --repo "$REPO" --limit 1 >/dev/null 2>&1; then
        pass "va-worker can access PR API"
    else
        fail "va-worker cannot access PR API"
    fi
}

test_va_reviewer_repo_access() {
    info "Testing if va-reviewer can access repository..."

    if ! switch_to_account "va-reviewer"; then
        fail "va-reviewer repo access test (auth switch failed)"
        return
    fi

    if gh repo view "$REPO" --json name -q '.name' >/dev/null 2>&1; then
        pass "va-reviewer can access repository"
    else
        fail "va-reviewer cannot access repository"
    fi
}

test_va_reviewer_pr_api_access() {
    info "Testing if va-reviewer can access PR API (needed to review PRs)..."

    if ! switch_to_account "va-reviewer"; then
        fail "va-reviewer PR API test (auth switch failed)"
        return
    fi

    if gh pr list --repo "$REPO" --limit 1 >/dev/null 2>&1; then
        pass "va-reviewer can access PR API"
    else
        fail "va-reviewer cannot access PR API"
    fi
}

test_branch_protection_active() {
    info "Testing if branch protection is active on main..."

    # Switch to any authenticated account
    switch_to_account "va-worker" 2>/dev/null || true

    local ruleset=$(gh api "repos/$REPO/rulesets" --jq '.[] | select(.name | test("main|Protect"; "i"))' 2>/dev/null)

    if [ -n "$ruleset" ]; then
        local enforcement=$(echo "$ruleset" | jq -r '.enforcement' 2>/dev/null)
        if [ "$enforcement" == "active" ]; then
            pass "Branch protection is active on main"
        else
            fail "Branch protection exists but is not active (enforcement: $enforcement)"
        fi
    else
        fail "No branch protection ruleset found for main"
    fi
}

test_required_status_checks() {
    info "Testing if required status checks are configured..."

    switch_to_account "va-worker" 2>/dev/null || true

    # Get ruleset ID first, then query its rules
    local ruleset_id=$(gh api "repos/$REPO/rulesets" --jq '.[0].id' 2>/dev/null)
    local checks=""
    if [ -n "$ruleset_id" ]; then
        checks=$(gh api "repos/$REPO/rulesets/$ruleset_id" --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[].context' 2>/dev/null)
    fi

    if [ -n "$checks" ]; then
        local expected_checks="lint typecheck build test"
        local missing=""

        for check in $expected_checks; do
            if ! echo "$checks" | grep -q "^$check$"; then
                missing="$missing $check"
            fi
        done

        if [ -z "$missing" ]; then
            pass "All required status checks configured (lint, typecheck, build, test)"
        else
            fail "Missing required status checks:$missing"
        fi
    else
        fail "No required status checks configured"
    fi
}

test_approval_required() {
    info "Testing if PR approval is required..."

    switch_to_account "va-worker" 2>/dev/null || true

    local ruleset_id=$(gh api "repos/$REPO/rulesets" --jq '.[0].id' 2>/dev/null)
    local approval_count=""
    if [ -n "$ruleset_id" ]; then
        approval_count=$(gh api "repos/$REPO/rulesets/$ruleset_id" --jq '.rules[] | select(.type=="pull_request") | .parameters.required_approving_review_count' 2>/dev/null)
    fi

    if [ -n "$approval_count" ] && [ "$approval_count" -ge 1 ]; then
        pass "PR approval required (count: $approval_count)"
    else
        fail "PR approval not required or count is 0"
    fi
}

test_force_push_blocked() {
    info "Testing if force push is blocked..."

    switch_to_account "va-worker" 2>/dev/null || true

    local ruleset_id=$(gh api "repos/$REPO/rulesets" --jq '.[0].id' 2>/dev/null)
    local non_ff=""
    if [ -n "$ruleset_id" ]; then
        non_ff=$(gh api "repos/$REPO/rulesets/$ruleset_id" --jq '.rules[] | select(.type=="non_fast_forward")' 2>/dev/null)
    fi

    if [ -n "$non_ff" ]; then
        pass "Force push blocked (non_fast_forward rule active)"
    else
        fail "Force push NOT blocked"
    fi
}

test_deletion_blocked() {
    info "Testing if branch deletion is blocked..."

    switch_to_account "va-worker" 2>/dev/null || true

    local ruleset_id=$(gh api "repos/$REPO/rulesets" --jq '.[0].id' 2>/dev/null)
    local deletion=""
    if [ -n "$ruleset_id" ]; then
        deletion=$(gh api "repos/$REPO/rulesets/$ruleset_id" --jq '.rules[] | select(.type=="deletion")' 2>/dev/null)
    fi

    if [ -n "$deletion" ]; then
        pass "Branch deletion blocked"
    else
        fail "Branch deletion NOT blocked"
    fi
}

test_linear_history_required() {
    info "Testing if linear history is required..."

    switch_to_account "va-worker" 2>/dev/null || true

    local ruleset_id=$(gh api "repos/$REPO/rulesets" --jq '.[0].id' 2>/dev/null)
    local linear=""
    if [ -n "$ruleset_id" ]; then
        linear=$(gh api "repos/$REPO/rulesets/$ruleset_id" --jq '.rules[] | select(.type=="required_linear_history")' 2>/dev/null)
    fi

    if [ -n "$linear" ]; then
        pass "Linear history required"
    else
        skip "Linear history not required (optional)"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header

    # Store original account to restore later
    ORIGINAL_ACCOUNT=$(get_active_account)
    info "Current account: $ORIGINAL_ACCOUNT"
    info "Repository: $REPO"
    info "Main branch: $MAIN_BRANCH"

    # Run tests
    print_section "Account Existence Tests"
    test_va_worker_exists
    test_va_reviewer_exists

    print_section "PAT Scope Tests"
    test_va_worker_scopes
    test_va_reviewer_scopes

    print_section "Repository Access Tests"
    test_va_worker_repo_access
    test_va_worker_pr_api_access
    test_va_reviewer_repo_access
    test_va_reviewer_pr_api_access

    print_section "Branch Protection Tests"
    test_branch_protection_active
    test_required_status_checks
    test_approval_required
    test_force_push_blocked
    test_deletion_blocked
    test_linear_history_required

    # Summary
    print_section "Summary"
    echo ""
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Skipped:${NC} $SKIP"
    echo ""

    # Document expected restrictions
    echo -e "${BLUE}Expected Permission Matrix:${NC}"
    echo ""
    echo "  | Action              | va-worker | va-reviewer | Human |"
    echo "  |---------------------|-----------|-------------|-------|"
    echo "  | Create branches     | Yes       | No          | Yes   |"
    echo "  | Push to branches    | Yes       | No          | Yes   |"
    echo "  | Create PRs          | Yes       | No          | Yes   |"
    echo "  | Review PRs          | No        | Yes         | Yes   |"
    echo "  | Approve PRs         | No        | Yes         | Yes   |"
    echo "  | Merge PRs           | No        | No          | Yes   |"
    echo "  | Push to main        | No        | No          | No    |"
    echo ""

    if [ $FAIL -eq 0 ]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}  ${GREEN}PASS: All bot restrictions verified${NC}                      ${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${NC}  ${RED}FAIL: Some restrictions not working - review above${NC}        ${RED}║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# Run main
main "$@"
