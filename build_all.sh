#!/usr/bin/env bash
#
# build_all.sh – Build all targets with ASan
#
set -u   

export CC=gcc
export CXX=g++
export CFLAGS="-g -O1 -fsanitize=address -fno-omit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fsanitize=address"
export LIBS=""

export MAGMA_ENABLE_FIXES=0



TARGETS_DIR="$(pwd)/targets"
LOG_DIR="$(pwd)/build_logs"
mkdir -p "$LOG_DIR"


$CC $CFLAGS -c "$(pwd)/driver/driver.c" -o "$(pwd)/out/driver.o"
export LIB_FUZZING_ENGINE="$(pwd)/out/driver.o" 

mapfile -t TARGETS < <(
  for d in "$TARGETS_DIR"/*/; do
    [ -f "${d}build.sh" ] && basename "$d"
  done
)

echo "Targets: ${TARGETS[*]}"
echo "---------------------------------------------"

declare -A RESULT

### === Build-loop ===
for t in "${TARGETS[@]}"; do
    echo ""
    echo "=== [$t] Build started ==="

    export TARGET="$TARGETS_DIR/$t"
    export OUT="$(pwd)/out/$t"
    mkdir -p "$OUT"

    LOG="$LOG_DIR/$t.log"

    {
        echo ">>> preinstall.sh"
        "$TARGET/preinstall.sh"

        echo ">>> build.sh"
        "$TARGET/build.sh"
    } &> "$LOG"

    if [ $? -eq 0 ]; then
        RESULT["$t"]="OK"
        echo "=== [$t] SUCCESSFUL (Log: $LOG) ==="
    else
        RESULT["$t"]="ERROR"
        echo "=== [$t] FAILED – see $LOG ==="
    fi
done

echo ""
echo "============ SUMMARY ============"
printf "%-15s %s\n" "TARGET" "STATUS"
printf "%-15s %s\n" "------" "------"
for t in "${TARGETS[@]}"; do
    printf "%-15s %s\n" "$t" "${RESULT[$t]}"
done
