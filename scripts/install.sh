#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

TARGET="claude"
SKILL="all"
SCOPE="project"
DEST=""
DRY_RUN=0
LIST_ONLY=0

usage() {
  cat <<'EOF'
Mobile Agent Skills Installer

Usage:
  bash scripts/install.sh [options]

Options:
  --target <name>   claude | cursor | codex | antigravity | gemini | all (default: claude)
  --skill <name>    Specific skill folder name, or 'all' (default: all)
  --scope <scope>   project | global (default: project)
  --dest <path>     Override project root directory (default: current directory)
  --list            List available skills and exit
  --dry-run         Print planned actions without writing files
  -h, --help        Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --skill) SKILL="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --dest) DEST="${2:-}"; shift 2 ;;
    --list) LIST_ONLY=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: skills directory not found at $SKILLS_DIR" >&2
  exit 1
fi

AVAILABLE_SKILLS=()
while IFS= read -r d; do
  AVAILABLE_SKILLS+=("$(basename "$d")")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$LIST_ONLY" -eq 1 ]]; then
  echo "Available Mobile Agent Skills (${#AVAILABLE_SKILLS[@]}):"
  for s in "${AVAILABLE_SKILLS[@]}"; do
    echo "  - $s"
  done
  exit 0
fi

SELECTED_SKILLS=()
if [[ "$SKILL" == "all" ]]; then
  SELECTED_SKILLS=("${AVAILABLE_SKILLS[@]}")
else
  if [[ ! -f "${SKILLS_DIR}/${SKILL}/SKILL.md" ]]; then
    echo "Error: skill '${SKILL}' not found in ${SKILLS_DIR}" >&2
    exit 1
  fi
  SELECTED_SKILLS=("$SKILL")
fi

if [[ -n "$DEST" ]]; then
  PROJECT_BASE="$DEST"
else
  PROJECT_BASE="$(pwd)"
fi

resolve_target_dir() {
  local t="$1"
  if [[ "$SCOPE" == "global" ]]; then
    case "$t" in
      claude) echo "${HOME}/.claude/skills" ;;
      cursor) echo "${HOME}/.cursor/rules" ;;
      codex) echo "${HOME}/.agents/skills" ;;
      antigravity) echo "${HOME}/.gemini/antigravity/skills" ;;
      gemini) echo "${HOME}/.gemini/skills" ;;
      *) echo "Unsupported target: $t" >&2; exit 1 ;;
    esac
  elif [[ "$SCOPE" == "project" ]]; then
    case "$t" in
      claude) echo "${PROJECT_BASE}/.claude/skills" ;;
      cursor) echo "${PROJECT_BASE}/.cursor/rules" ;;
      codex) echo "${PROJECT_BASE}/.agents/skills" ;;
      antigravity) echo "${PROJECT_BASE}/.agent/skills" ;;
      gemini) echo "${PROJECT_BASE}/.gemini/skills" ;;
      *) echo "Unsupported target: $t" >&2; exit 1 ;;
    esac
  else
    echo "Error: --scope must be 'project' or 'global'" >&2
    exit 1
  fi
}

TARGETS=()
case "$TARGET" in
  all) TARGETS=(claude cursor codex antigravity gemini) ;;
  claude|cursor|codex|antigravity|gemini) TARGETS=("$TARGET") ;;
  *) echo "Error: unsupported --target '${TARGET}'" >&2; exit 1 ;;
esac

install_skill_for_target() {
  local t="$1"
  local s="$2"
  local src="${SKILLS_DIR}/${s}/SKILL.md"
  local out_dir
  out_dir="$(resolve_target_dir "$t")"

  if [[ "$t" == "cursor" ]]; then
    local dest_file="${out_dir}/${s}.mdc"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] write Cursor rule -> ${dest_file}"
      return 0
    fi
    mkdir -p "$out_dir"
    # Extract description from YAML frontmatter for Cursor .mdc header
    local desc
    desc="$(awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); gsub(/^["'\'']|["'\'']$/, ""); print; exit}' "$src")"
    {
      echo "---"
      echo "description: ${desc}"
      echo "alwaysApply: false"
      echo "---"
      echo ""
      awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$src"
    } > "$dest_file"
  else
    local dest_dir="${out_dir}/${s}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] copy ${s}/SKILL.md -> ${dest_dir}/SKILL.md"
      return 0
    fi
    mkdir -p "$dest_dir"
    cp -R "${SKILLS_DIR}/${s}/." "$dest_dir/"
  fi
}

for t in "${TARGETS[@]}"; do
  for s in "${SELECTED_SKILLS[@]}"; do
    install_skill_for_target "$t" "$s"
  done
  echo "Installed ${#SELECTED_SKILLS[@]} skill(s) for target '${t}' ($(resolve_target_dir "$t"))"
done
