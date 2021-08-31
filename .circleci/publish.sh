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

echo "⏫ Bumping version ..."

CURRENT_VERSION=$(npm view --registry $NPM_REGISTRY_URL @celo/payments-sdk@latest version || node -p "require('./packages/sdk/package.json').version")
echo "⌗ Current version: $CURRENT_VERSION"

echo -n "⌗ Bumping to: "
RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
MAJOR=`echo $CURRENT_VERSION | sed -e "s#$RE#\1#"`
MINOR=`echo $CURRENT_VERSION | sed -e "s#$RE#\2#"`
PATCH=`echo $CURRENT_VERSION | sed -e "s#$RE#\3#"`
case "$1" in
  major)
    let MAJOR+=1
    ;;
  minor)
    let MINOR+=1
    ;;
  patch)
    let PATCH+=1
    ;;
esac
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION"
npx lerna version "$NEW_VERSION" --no-git-tag-version --no-push --force-publish --yes

echo "📡 Publishing ..."
npx lerna publish --registry $NPM_REGISTRY_URL --no-git-reset  --force-publish --yes

echo "🎊 New version is $NEW_VERSION"
echo "✅ DONE"
