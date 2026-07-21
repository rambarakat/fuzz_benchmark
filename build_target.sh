#!/usr/bin/env bash
#
# build_target.sh — Build Magma targets (bare-metal, ASan, bugs enabled).
#
# Usage:
#   ./build_target.sh all                 # build all targets
#   ./build_target.sh libtiff             # build a single target
#   ./build_target.sh libtiff poppler     # build multiple targets
#   ./build_target.sh --list              # list available targets
#   ./build_target.sh clean               # clean all targets
#   ./build_target.sh clean libtiff       # clean specific target(s)
#
set -u

### === Paths & base configuration ===
ROOT="$(pwd)"
export OUT_BASE="$ROOT/out"
export LOG_DIR="$ROOT/build_logs"

### === Compiler / flags ===
export CC=gcc
export CXX=g++
export CFLAGS="-g -O1 -fsanitize=address -fno-omit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fsanitize=address"
export LIBS=""

# Keep bugs enabled (no fixes)
export MAGMA_ENABLE_FIXES=0

# Extra system libs some targets need at link time:
#   libtiff  -> (JBIG usually disabled; otherwise -ljbig)
#   poppler  -> FreeType built with Brotli/bzip2
export LIBS="${LIBS:-} -lbz2 -lbrotlidec -lbrotlicommon"

### === Discover all available targets automatically ===
mapfile -t ALL_TARGETS < <(
    find "$ROOT/targets" -maxdepth 2 -name build.sh -printf '%h\n' \
        | xargs -r -n1 basename | sort -u
)

usage() {
    cat <<EOF
Usage: $0 [all | <target> ...] | --list | clean [<target> ...]

  all              Build all available targets
  <target> ...     Build the specified targets
  --list           List available targets
  clean            Remove build artifacts (out/, work/, logs)
  clean <target>   Clean only the specified target(s)

Available targets:
  ${ALL_TARGETS[*]}
EOF
}

### === Argument parsing ===
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    printf '%s\n' "${ALL_TARGETS[@]}"
    exit 0
fi

### === Helper: validate a target name ===
is_valid_target() {
    local t="$1"
    for a in "${ALL_TARGETS[@]}"; do
        [ "$a" = "$t" ] && return 0
    done
    return 1
}

### === Clean mode ===
if [ "$1" = "clean" ]; then
    shift
    if [ "$#" -eq 0 ]; then
        # Clean everything
        CLEAN_TARGETS=("${ALL_TARGETS[@]}")
        echo ">>> Cleaning all targets"
    else
        CLEAN_TARGETS=("$@")
    fi

    for t in "${CLEAN_TARGETS[@]}"; do
        if ! is_valid_target "$t"; then
            echo "ERROR: unknown target '$t'." >&2
            echo "Available: ${ALL_TARGETS[*]}" >&2
            exit 1
        fi
    done

    for t in "${CLEAN_TARGETS[@]}"; do
        echo "    cleaning $t"
        rm -rf "$OUT_BASE/$t"
        rm -rf "$ROOT/targets/$t/work"
        rm -f  "$LOG_DIR/$t.log"
    done

    echo ">>> Clean done"
    exit 0
fi

### === Build mode: resolve target list ===
if [ "$1" = "all" ]; then
    TARGETS=("${ALL_TARGETS[@]}")
else
    TARGETS=("$@")
fi

### === Validate inputs ===
for t in "${TARGETS[@]}"; do
    if ! is_valid_target "$t"; then
        echo "ERROR: unknown target '$t'." >&2
        echo "Available: ${ALL_TARGETS[*]}" >&2
        exit 1
    fi
done

mkdir -p "$LOG_DIR"

$CC $CFLAGS -c "$(pwd)/driver/driver.c" -o "$(pwd)/out/driver.o"
export LIB_FUZZING_ENGINE="$(pwd)/out/driver.o" 

### === Build loop ===
declare -a OK_TARGETS FAIL_TARGETS

for t in "${TARGETS[@]}"; do
    echo ""
    echo "=============================================="
    echo ">>> Building target: $t"
    echo "=============================================="

    export TARGETS_DIR="$ROOT/targets"
    export TARGET="$TARGETS_DIR/$t"
    export OUT="$OUT_BASE/$t"
    mkdir -p "$OUT"

    LOG="$LOG_DIR/$t.log"

    if "$TARGET/build.sh" >"$LOG" 2>&1; then
        echo "    OK  -> artifacts in $OUT"
        OK_TARGETS+=("$t")
    else
        echo "    FAILED (see $LOG)"
        FAIL_TARGETS+=("$t")
    fi
done

### === Summary ===
echo ""
echo "=============================================="
echo ">>> Summary"
echo "=============================================="
echo "Succeeded (${#OK_TARGETS[@]}): ${OK_TARGETS[*]:-–}"
echo "Failed    (${#FAIL_TARGETS[@]}): ${FAIL_TARGETS[*]:-–}"

# Non-zero exit code if at least one target failed
[ "${#FAIL_TARGETS[@]}" -eq 0 ]