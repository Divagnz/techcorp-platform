#!/bin/bash

# Script to test automatic version bump detection from conventional commits
# Usage: ./test-auto-detect.sh [project-name]

set -e

PROJECT=${1:-"@nx-project-release"}
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Auto-Detection Test Script${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${BOLD}Project:${NC} ${PROJECT}"
echo ""

# Check if project exists
if ! npx nx show project ${PROJECT} > /dev/null 2>&1; then
  echo -e "${RED}❌ Project '${PROJECT}' not found${NC}"
  echo ""
  echo "Available projects:"
  npx nx show projects
  exit 1
fi

echo -e "${BOLD}${GREEN}Step 1: Preview Current State${NC}"
echo "Running: ${YELLOW}nx run ${PROJECT}:version --preview${NC}"
echo ""
npx nx run ${PROJECT}:version --preview || true
echo ""

echo -e "${BOLD}${GREEN}Step 2: Check Recent Commits${NC}"
echo "Last 10 commits on current branch:"
echo ""
git log --oneline -10 --no-decorate
echo ""

echo -e "${BOLD}${GREEN}Step 3: Get Current Version${NC}"
CURRENT_VERSION=$(node -p "require('./packages/project-release/package.json').version" 2>/dev/null || echo "unknown")
echo -e "Current version: ${YELLOW}${CURRENT_VERSION}${NC}"
echo ""

echo -e "${BOLD}${GREEN}Step 4: Test Auto-Detection (Dry Run)${NC}"
echo "Running: ${YELLOW}nx run ${PROJECT}:version --dryRun${NC}"
echo ""
echo "This will analyze conventional commits and show what bump it would do:"
echo ""
npx nx run ${PROJECT}:version --dryRun
echo ""

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Test Scenarios${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""

echo -e "${BOLD}Scenario 1: Auto-detect (recommended)${NC}"
echo -e "${GREEN}✓ Command:${NC} nx run ${PROJECT}:version --gitCommit --gitTag"
echo -e "${GREEN}✓ Behavior:${NC} Analyzes conventional commits to determine bump type"
echo ""

echo -e "${BOLD}Scenario 2: Manual override${NC}"
echo -e "${YELLOW}⚠ Command:${NC} nx run ${PROJECT}:version --releaseAs=major --gitCommit --gitTag"
echo -e "${YELLOW}⚠ Behavior:${NC} Forces major bump regardless of commits"
echo ""

echo -e "${BOLD}Scenario 3: Preview only${NC}"
echo -e "${BLUE}ℹ Command:${NC} nx run ${PROJECT}:version --preview"
echo -e "${BLUE}ℹ Behavior:${NC} Shows what would change without making changes"
echo ""

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Commit Type Reference${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${GREEN}Patch bump (0.0.1 → 0.0.2):${NC}"
echo "  - fix(scope): description"
echo "  - perf(scope): description"
echo "  - docs(scope): description"
echo ""
echo -e "${YELLOW}Minor bump (0.0.1 → 0.1.0):${NC}"
echo "  - feat(scope): description"
echo ""
echo -e "${RED}Major bump (0.0.1 → 1.0.0):${NC}"
echo "  - feat(scope)!: description"
echo "  - fix(scope)!: description"
echo "  - BREAKING CHANGE: description in body"
echo ""

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Next Steps${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo "1. Review the preview above to see what bump would be applied"
echo "2. Make test commits with conventional format if needed:"
echo "   ${GREEN}git commit -m 'feat(test): add new feature'${NC}"
echo "3. Run auto-detection:"
echo "   ${GREEN}nx run ${PROJECT}:version --dryRun${NC}"
echo "4. If satisfied, create real version:"
echo "   ${GREEN}nx run ${PROJECT}:version --gitCommit --gitTag${NC}"
echo ""
