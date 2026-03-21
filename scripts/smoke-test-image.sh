#!/usr/bin/env bash

set -euo pipefail

main() {
    local image_ref="${1:-}"

    require_image_ref "$image_ref"
    run_smoke_checks "$image_ref"
}

require_image_ref() {
    local image_ref="$1"

    if [[ -n "$image_ref" ]]; then
        return
    fi

    echo "Usage: bash scripts/smoke-test-image.sh <image-ref>" >&2
    exit 1
}

run_smoke_checks() {
    local image_ref="$1"

    docker run --rm "$image_ref" bash -lc '
python3 --version
pip3 --version
poetry --version
gdalinfo --version
projinfo EPSG:4326 --summary
geos-config --version
'
}

main "$@"
