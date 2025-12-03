#!/bin/bash

# Script to simulate GitHub Actions workflow behavior locally
# Tests the same commands that would run in CI/CD

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
PROJECT=""
RELEASE_AS=""
DRY_RUN="false"
MODE="affected"

while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT="$2"
      MODE="single"
      shift 2
      ;;
    --releaseAs)
      RELEASE_AS="$2"
      shift 2
      ;;
    --dryRun)
      DRY_RUN="true"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--project PROJECT_NAME] [--releaseAs patch|minor|major] [--dryRun]"
      exit 1
      ;;
  esac
done

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Workflow Simulation${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${BOLD}Mode:${NC} ${MODE}"
if [ "$MODE" = "single" ]; then
  echo -e "${BOLD}Project:${NC} ${PROJECT}"
fi
echo -e "${BOLD}Release Type:${NC} ${RELEASE_AS:-auto-detect}"
echo -e "${BOLD}Dry Run:${NC} ${DRY_RUN}"
echo ""

# Simulate workflow steps
echo -e "${BOLD}${GREEN}Step 1: Determine Release Mode${NC}"
if [ "$MODE" = "single" ]; then
  echo "  Mode: single project"
  echo "  Project: ${PROJECT}"
else
  echo "  Mode: affected projects"
fi
echo ""

echo -e "${BOLD}${GREEN}Step 2: Version${NC}"
if [ "$MODE" = "single" ]; then
  echo -e "Running: ${YELLOW}nx run ${PROJECT}:version${NC}"

  # Build command based on inputs
  CMD="npx nx run ${PROJECT}:version"

  # Add releaseAs only if provided (auto-detect otherwise)
  if [ -n "${RELEASE_AS}" ]; then
    CMD="${CMD} --releaseAs=${RELEASE_AS}"
    echo -e "  ${YELLOW}→ Manual override:${NC} ${RELEASE_AS}"
  else
    echo -e "  ${GREEN}→ Auto-detecting from conventional commits${NC}"
  fi

  # Add dry run flag
  if [ "${DRY_RUN}" = "true" ]; then
    CMD="${CMD} --dryRun"
  fi

  echo ""
  echo "Executing: ${CMD}"
  echo ""
  eval ${CMD}

else
  echo -e "Running: ${YELLOW}nx affected -t version --base=origin/main~1${NC}"

  # Build command
  CMD="npx nx affected -t version --base=origin/main~1"

  # Add releaseAs only if provided
  if [ -n "${RELEASE_AS}" ]; then
    CMD="${CMD} --releaseAs=${RELEASE_AS}"
    echo -e "  ${YELLOW}→ Manual override:${NC} ${RELEASE_AS}"
  else
    echo -e "  ${GREEN}→ Auto-detecting from conventional commits${NC}"
  fi

  # Add dry run flag
  if [ "${DRY_RUN}" = "true" ]; then
    CMD="${CMD} --dryRun"
  fi

  echo ""
  echo "Executing: ${CMD}"
  echo ""
  eval ${CMD}
fi
echo ""

if [ "${DRY_RUN}" != "true" ]; then
  echo -e "${BOLD}${GREEN}Step 3: Changelog${NC}"
  if [ "$MODE" = "single" ]; then
    echo "Running: nx run ${PROJECT}:changelog"
    npx nx run ${PROJECT}:changelog
  else
    echo "Running: nx affected -t changelog --base=origin/main~1"
    npx nx affected -t changelog --base=origin/main~1
  fi
  echo ""

  echo -e "${BOLD}${GREEN}Step 4: Summary${NC}"
  echo "Changes made (git status):"
  git status --short
  echo ""
fi

echo -e "${BOLD}${BLUE}================================${NC}"
echo -e "${BOLD}${BLUE}Workflow Summary${NC}"
echo -e "${BOLD}${BLUE}================================${NC}"
echo ""
echo -e "${BOLD}Mode:${NC} ${MODE}"
if [ "$MODE" = "single" ]; then
  echo -e "${BOLD}Project:${NC} ${PROJECT}"
fi
echo -e "${BOLD}Release Type:${NC} ${RELEASE_AS:-auto-detect}"
echo -e "${BOLD}Dry Run:${NC} ${DRY_RUN}"
echo ""

if [ "${DRY_RUN}" = "true" ]; then
  echo -e "${GREEN}✅ Dry run completed successfully${NC}"
  echo "No changes were made to files or git history"
else
  echo -e "${YELLOW}⚠ Changes were made to files${NC}"
  echo "Review with: git status"
  echo "Commit with: git add . && git commit -m 'chore(release): version bumps and changelogs'"
fi
echo ""

echo -e "${BOLD}Test Examples:${NC}"
echo ""
echo "1. Test single project with auto-detection (dry run):"
echo "   ${GREEN}./test-workflow-simulation.sh --project @nx-project-release --dryRun${NC}"
echo ""
echo "2. Test affected projects with manual bump (dry run):"
echo "   ${GREEN}./test-workflow-simulation.sh --releaseAs patch --dryRun${NC}"
echo ""
echo "3. Test affected projects with auto-detection (real):"
echo "   ${GREEN}./test-workflow-simulation.sh${NC}"
echo ""
echo "4. Test single project with manual major bump (real):"
echo "   ${GREEN}./test-workflow-simulation.sh --project @nx-project-release --releaseAs major${NC}"
echo ""
