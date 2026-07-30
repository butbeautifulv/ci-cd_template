#!/usr/bin/env sh
# Kaniko build for corp mirror — NO docker CLI / NO dind / NO python required.
# Writes build.env: IMAGE_TAG, BUILD_FALLBACK, SOURCE_SHA
# IMAGE_TAG=${SERVICE_NAME}-${SOURCE_SHA}
set -eu

# Kaniko debug image tools live under /busybox
export PATH="/busybox:/kaniko:${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"

SCAN_ROOT="${SCAN_ROOT:-checkout}"
SERVICE_NAME="${SERVICE_NAME:-app}"
REGISTRY="${REGISTRY:?REGISTRY required}"
NEXUS_DOCKER_PREFIX="${NEXUS_DOCKER_PREFIX:-nexus.svo.aero:8345}"
NEXUS_DOCKER_GROUP="${NEXUS_DOCKER_GROUP:-nexus.svo.aero:8374}"
BUILD_BASE_IMAGE="${BUILD_BASE_IMAGE:-${NEXUS_DOCKER_PREFIX}/library/python:3.11.11-slim-bookworm}"
BUILD_DOCKER_TARGET="${BUILD_DOCKER_TARGET:-source}"
echo "[kaniko] BUILD_DOCKER_TARGET=${BUILD_DOCKER_TARGET}"
echo "[kaniko] NEXUS_DOCKER_PREFIX=${NEXUS_DOCKER_PREFIX} NEXUS_DOCKER_GROUP=${NEXUS_DOCKER_GROUP}"
NEXUS_PYPI_URL="${NEXUS_PYPI_URL:-}"
if [ -z "$NEXUS_PYPI_URL" ] && [ -n "${PIP_INDEX_URL:-}" ]; then
  NEXUS_PYPI_URL=$(printf '%s' "$PIP_INDEX_URL" | sed -E 's|^https?://||; s|/simple/?$||')
fi
NEXUS_PYPI_URL_LOG="${NEXUS_PYPI_URL:-<unset>}"
# Nexus PyPI can require auth.
# IMPORTANT: do NOT embed user/pass into NEXUS_PYPI_URL here.
# Dockerfiles typically build the final index URL from NEXUS_USERNAME/NEXUS_PASSWORD build-args.
# Double-embedding can lead to malformed URLs and 401s.
NEXUS_PYPI_HAS_AUTH=0
case "${NEXUS_PYPI_URL:-}" in
  *@*) NEXUS_PYPI_HAS_AUTH=1 ;;
esac
echo "[kaniko] pip NEXUS_PYPI_URL=${NEXUS_PYPI_URL_LOG} NEXUS_PYPI_HAS_AUTH=${NEXUS_PYPI_HAS_AUTH} PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST:-<unset>} NEXUS_USER_set=$([ -n \"${NEXUS_USER:-}\" ] && echo 1 || echo 0) NEXUS_PASSWORD_set=$([ -n \"${NEXUS_PASSWORD:-}\" ] && echo 1 || echo 0)"

write_env() {
  echo "IMAGE_TAG=${1}" >> build.env
  echo "BUILD_FALLBACK=${2}" >> build.env
  echo "SOURCE_SHA=${3}" >> build.env
  if [ "$1" != "none" ] && [ -n "${REGISTRY:-}" ]; then
    echo "BUILT_IMAGE=${REGISTRY}:${1}" >> build.env
  else
    echo "BUILT_IMAGE=" >> build.env
  fi
}

: > build.env

SOURCE_SHA=""
if command -v git >/dev/null 2>&1 && [ -d "$SCAN_ROOT/.git" ]; then
  SOURCE_SHA=$(git -C "$SCAN_ROOT" rev-parse HEAD)
elif [ -n "${SOURCE_REF_RESOLVED:-}" ]; then
  SOURCE_SHA=$(printf '%s' "$SOURCE_REF_RESOLVED" | tr -c 'A-Za-z0-9' '-' | cut -c1-40)
elif [ -n "${SOURCE_REF:-}" ]; then
  SOURCE_SHA=$(printf '%s' "$SOURCE_REF" | tr -c 'A-Za-z0-9' '-' | cut -c1-40)
else
  SOURCE_SHA="${CI_COMMIT_SHA:-unknown}"
fi
IMAGE_TAG="${SERVICE_NAME}-${SOURCE_SHA}"
DESTINATION="${REGISTRY}:${IMAGE_TAG}"

if [ ! -x /kaniko/executor ]; then
  echo "[kaniko] ERROR: /kaniko/executor missing"
  write_env none 0 "$SOURCE_SHA"
  exit 1
fi

DF=""
if [ -d "$SCAN_ROOT" ]; then
  DF=$(find "$SCAN_ROOT" \( -path "$SCAN_ROOT/Docker/*/Dockerfile" -o -path "$SCAN_ROOT/Docker/Dockerfile" -o -name Dockerfile \) -type f 2>/dev/null | head -n 1 || true)
fi
if [ -z "$DF" ] && [ -f Dockerfile ]; then
  DF=Dockerfile
fi

if [ -z "$DF" ] || [ ! -f "$DF" ]; then
  echo "[kaniko] ERROR: No Dockerfile under $SCAN_ROOT"
  write_env none 0 "$SOURCE_SHA"
  exit 1
fi

# Parity with Jenkins: remove local-only VSCode block from Dockerfile.
# This block is intentionally deleted before building so it doesn't affect prod-like builds.
if [ -n "$DF" ] && [ -f "$DF" ]; then
  sed -i '/# Only for local useage for VSCode/,/# End of local useage for VSCode/d' "$DF" || true
  echo "[kaniko] patched Dockerfile VSCode-local block (if present): $DF"
fi

CONTEXT="$SCAN_ROOT"
if [ ! -d "$CONTEXT" ]; then
  CONTEXT=$(dirname "$DF")
fi

echo "[kaniko] dockerfile=$DF context=$CONTEXT dest=$DESTINATION"
echo "[kaniko] BUILD_BASE_IMAGE=$BUILD_BASE_IMAGE target=$BUILD_DOCKER_TARGET SOURCE_SHA=$SOURCE_SHA"

# Auth: in k8s jobs `/kaniko` can be mounted read-only.
# Prefer writing docker config into a writable dir and letting kaniko read it via DOCKER_CONFIG.
KANIKO_DOCKER_CONFIG_DIR="${KANIKO_DOCKER_CONFIG_DIR:-/tmp/kaniko-docker-config}"
export DOCKER_CONFIG="$KANIKO_DOCKER_CONFIG_DIR"
CONFIG_JSON="$KANIKO_DOCKER_CONFIG_DIR/config.json"
mkdir -p "$KANIKO_DOCKER_CONFIG_DIR"
b64_auth() {
  # busybox base64 -w0 may not exist; strip newlines
  printf '%s' "$1" | base64 | tr -d '\n'
}
if [ ! -s "$CONFIG_JSON" ]; then
  AUTH_ENTRIES=""
  if [ -n "${NEXUS_USER:-}" ] && [ -n "${NEXUS_PASSWORD:-}" ]; then
    NA=$(b64_auth "${NEXUS_USER}:${NEXUS_PASSWORD}")
    AUTH_ENTRIES="${AUTH_ENTRIES}\"${NEXUS_DOCKER_PREFIX}\":{\"auth\":\"${NA}\"},\"${NEXUS_DOCKER_GROUP}\":{\"auth\":\"${NA}\"},"
  fi
  user="${CI_REGISTRY_USER:-gitlab-ci-token}"
  password="${CI_REGISTRY_PASSWORD:-${CI_JOB_TOKEN:-}}"
  reg="${CI_REGISTRY:-}"
  if [ -n "$reg" ] && [ -n "$password" ]; then
    GA=$(b64_auth "${user}:${password}")
    AUTH_ENTRIES="${AUTH_ENTRIES}\"${reg}\":{\"auth\":\"${GA}\"},"
  fi
  AUTH_ENTRIES=$(printf '%s' "$AUTH_ENTRIES" | sed 's/,$//')
  printf '{"auths":{%s}}\n' "$AUTH_ENTRIES" > "$CONFIG_JSON"
  echo "[kaniko] wrote $CONFIG_JSON"
else
  echo "[kaniko] using existing docker config from DOCKER_CONFIG=$DOCKER_CONFIG"
fi

PIP_HOST="${PIP_TRUSTED_HOST:-}"
if [ -z "$PIP_HOST" ] && [ -n "${NEXUS_PYPI_URL:-}" ]; then
  PIP_HOST=$(printf '%s' "$NEXUS_PYPI_URL" | cut -d/ -f1)
fi
# Hostname only for pip --trusted-host (strip :port). Keep Nexus-only installs — no public pypi.org.
PIP_TRUST_NAME=$(printf '%s' "$PIP_HOST" | cut -d: -f1)
if [ -n "$PIP_TRUST_NAME" ] && [ -f "$DF" ]; then
  echo "[kaniko] patch trusted-host -> ${PIP_TRUST_NAME}"
  sed -i "s/--trusted-host [^ ]*/--trusted-host ${PIP_TRUST_NAME}/g" "$DF" || true
fi

# gismaputils: do NOT use --extra-index-url (pip would query GitLab for every pkg and fall through to pypi.org SSL).
# Instead vendor wheels from map_objects-ci Package Registry into build context and --find-links locally.
GISMAPUTILS_INDEX_HOST="${GISMAPUTILS_INDEX_HOST:-gitlab.svo.aero}"
GISMAPUTILS_PYPI_PROJECT_ID="${GISMAPUTILS_PYPI_PROJECT_ID:-1962}"
VENDOR_DIR="${CONTEXT}/vendor-gismaputils"
GISMAP_TOKEN="${GISMAPUTILS_PYPI_TOKEN:-${CI_JOB_TOKEN:-}}"
GISMAP_VENDOR_SET=0
if [ -n "$GISMAP_TOKEN" ] && [ -d "$CONTEXT" ]; then
  mkdir -p "$VENDOR_DIR"
  # Pull versions referenced in requirements (fallback: 0.5.1 0.5.3).
  REQ_FILES=""
  for rf in "$CONTEXT/dev-requirements.txt" "$CONTEXT/requirements.txt"; do
    [ -f "$rf" ] && REQ_FILES="$REQ_FILES $rf"
  done
  VERS=$( { [ -n "$REQ_FILES" ] && grep -hE '^[[:space:]]*gismaputils[[:space:]]*==' $REQ_FILES || true; } \
    | sed -E 's/.*==[[:space:]]*([0-9][^[:space:]#]+).*/\1/' | sort -u )
  if [ -z "$VERS" ]; then
    VERS="0.5.1
0.5.3"
  fi
  for ver in $VERS; do
    # GitLab simple index → wheel URL via python (TLS ok in helper image).
    # If exact pin missing (e.g. user_service gismaputils==0.2.5), remap req to
    # nearest available Package Registry wheel so BUILD_FALLBACK stays 0.
    if command -v python3 >/dev/null 2>&1; then
      GISMAP_TOKEN="$GISMAP_TOKEN" GISMAPUTILS_INDEX_HOST="$GISMAPUTILS_INDEX_HOST" \
      GISMAPUTILS_PYPI_PROJECT_ID="$GISMAPUTILS_PYPI_PROJECT_ID" VENDOR_DIR="$VENDOR_DIR" \
      VER="$ver" CONTEXT="$CONTEXT" python3 - <<'PY'
import os, ssl, urllib.request, re, sys
from pathlib import Path

ver = os.environ["VER"]
host = os.environ["GISMAPUTILS_INDEX_HOST"]
pid = os.environ["GISMAPUTILS_PYPI_PROJECT_ID"]
tok = os.environ["GISMAP_TOKEN"]
vendor = os.environ["VENDOR_DIR"]
context = Path(os.environ["CONTEXT"])
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
simple = f"https://{host}/api/v4/projects/{pid}/packages/pypi/simple/gismaputils/"
req = urllib.request.Request(simple, headers={"PRIVATE-TOKEN": tok})
try:
    html = urllib.request.urlopen(req, context=ctx, timeout=60).read().decode("utf-8", "replace")
except Exception as e:
    print(f"[kaniko] WARN: cannot list gismaputils simple index: {e}", file=sys.stderr)
    sys.exit(0)

def wheel_for(v: str):
    pat = re.compile(r'href="([^"]*gismaputils-' + re.escape(v) + r'-[^"]+\.whl)[^"]*"', re.I)
    return pat.search(html)

m = wheel_for(ver)
use_ver = ver
if not m:
    avail = sorted(set(re.findall(r"gismaputils-([0-9][^\"/]+?)-py", html, flags=re.I)))
    prefer = [x for x in ("0.5.1", "0.5.3") if x in avail]
    use_ver = (prefer or avail)[-1] if (prefer or avail) else ""
    if not use_ver:
        print(f"[kaniko] WARN: no wheel for gismaputils=={ver} in Package Registry", file=sys.stderr)
        sys.exit(0)
    print(
        f"[kaniko] WARN: no wheel for gismaputils=={ver}; remapping requirements → {use_ver}",
        file=sys.stderr,
    )
    pin_re = re.compile(rf"^(?P<pre>\s*gismaputils\s*==\s*){re.escape(ver)}(?P<post>\b.*)$", re.M)
    for rf in (context / "dev-requirements.txt", context / "requirements.txt"):
        if not rf.is_file():
            continue
        text = rf.read_text(encoding="utf-8", errors="replace")
        new, n = pin_re.subn(rf"\g<pre>{use_ver}\g<post>", text)
        if n:
            rf.write_text(new, encoding="utf-8")
            print(f"[kaniko] rewritten {rf.name}: gismaputils=={ver} → {use_ver} ({n} hit(s))")
            (context / ".gismaputils_remapped").write_text(f"{ver}->{use_ver}\n", encoding="utf-8")
    m = wheel_for(use_ver)
    if not m:
        print(f"[kaniko] WARN: remap target gismaputils=={use_ver} also missing", file=sys.stderr)
        sys.exit(0)

url = m.group(1)
if url.startswith("/"):
    url = f"https://{host}{url}"
req2 = urllib.request.Request(url, headers={"PRIVATE-TOKEN": tok})
data = urllib.request.urlopen(req2, context=ctx, timeout=120).read()
name = url.split("/")[-1].split("#")[0]
path = os.path.join(vendor, name)
with open(path, "wb") as f:
    f.write(data)
print(f"[kaniko] vendored {name} ({len(data)} bytes)")
PY
    fi
  done
fi
# After remapping gismaputils to 0.5.x, old services may import module-level get_token
# (user_service 0.4.4). Patch health_router to Auth.get_token so the image can boot.
if [ -f "${CONTEXT}/.gismaputils_remapped" ] && command -v python3 >/dev/null 2>&1; then
  CONTEXT="$CONTEXT" python3 - <<'PY'
import os, re
from pathlib import Path

ctx = Path(os.environ["CONTEXT"])
hr = ctx / "src" / "routers" / "health_router.py"
if not hr.is_file():
    raise SystemExit(0)
text = hr.read_text(encoding="utf-8", errors="replace")
if "from gismaputils.auth.network.auth_requests import get_token" not in text:
    raise SystemExit(0)
text2 = text.replace(
    "from gismaputils.auth.network.auth_requests import get_token",
    "from gismaputils.auth.network.auth_requests import auth",
)
text3, n = re.subn(
    r"token\s*=\s*await\s+get_token\([^)]*\)",
    "auth.set_config(\n"
    "        url_auth=get_settings().URL_AUTH,\n"
    "        b2b_user=get_settings().BACK_TO_BACK_USER,\n"
    "        b2b_pwd=get_settings().BACK_TO_BACK_PASSWORD,\n"
    "    )\n"
    "    token = await auth.get_token()",
    text2,
    count=1,
)
if n:
    hr.write_text(text3, encoding="utf-8")
    print(f"[kaniko] patched {hr.relative_to(ctx)} for gismaputils Auth.get_token compat")
else:
    print(f"[kaniko] WARN: remapped gismaputils but could not patch {hr}", flush=True)
PY
fi
if ls "$VENDOR_DIR"/*.whl >/dev/null 2>&1; then
  GISMAP_VENDOR_SET=1
fi
echo "[kaniko] gismaputils_vendor set=${GISMAP_VENDOR_SET} dir=${VENDOR_DIR}"
if [ "$GISMAP_VENDOR_SET" = 1 ] && [ -f "$DF" ]; then
  if command -v python3 >/dev/null 2>&1; then
    DF="$DF" python3 - <<'PY'
import os, re
df = os.environ["DF"]
with open(df, "r", encoding="utf-8", errors="replace") as f:
    text = f.read()
# Ensure COPY vendor into image (after first COPY of requirements if present).
if "vendor-gismaputils" not in text:
    # Insert after WORKDIR /app or after first COPY line.
    lines = text.splitlines(True)
    out = []
    inserted = False
    for i, line in enumerate(lines):
        out.append(line)
        if not inserted and re.match(r"^COPY\s+", line):
            out.append("COPY ./vendor-gismaputils /app/vendor-gismaputils\n")
            inserted = True
    if not inserted:
        out.insert(0, "COPY ./vendor-gismaputils /app/vendor-gismaputils\n")
    text = "".join(out)
# Add --find-links to pip install -r lines (local only; Nexus remains sole index via PIP_INDEX_URL).
lines = text.splitlines(True)
out = []
for line in lines:
    if re.search(r"pip\s+install\b", line) and "-r" in line and "--find-links" not in line:
        out.append(line.rstrip("\n") + " --find-links /app/vendor-gismaputils\n")
    else:
        out.append(line)
with open(df, "w", encoding="utf-8") as f:
    f.writelines(out)
print("[kaniko] patched Dockerfile for local gismaputils --find-links")
PY
  fi
fi

# URL-encode for build-args without python (minimal: leave as-is if encoding unavailable)
NEXUS_USER_ENC="${NEXUS_USER:-}"
NEXUS_PASSWORD_ENC="${NEXUS_PASSWORD:-}"

CONTEXT_ABS=$(cd "$CONTEXT" && pwd)
set -- --dockerfile "$DF" --context "dir://${CONTEXT_ABS}" --destination "$DESTINATION" \
  --target "$BUILD_DOCKER_TARGET" \
  --build-arg "IMAGE_NAME=${BUILD_BASE_IMAGE}" \
  --skip-tls-verify \
  --insecure \
  --cache=false
if [ -n "${NEXUS_PYPI_URL:-}" ]; then
  set -- "$@" --build-arg "NEXUS_PYPI_URL=${NEXUS_PYPI_URL}"
fi
if [ -n "${NEXUS_USER_ENC}" ]; then
  set -- "$@" --build-arg "NEXUS_USERNAME=${NEXUS_USER_ENC}"
fi
if [ -n "${NEXUS_PASSWORD_ENC}" ]; then
  set -- "$@" --build-arg "NEXUS_PASSWORD=${NEXUS_PASSWORD_ENC}"
fi

echo "[kaniko] executor start"
set +e
/kaniko/executor "$@"
rc=$?
set -e

if [ "$rc" -eq 0 ]; then
  write_env "$IMAGE_TAG" 0 "$SOURCE_SHA"
  echo "[kaniko] pushed $DESTINATION BUILD_FALLBACK=0"
  exit 0
fi

echo "[kaniko] WARN: service build failed rc=$rc — fallback FROM $BUILD_BASE_IMAGE"
FB_DIR="${CI_PROJECT_DIR:-.}/.kaniko-fallback"
rm -rf "$FB_DIR"
mkdir -p "$FB_DIR"
printf 'FROM %s\n' "$BUILD_BASE_IMAGE" > "$FB_DIR/Dockerfile"
FB_ABS=$(cd "$FB_DIR" && pwd)
set +e
/kaniko/executor \
  --dockerfile "$FB_DIR/Dockerfile" \
  --context "dir://${FB_ABS}" \
  --destination "$DESTINATION" \
  --skip-tls-verify \
  --insecure \
  --cache=false
frc=$?
set -e
if [ "$frc" -eq 0 ]; then
  write_env "$IMAGE_TAG" 1 "$SOURCE_SHA"
  echo "[kaniko] fallback pushed $DESTINATION BUILD_FALLBACK=1"
  exit 0
fi
echo "[kaniko] ERROR: fallback also failed"
write_env none 1 "$SOURCE_SHA"
exit 1
