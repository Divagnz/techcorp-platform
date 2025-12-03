#!/bin/bash

# Local Release Flow Test Script
# Tests the complete release workflow locally without pushing to remote

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT=${1:-"@nx-project-release"}
RELEASE_AS=${2:-""}

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Local Release Flow Test${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${BOLD}Project:${NC} ${PROJECT}"
echo -e "${BOLD}Release Type:${NC} ${RELEASE_AS:-auto-detect from commits}"
echo ""

# Safety check
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${YELLOW}⚠️  Current branch: ${CURRENT_BRANCH}${NC}"
echo ""
read -p "This will create commits and tags locally. Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi
echo ""

# Save current state for rollback
INITIAL_COMMIT=$(git rev-parse HEAD)
echo -e "${BLUE}ℹ️  Saved current commit: ${INITIAL_COMMIT:0:7}${NC}"
echo ""

# Create rollback function
rollback() {
    echo ""
    echo -e "${YELLOW}Rolling back changes...${NC}"
    git reset --hard ${INITIAL_COMMIT}
    git tag -l | xargs -I {} sh -c 'git tag -d {} 2>/dev/null || true'
    echo -e "${GREEN}✓ Rolled back to ${INITIAL_COMMIT:0:7}${NC}"
}

# Set trap for cleanup on error
trap rollback ERR

echo -e "${BOLD}${GREEN}Step 1: Preview Version Bump${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
npx nx run ${PROJECT}:version --preview
echo ""

read -p "Continue with version bump? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi
echo ""

echo -e "${BOLD}${GREEN}Step 2: Bump Version${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Build version command
VERSION_CMD="npx nx run ${PROJECT}:version"
if [ -n "${RELEASE_AS}" ]; then
    VERSION_CMD="${VERSION_CMD} --releaseAs=${RELEASE_AS}"
    echo -e "${YELLOW}→ Manual override: ${RELEASE_AS}${NC}"
else
    echo -e "${GREEN}→ Auto-detecting from conventional commits${NC}"
fi
VERSION_CMD="${VERSION_CMD} --gitCommit --gitTag"

echo "Running: ${VERSION_CMD}"
echo ""
eval ${VERSION_CMD}
echo ""

NEW_VERSION=$(node -p "require('./packages/project-release/package.json').version" 2>/dev/null || echo "unknown")
NEW_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "no-tag")
echo -e "${GREEN}✓ New version: ${NEW_VERSION}${NC}"
echo -e "${GREEN}✓ New tag: ${NEW_TAG}${NC}"
echo ""

echo -e "${BOLD}${GREEN}Step 3: Generate Changelog${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
npx nx run ${PROJECT}:changelog
echo ""

if [ -f "packages/project-release/CHANGELOG.md" ]; then
    echo -e "${GREEN}✓ CHANGELOG.md generated${NC}"
    echo ""
    echo "Preview (first 20 lines):"
    head -n 20 packages/project-release/CHANGELOG.md
    echo ""
else
    echo -e "${YELLOW}⚠️  No CHANGELOG.md found${NC}"
fi

echo -e "${BOLD}${GREEN}Step 4: Build${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
npx nx run ${PROJECT}:build
echo ""
echo -e "${GREEN}✓ Build completed${NC}"
echo ""

echo ""
if [ -d "dist/project-release" ]; then
    echo -e "${GREEN}✓ dist/project-release exists${NC}"
    echo ""
    echo "Contents:"
    ls -lh dist/project-release/ | head -n 10
    echo ""

    DIST_VERSION=$(node -p "require('./dist/project-release/package.json').version" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Dist version: ${DIST_VERSION}${NC}"
else
    echo -e "${RED}✗ dist/project-release not found${NC}"
fi
echo ""

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Release Flow Summary${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${BOLD}Version:${NC} ${NEW_VERSION}"
echo -e "${BOLD}Tag:${NC} ${NEW_TAG}"
echo -e "${BOLD}Branch:${NC} ${CURRENT_BRANCH}"
echo ""

echo -e "${BOLD}Git Status:${NC}"
git status --short
echo ""

echo -e "${BOLD}Recent Commits:${NC}"
git log --oneline -3
echo ""

echo -e "${BOLD}Tags Created:${NC}"
git tag -l | tail -n 3
echo ""

echo -e "${BOLD}${YELLOW}⚠️  Next Steps:${NC}"
echo ""
echo "The release was created locally. You have three options:"
echo ""
echo -e "${GREEN}1. Keep changes and push:${NC}"
echo "   git push"
echo "   git push --tags"
echo "   cd dist/project-release && npm publish --access public"
echo ""
echo -e "${YELLOW}2. Keep for review:${NC}"
echo "   Review the changes, then decide to push or rollback"
echo ""
echo -e "${RED}3. Rollback everything:${NC}"
echo "   git reset --hard ${INITIAL_COMMIT:0:7}"
echo "   git tag -d ${NEW_TAG}"
echo ""

read -p "Rollback all changes now? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rollback
    echo ""
    echo -e "${GREEN}✓ All changes rolled back${NC}"
else
    echo ""
    echo -e "${YELLOW}Changes preserved. You can review and decide what to do.${NC}"
    echo ""
    echo "To rollback later, run:"
    echo "  git reset --hard ${INITIAL_COMMIT:0:7}"
    echo "  git tag -d ${NEW_TAG}"
fi

echo ""
echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${GREEN}✓ Local release test completed${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
