#!/usr/bin/env bash

set -euo pipefail

main() {
    local release_tag="${1:-}"
    local dockerfile_path="${2:-Dockerfile}"
    local ubuntu_base_tag
    local ubuntu_point_release
    local expected_prefix
    local release_suffix

    require_release_tag "$release_tag"

    ubuntu_base_tag="$(read_ubuntu_base_tag "$dockerfile_path")"
    ubuntu_point_release="$(read_ubuntu_point_release "$dockerfile_path")"
    expected_prefix="ulgis${ubuntu_point_release}"

    ensure_expected_prefix "$release_tag" "$expected_prefix"

    release_suffix="${release_tag#${expected_prefix}-r}"
    ensure_year_revision_suffix "$release_suffix"

    printf 'Release tag "%s" matches Ubuntu point release %s and Docker base tag %s.\n' \
        "$release_tag" \
        "$ubuntu_point_release" \
        "$ubuntu_base_tag"
}

require_release_tag() {
    local release_tag="$1"

    if [[ -n "$release_tag" ]]; then
        return
    fi

    echo "Usage: bash scripts/validate-release-tag.sh <release-tag> [dockerfile-path]" >&2
    exit 1
}

read_ubuntu_base_tag() {
    local dockerfile_path="$1"
    local ubuntu_base_tag

    ubuntu_base_tag="$(sed -n 's/^ARG UBUNTU_BASE_TAG=\([^[:space:]]*\)$/\1/p' "$dockerfile_path" | head -n 1)"

    if [[ -n "$ubuntu_base_tag" ]]; then
        printf '%s' "$ubuntu_base_tag"
        return
    fi

    echo "Unable to read UBUNTU_BASE_TAG from ${dockerfile_path}." >&2
    exit 1
}

read_ubuntu_point_release() {
    local dockerfile_path="$1"
    local ubuntu_point_release

    ubuntu_point_release="$(sed -n 's/^ARG UBUNTU_LTS_POINT_RELEASE=\([0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]*\)$/\1/p' "$dockerfile_path" | head -n 1)"

    if [[ -n "$ubuntu_point_release" ]]; then
        printf '%s' "$ubuntu_point_release"
        return
    fi

    echo "Unable to read UBUNTU_LTS_POINT_RELEASE from ${dockerfile_path}." >&2
    exit 1
}

ensure_expected_prefix() {
    local release_tag="$1"
    local expected_prefix="$2"

    if [[ "$release_tag" == "$expected_prefix" ]]; then
        echo "Primary release tags must add a ULGIS release suffix, for example ${expected_prefix}-r2026.1." >&2
        exit 1
    fi

    if [[ "$release_tag" == "${expected_prefix}-r"* ]]; then
        return
    fi

    echo "Release tag must start with ${expected_prefix}-r." >&2
    exit 1
}

ensure_year_revision_suffix() {
    local release_suffix="$1"

    if [[ "$release_suffix" =~ ^[0-9]{4}\.[0-9]+$ ]]; then
        return
    fi

    echo "Release tag must end with a year and revision such as 2026.1 or 2026.2." >&2
    exit 1
}

main "$@"
