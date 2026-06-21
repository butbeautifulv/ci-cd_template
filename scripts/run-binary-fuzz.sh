#!/usr/bin/env bash
# Run OSS binary fuzz engines (AFL++, Go native fuzz, Jazzer) and emit JUnit.
set -euo pipefail

ROOT="${1:-.}"
REPORT="${2:-reports/binary-fuzz-junit.xml}"
FUZZ_TIME="${FUZZ_TIME:-30}"
FUZZ_TARGETS="${FUZZ_TARGETS:-auto}"

AFL_IMAGE="${OSS_AFLPP_IMAGE:-aflplusplus/aflplusplus:v4.40c}"
GO_IMAGE="${OSS_GOLANG_IMAGE:-golang:1.23.8-bookworm}"
MAVEN_IMAGE="${OSS_MAVEN_IMAGE:-maven:3.9.9-eclipse-temurin-17}"

RESULTS=()

add_result() {
  RESULTS+=("$1")
}

detect_targets() {
  local t=""
  [ -d "${ROOT}/fuzz/c" ] || [ -d "${ROOT}/examples/fuzzing/c" ] && t="${t}afl,"
  [ -d "${ROOT}/fuzz/go" ] || [ -d "${ROOT}/examples/fuzzing/go" ] && t="${t}go,"
  [ -f "${ROOT}/fuzz/java/pom.xml" ] || [ -f "${ROOT}/examples/fuzzing/java/pom.xml" ] && t="${t}jazzer,"
  echo "${t%,}"
}

should_run() {
  local engine="$1"
  if [ "${FUZZ_TARGETS}" = "auto" ]; then
    local detected
    detected="$(detect_targets)"
    [[ ",${detected}," == *",${engine},"* ]]
    return
  fi
  [[ ",${FUZZ_TARGETS}," == *",${engine},"* ]]
}

afl_dir() {
  if [ -d "${ROOT}/fuzz/c" ]; then echo "${ROOT}/fuzz/c"; else echo "${ROOT}/examples/fuzzing/c"; fi
}

go_dir() {
  if [ -d "${ROOT}/fuzz/go" ]; then echo "${ROOT}/fuzz/go"; else echo "${ROOT}/examples/fuzzing/go"; fi
}

java_dir() {
  if [ -f "${ROOT}/fuzz/java/pom.xml" ]; then echo "${ROOT}/fuzz/java"; else echo "${ROOT}/examples/fuzzing/java"; fi
}

run_afl() {
  local dir rel crash_count
  dir="$(afl_dir)"
  rel="${dir#${ROOT}/}"
  echo "==> AFL++ in ${dir}"
  if ! docker run --rm \
    -v "${ROOT}:/repo" \
    -w "/repo/${rel}" \
    -e "FUZZ_TIME=${FUZZ_TIME}" \
    --entrypoint bash \
    "${AFL_IMAGE}" \
    -lc '
      set -e
      export AFL_SKIP_CPUFREQ=1 AFL_NO_UI=1
      make clean >/dev/null 2>&1 || true
      make CC=afl-clang-fast
      rm -rf out && mkdir -p out
      timeout "$((FUZZ_TIME + 15))" afl-fuzz -V "${FUZZ_TIME}" -i seeds -o out -- ./harness || true
    '; then
    add_result "afl:error:docker run failed"
    return
  fi
  crash_count="$(find "${dir}/out" -type f -path '*/crashes/id:*' 2>/dev/null | wc -l | tr -d ' ')"
  if [ "${crash_count}" -gt 0 ]; then
    add_result "afl:fail:${crash_count} crash(es) in AFL++ output"
  else
    add_result "afl:pass"
  fi
}

run_go() {
  local dir rel
  dir="$(go_dir)"
  rel="${dir#${ROOT}/}"
  echo "==> Go fuzz in ${dir}"
  if ! docker run --rm \
    -v "${ROOT}:/repo" \
    -w "/repo/${rel}" \
    -e "CGO_ENABLED=0" \
    "${GO_IMAGE}" \
    go test . -fuzz=FuzzParse -fuzztime="${FUZZ_TIME}s" -count=1; then
    add_result "go:fail:go test -fuzz failed"
  else
    add_result "go:pass"
  fi
}

run_jazzer() {
  local dir rel
  dir="$(java_dir)"
  rel="${dir#${ROOT}/}"
  echo "==> Jazzer in ${dir}"
  if ! docker run --rm \
    -v "${ROOT}:/repo" \
    -w "/repo/${rel}" \
    "${MAVEN_IMAGE}" \
    mvn -q -DskipTests compile test-compile jazzer:fuzz \
      -Djazzer.target=FuzzTest -Djazzer.duration="${FUZZ_TIME}"; then
    add_result "jazzer:fail:Jazzer fuzz failed"
  else
    add_result "jazzer:pass"
  fi
}

mkdir -p "$(dirname "${REPORT}")"

if should_run afl; then run_afl; fi
if should_run go; then run_go; fi
if should_run jazzer; then run_jazzer; fi

if [ "${#RESULTS[@]}" -eq 0 ]; then
  echo "No binary fuzz targets found (fuzz/* or examples/fuzzing/*)"
  python3 "${ROOT}/scripts/binary-fuzz-to-junit.py" -o "${REPORT}" --result "binary-fuzz:error:no targets configured"
  exit 1
fi

ARGS=()
for r in "${RESULTS[@]}"; do
  ARGS+=(--result "${r}")
done

python3 "${ROOT}/scripts/binary-fuzz-to-junit.py" -o "${REPORT}" "${ARGS[@]}"
echo "Wrote ${REPORT}: ${RESULTS[*]}"
exit $?
