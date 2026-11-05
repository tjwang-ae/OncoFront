#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
curl --fail --location --retry 3 'https://github.com/tjwang-ae/OncoFront/releases/download/V1.0/OncoFront_Linux.zip' -o "$work/OncoFront_Linux.zip"
(cd "$work" && echo '2b5e93ddc20e888cf5e29b42242ffa7f96e7481a5152316a6340f339b92a2828  OncoFront_Linux.zip' | sha256sum -c - && unzip -q OncoFront_Linux.zip -d kit)
bash "$work/kit/install.sh" "$@"
