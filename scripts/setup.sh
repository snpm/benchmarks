#!/bin/bash

# Exit on error
set -e

# Resolve repository paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Environment Configuration
COREPACK_ENABLE_STRICT=0
COREPACK_ENABLE_AUTO_PIN=0
YARN_ENABLE_IMMUTABLE_INSTALLS=false

# Check Node version (support 24.x and 25.x to match current runners)
SUPPORTED_NODE_VERSIONS=("24" "25")
CURRENT_NODE_VERSION=$(node -v | cut -d'v' -f2)

NODE_SUPPORTED=false
for VERSION_PREFIX in "${SUPPORTED_NODE_VERSIONS[@]}"; do
    if [[ "$CURRENT_NODE_VERSION" == "$VERSION_PREFIX"* ]]; then
        NODE_SUPPORTED=true
        break
    fi
done

if [[ "$NODE_SUPPORTED" == "false" ]]; then
    echo "Error: Node.js ${SUPPORTED_NODE_VERSIONS[*]} is required, but version $CURRENT_NODE_VERSION is installed"
    exit 1
fi

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y jq

# Install Hyperfine
wget https://github.com/sharkdp/hyperfine/releases/download/v1.19.0/hyperfine_1.19.0_amd64.deb
sudo dpkg -i hyperfine_1.19.0_amd64.deb

echo "Required system dependencies installed successfully!"
JQ_VERSION=$(jq --version)
HYPERFINE_VERSION=$(hyperfine --version)
echo "jq: $JQ_VERSION"
echo "hyperfine: $HYPERFINE_VERSION"

# Install Node.js package managers and tools
echo "Installing package managers and tools..."
npm install -g npm@latest corepack@latest vlt@latest bun@latest deno@latest nx@latest turbo@latest
echo "Installing snpm globally via npm..."
npm install -g snpm@latest

# Configure Package Managers
echo "Configuring package managers..."
corepack enable yarn pnpm

# Make npm silent
npm config set loglevel silent

# Create Results Directory
mkdir -p ./results/

# Log Package Manager Versions
echo "Logging package manager versions..."
NPM_VERSION="$(npm -v)"
VLT_VERSION="$(vlt -v)"
YARN_VERSION="$(corepack yarn@1 -v)"
BERRY_VERSION="$(corepack yarn@latest -v)"
PNPM_VERSION="$(corepack pnpm@latest -v)"
BUN_VERSION="$(bun -v)"
DENO_VERSION="$(npm view deno@latest version)"
NX_VERSION="$(npm view nx@latest version)"
TURBO_VERSION="$(npm view turbo@latest version)"
NODE_VERSION=$(node -v)
SNPM_VERSION="$(snpm --version)"

# Output versions
echo "npm: $NPM_VERSION"
echo "vlt: $VLT_VERSION"
echo "yarn: $YARN_VERSION"
echo "berry: $BERRY_VERSION"
echo "pnpm: $PNPM_VERSION"
echo "bun: $BUN_VERSION"
echo "deno: $DENO_VERSION"
echo "nx: $NX_VERSION"
echo "turbo: $TURBO_VERSION"
echo "node: $NODE_VERSION"
echo "snpm: $SNPM_VERSION"

# Save versions to JSON file
echo "{
  \"npm\": \"$NPM_VERSION\",
  \"vlt\": \"$VLT_VERSION\",
  \"yarn\": \"$YARN_VERSION\",
  \"berry\": \"$BERRY_VERSION\",
  \"pnpm\": \"$PNPM_VERSION\",
  \"bun\": \"$BUN_VERSION\",
  \"deno\": \"$DENO_VERSION\",
  \"nx\": \"$NX_VERSION\",
  \"turbo\": \"$TURBO_VERSION\",
  \"node\": \"$NODE_VERSION\",
  \"snpm\": \"$SNPM_VERSION\"
}" > ./results/versions.json

echo "Setup completed successfully!"
