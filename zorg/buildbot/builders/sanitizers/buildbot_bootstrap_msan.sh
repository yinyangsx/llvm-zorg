#!/usr/bin/env bash

set -x
set -e
set -u

HERE="$(cd $(dirname $0) && pwd)"
. ${HERE}/buildbot_functions.sh

ROOT=`pwd`
PLATFORM=`uname`
export PATH="/usr/local/bin:$PATH"

LLVM=$ROOT/llvm
CMAKE_COMMON_OPTIONS="-GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF"

clobber

buildbot_update

# Stage 1

build_stage1_clang

# Stage 2 / Memory Sanitizer

build_stage2_msan

check_stage2_msan

# Stage 3 / MemorySanitizer

build_stage3_msan

check_stage3_msan

if [[ -v msan_FAILED ]]; then
  # Stage 2 / MemoryWithOriginsSanitizer
  build_stage2_msan_track_origins

  check_stage2_msan_track_origins

  # Stage 3 / MemoryWithOriginsSanitizer
  build_stage3_msan_track_origins

  check_stage3_msan_track_origins
fi

cleanup $STAGE1_DIR
