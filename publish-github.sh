#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_DIR}"

REPO_NAME="t2-touchid-touchbar-bridge-ubuntu-24"
DESC="Apple T2 Touch Bar Debounce, Sleep Persistence & Touch ID CDC-NCM Bridge for Ubuntu 24.04 LTS"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

export PATH="${HOME}/.local/bin:/tmp:${PATH}"

echo -e "${CYAN}==> Publishing ${REPO_NAME} to GitHub...${NC}"

GH_USER="$(gh api user -q .login)"
echo -e "${GREEN}[✓] Authenticated as @${GH_USER}${NC}"

git config user.name "${GH_USER}"
git config user.email "mylnzon58@gmail.com"
gh auth setup-git

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    git init -b main
    git add .
    git commit -m "feat: initial commit - Apple T2 Touch Bar and Touch ID bridge for Ubuntu 24.04 LTS"
else
    git add .
    git commit -m "feat: update T2 bridge configurations and scripts" || true
fi

if gh repo view "${GH_USER}/${REPO_NAME}" &>/dev/null; then
    echo -e "${CYAN}[i] Repository already exists. Pushing...${NC}"
    git remote set-url origin "https://github.com/${GH_USER}/${REPO_NAME}.git" 2>/dev/null || \
        git remote add origin "https://github.com/${GH_USER}/${REPO_NAME}.git"
    git push -u origin main --force
else
    echo -e "${CYAN}==> Creating public repository...${NC}"
    gh repo create "${REPO_NAME}" --public --source=. --remote=origin --description "${DESC}" --push
fi

echo -e "${CYAN}==> Setting topics & homepage...${NC}"
gh repo edit "${GH_USER}/${REPO_NAME}" \
    --homepage "https://${GH_USER}.github.io/${REPO_NAME}/" \
    --add-topic "apple-t2" \
    --add-topic "touch-bar" \
    --add-topic "touch-id" \
    --add-topic "macbook-pro" \
    --add-topic "ubuntu-24-04" \
    --add-topic "linux" \
    --add-topic "remotexpc" \
    --add-topic "bridgeos" || true

echo -e "${CYAN}==> Activating GitHub Pages...${NC}"
gh api -X POST "repos/${GH_USER}/${REPO_NAME}/pages" \
    -f "source[branch]=main" -f "source[path]=/docs" 2>/dev/null || \
gh api -X PUT "repos/${GH_USER}/${REPO_NAME}/pages" \
    -f "source[branch]=main" -f "source[path]=/docs" 2>/dev/null || true

echo -e "\n${GREEN}[✓] Public Repo:${NC} https://github.com/${GH_USER}/${REPO_NAME}"
echo -e "${GREEN}[✓] Live Page:${NC} https://${GH_USER}.github.io/${REPO_NAME}/"

