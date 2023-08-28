#!/usr/bin/env bash
set -euo pipefail

newRev=$1

pinFile=prebuilt-commit.json

if [[ -e "$pinFile" ]]; then
  oldRev=$(jq -r '.rev' "$pinFile")

  # If the difference between the old pin and the new pin is only the pinned file itself,
  # it means that a previous update of a pin itself caused the channel update.
  # We don't want to cause another channel update just because of the pin.
  if [[ "$(git diff "$oldRev" "$newRev" --name-only)" == "$pinFile" ]]; then
    exit 1
  fi
fi


narHash=$(nix-prefetch-url \
  "${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-NixOS/nixpkgs}/tarball/$newRev" \
  --type sha256 --unpack)

jq -n > "$pinFile" \
  --arg rev "$newRev" \
  --arg narHash "$narHash" \
  '$ARGS.named'
