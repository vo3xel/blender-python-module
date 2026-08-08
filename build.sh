#!/usr/bin/env bash
#
# Build Blender-as-Python-module Docker images.
#
# Usage:
#   ./build.sh list                 # show all buildable versions
#   ./build.sh <version>            # build one release, e.g. ./build.sh 4.5.12
#   ./build.sh nightly              # build current main branch (version auto-detected)
#   ./build.sh all                  # build every release + nightly
#
# Options:
#   --push       push images to the registry after a successful test
#   --no-test    skip the smoke test
#
# Environment:
#   IMAGE_REPO   image repository (default: ghcr.io/vo3xel/blender-python-module)

set -euo pipefail
cd "$(dirname "$0")"

IMAGE_REPO="${IMAGE_REPO:-ghcr.io/vo3xel/blender-python-module}"
VERSIONS_FILE="versions.json"
# GitHub mirror — projects.blender.org throttles CI traffic
BLENDER_GIT_RAW="https://raw.githubusercontent.com/blender/blender/main"

PUSH=0
RUN_TEST=1
TARGETS=()

for arg in "$@"; do
    case "$arg" in
        --push)    PUSH=1 ;;
        --no-test) RUN_TEST=0 ;;
        -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         TARGETS+=("$arg") ;;
    esac
done

[ ${#TARGETS[@]} -gt 0 ] || { echo "error: no target given (try './build.sh list')" >&2; exit 1; }

list_versions() {
    python3 -c "
import json
for e in json.load(open('$VERSIONS_FILE'))['versions']:
    print(e['version'], e['python'], e.get('gcc', '13'))"
}

python_for_version() {
    list_versions | awk -v v="$1" '$1 == v { print $2 }'
}

gcc_for_version() {
    list_versions | awk -v v="$1" '$1 == v { print $3 }'
}

latest_version() {
    list_versions | awk 'END { print $1 }'
}

# Detect the nightly version string (e.g. 5.3.0-alpha), bundled Python
# version and required GCC directly from Blender's main branch.
detect_nightly() {
    local header versions_cmake cmakelists version patch cycle
    header=$(curl -fsSL "$BLENDER_GIT_RAW/source/blender/blenkernel/BKE_blender_version.h")
    versions_cmake=$(curl -fsSL "$BLENDER_GIT_RAW/build_files/build_environment/cmake/versions.cmake")
    cmakelists=$(curl -fsSL "$BLENDER_GIT_RAW/CMakeLists.txt")

    version=$(echo "$header" | awk '/#define BLENDER_VERSION /       { print $3 }')
    patch=$(echo "$header"   | awk '/#define BLENDER_VERSION_PATCH / { print $3 }')
    cycle=$(echo "$header"   | awk '/#define BLENDER_VERSION_CYCLE / { print $3 }')

    NIGHTLY_VERSION_STRING="$((version / 100)).$((version % 100)).${patch}-${cycle}"
    NIGHTLY_PYTHON=$(echo "$versions_cmake" | sed -n 's/^set(PYTHON_SHORT_VERSION \(.*\))$/\1/p')
    NIGHTLY_GCC=$(echo "$cmakelists" \
        | sed -n 's/.*minimum supported version of GCC is \([0-9]*\).*/\1/p' | head -1)
    NIGHTLY_GCC="${NIGHTLY_GCC:-14}"

    [ -n "$NIGHTLY_PYTHON" ] || { echo "error: could not detect nightly Python version" >&2; exit 1; }
}

smoke_test() {
    local image="$1"
    local test_file="./data/my.blend"

    rm -f "$test_file"
    # Run with the host uid so the container can write into the mounted dir
    # regardless of which uid the host user has.
    docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
        -v "$PWD/data":/home/blender/data "$image" test.py

    if [ -f "$test_file" ]; then
        echo "*** Smoke test OK: $image"
        rm -f "$test_file"
    else
        echo "*** Smoke test FAILED: $image" >&2
        exit 1
    fi
}

# build_image <git-ref> <python-version> <gcc-version> <version-string> <tag>...
build_image() {
    local git_ref="$1" python_version="$2" gcc_version="$3" version_string="$4"
    shift 4
    local tags=("$@")

    local tag_args=()
    for t in "${tags[@]}"; do
        tag_args+=(-t "$IMAGE_REPO:$t")
    done

    echo "==> Building Blender $version_string (ref: $git_ref, Python $python_version, GCC $gcc_version)"
    docker build \
        --build-arg BLENDER_GIT_REF="$git_ref" \
        --build-arg PYTHON_VERSION="$python_version" \
        --build-arg GCC_VERSION="$gcc_version" \
        --build-arg BLENDER_VERSION="$version_string" \
        "${tag_args[@]}" \
        .

    [ "$RUN_TEST" -eq 1 ] && smoke_test "$IMAGE_REPO:${tags[0]}"

    if [ "$PUSH" -eq 1 ]; then
        for t in "${tags[@]}"; do
            docker push "$IMAGE_REPO:$t"
        done
    fi
}

build_release() {
    local version="$1"
    local python_version gcc_version
    python_version=$(python_for_version "$version")
    gcc_version=$(gcc_for_version "$version")
    [ -n "$python_version" ] || {
        echo "error: unknown version '$version' (see './build.sh list')" >&2; exit 1;
    }

    local tags=("$version" "${version%.*}")
    [ "$version" = "$(latest_version)" ] && tags+=("latest")

    build_image "v$version" "$python_version" "$gcc_version" "$version" "${tags[@]}"
}

build_nightly() {
    detect_nightly
    echo "==> Nightly is Blender $NIGHTLY_VERSION_STRING (Python $NIGHTLY_PYTHON, GCC $NIGHTLY_GCC)"
    build_image "main" "$NIGHTLY_PYTHON" "$NIGHTLY_GCC" "$NIGHTLY_VERSION_STRING" \
        "nightly" "nightly-$NIGHTLY_VERSION_STRING"
}

for target in "${TARGETS[@]}"; do
    case "$target" in
        list)
            list_versions | awk '{ printf "%-10s (Python %s, GCC %s)\n", $1, $2, $3 }'
            echo "nightly    (auto-detected from main)"
            ;;
        all)
            while read -r version _; do
                build_release "$version"
            done < <(list_versions)
            build_nightly
            ;;
        nightly)
            build_nightly
            ;;
        *)
            build_release "$target"
            ;;
    esac
done
