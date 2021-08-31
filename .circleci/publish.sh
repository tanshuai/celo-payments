#!/usr/bin/env bash

if [ ! "$1" ]; then
  echo "Usage: publish.sh <version>       See 'npm version --help' for version conventions"
  exit 1
fi

if [ -z "$NPM_REGISTRY_URL" ]; then
  NPM_REGISTRY_URL=$(npm config get registry)
fi

PACKAGE_NAME=$(node -p "require('./package.json').name")

BOLD='\033[1m'
NORMAL='\033[00m'

echo -e "🚀 Publishing ${BOLD}$PACKAGE_NAME${NORMAL} to $NPM_REGISTRY_URL\n"

if [ $NPM_REGISTRY_URL == 'https://registry.npmjs.org/' ]; then
  echo "❌ npmjs registry is not supported at the moment"
  exit 1
fi

echo "⏫ Bumping '$1' version ..."

CURRENT_VERSION=$(npm view --registry $NPM_REGISTRY_URL ${PACKAGE_NAME}@latest version || node -p "require('./package.json').version")
echo "⌗ Current version: $CURRENT_VERSION"

echo "⌗ Bumping to:"
npm version --no-git-tag-version --allow-same-version "$CURRENT_VERSION" > /dev/null || exit 1
NEW_VERSION=$(npm version --no-git-tag-version "$1") || exit 1

echo "📡 Publishing ..."
npm publish --registry $NPM_REGISTRY_URL || exit 1

echo "🚀 Pushing to GitHub..."
git config --global user.email "ci@firstdag.com"
git config --global user.name "CircleCI"
git add package.json package-lock.json
git commit --no-verify -m "[skip ci] Bump npm package version from $CURRENT_VERSION [level '$1'] to $NEW_VERSION" || exit 1
git branch --set-upstream-to=origin/$(git rev-parse --abbrev-ref HEAD)
git push --no-verify || exit 1

echo "✅ DONE"
