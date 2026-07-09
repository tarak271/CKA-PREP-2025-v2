#!/bin/bash
# Re-export shared helpers from exercises/lib
_EXERCISES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../exercises/lib" && pwd)"
# shellcheck source=/dev/null
source "$_EXERCISES_LIB/common.sh"
