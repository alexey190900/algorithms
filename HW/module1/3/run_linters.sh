#!/usr/bin/env bash

set -o pipefail

function print_header() {
    echo -e "\n***** ${1} *****"
}

function check_log() {
    LOG=$( { ${1}; } 2>&1 )
    STATUS=$?
    echo "$LOG"
    if echo "$LOG" | grep -q -E "${2}"
    then
        exit 1
    fi

    if [ $STATUS -ne 0 ]
    then
        exit $STATUS
    fi
}

print_header "RUN cppcheck"
check_log "cppcheck $@ --enable=all --inconclusive --error-exitcode=1 --suppress=missingIncludeSystem" "\(information\)"

print_header "RUN clang-tidy"
check_log "clang-tidy $@ -warnings-as-errors=* -extra-arg=-std=c99 --filter=-warnings-as-errors -- " "Error (?:reading|while processing)"

print_header "RUN cpplint"
check_log "cpplint $@ --extensions=c" "Can't open for reading"

print_header "SUCCESS"