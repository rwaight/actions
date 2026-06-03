#!/usr/bin/env bash
# infer-type-label-from-commits.sh — infer and validate PR type: label from commit messages
#
# Purpose: Parse PR commits for conventional commit types, auto-apply a type: label
#   when all evaluable commits share one type, validate label/commit agreement for
#   uniform commits, and accept a manual type: label when commit types are mixed or
#   when some commits are non-conventional (commitlint validates message format).
# Usage: bash assets/pr-labeler/infer-type-label-from-commits.sh
# Dependencies: bash 3.2+, gh, node, commitlint.config.js at repo root
# Offline use: set MOCK_COMMITS_JSON and MOCK_PR_LABELS for local fixture testing
# Inputs: GH_TOKEN, GITHUB_REPOSITORY, PR_NUMBER, PR_HEAD_REF (optional)
# Outputs: GITHUB_OUTPUT keys result, failure_reason, commit_type, inferred_label,
#   commit_types_found, auto_labeled
# Compatible: bash 3.2+ / zsh, Ubuntu 20.04+, macOS 12+
#
set -euo pipefail

GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/stdout}"

# -------------------------------------------------------
# Write a single GitHub Actions output (multiline-safe).
# -------------------------------------------------------
gha_output() {
    local key="$1"
    local value="$2"
    {
        printf '%s=%s\n' "${key}" "${value}"
    } >> "${GITHUB_OUTPUT}"
}

# -------------------------------------------------------
# Exit with failure outputs set.
# -------------------------------------------------------
fail_with() {
    local reason="$1"
    gha_output "result" "failure"
    gha_output "failure_reason" "${reason}"
    gha_output "auto_labeled" "false"
    exit 0
}

# -------------------------------------------------------
# fail_with after optional context fields are set
# -------------------------------------------------------
fail_with_context() {
    local reason="$1"
    gha_output "commit_types_found" "${2:-}"
    gha_output "inferred_label" "${3:-}"
    fail_with "${reason}"
}

# -------------------------------------------------------
# Exit with success outputs set.
# -------------------------------------------------------
succeed_with() {
    local commit_type="$1"
    local inferred_label="$2"
    local auto_labeled="$3"
    local types_found="$4"
    gha_output "result" "success"
    gha_output "failure_reason" ""
    gha_output "commit_type" "${commit_type}"
    gha_output "inferred_label" "${inferred_label}"
    gha_output "commit_types_found" "${types_found}"
    gha_output "auto_labeled" "${auto_labeled}"
    exit 0
}

# -------------------------------------------------------
# Skip infer for dependabot PRs (matches check-commits.yml).
# -------------------------------------------------------
skip_infer() {
    gha_output "result" "skipped"
    gha_output "failure_reason" ""
    gha_output "auto_labeled" "false"
    exit 0
}

# -------------------------------------------------------
# Return 0 if subject should be skipped (merge, WIP).
# Only skip WIP-prefixed subjects (e.g. "WIP:", "WIP(scope):");
# do not skip conventional commits that mention WIP in the description.
# -------------------------------------------------------
should_skip_subject() {
    local subject="$1"
    case "${subject}" in
        Merge\ *) return 0 ;;
    esac
    if echo "${subject}" | grep -qiE '^WIP(\([^)]*\))?([:\s]|$)'; then
        return 0
    fi
    return 1
}

# -------------------------------------------------------
# Return 0 if full commit message is dependabot-authored.
# -------------------------------------------------------
is_dependabot_commit() {
    local full_message="$1"
    echo "${full_message}" | grep -q 'Signed-off-by: dependabot\[bot\]'
}

# -------------------------------------------------------
# Parse conventional commit type from subject line.
# Prints type on success; returns 1 if not conventional.
# -------------------------------------------------------
parse_commit_type() {
    local subject="$1"
    if echo "${subject}" | grep -qE '^[a-z]+(\([^)]*\))?!?:'; then
        echo "${subject}" | sed -E 's/^([a-z]+)(\([^)]*\))?!?:.*/\1/'
        return 0
    fi
    return 1
}

# -------------------------------------------------------
# Load allowed commit types from commitlint.config.js via node.
# -------------------------------------------------------
load_allowed_types() {
    local config_file="commitlint.config.js"
    if [[ ! -f "${config_file}" ]]; then
        echo "ERROR: ${config_file} not found at repo root" >&2
        exit 1
    fi
    node -e "
const cfg = require('./${config_file}');
const types = cfg.rules['type-enum'][2];
console.log(types.join(' '));
"
}

# -------------------------------------------------------
# Required environment
# -------------------------------------------------------
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${PR_NUMBER:?PR_NUMBER is required}"

if [[ -z "${GH_TOKEN:-}" ]]; then
    echo "ERROR: GH_TOKEN is required" >&2
    exit 1
fi

export GH_TOKEN

PR_HEAD_REF="${PR_HEAD_REF:-}"
if [[ "${PR_HEAD_REF}" == dependabot* ]] || [[ "${GITHUB_ACTOR:-}" == "dependabot[bot]" ]]; then
    echo "Skipping infer for dependabot PR"
    skip_infer
fi

# -------------------------------------------------------
# Map commitlint type to an existing type: label in the repo.
# Extended commitlint types without a dedicated label use
# the closest match defined in infra-open-pr skill.
# -------------------------------------------------------
map_commit_type_to_label_suffix() {
    local commit_type="$1"
    case "${commit_type}" in
        change|deprecate|remove) echo "chore" ;;
        security)                echo "fix" ;;
        *)                       echo "${commit_type}" ;;
    esac
}

ALLOWED_TYPES="$(load_allowed_types)"
is_allowed_type() {
    local t="$1"
    for allowed in ${ALLOWED_TYPES}; do
        if [[ "${t}" == "${allowed}" ]]; then
            return 0
        fi
    done
    return 1
}

# -------------------------------------------------------
# Fetch PR commits (subjects + full messages for dependabot skip)
# -------------------------------------------------------
if [[ -n "${MOCK_COMMITS_JSON:-}" ]]; then
    commits_json="${MOCK_COMMITS_JSON}"
else
    commits_json="$(gh api "repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}/commits" --paginate)"
fi

# -------------------------------------------------------
# Fetch existing type: labels on the PR
# -------------------------------------------------------
if [[ -n "${MOCK_PR_LABELS:-}" ]]; then
    pr_labels_json="${MOCK_PR_LABELS}"
else
    pr_labels_json="$(gh api "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/labels")"
fi

existing_type_labels="$(echo "${pr_labels_json}" | node -e "
const labels = JSON.parse(require('fs').readFileSync(0, 'utf8'));
labels.filter(l => l.name.startsWith('type:')).map(l => l.name).forEach(n => console.log(n));
")"

type_label_count=0
existing_type_label=""
while IFS= read -r label_name; do
    [[ -z "${label_name}" ]] && continue
    type_label_count=$((type_label_count + 1))
    existing_type_label="${label_name}"
done <<< "${existing_type_labels}"

if [[ "${type_label_count}" -gt 1 ]]; then
    gha_output "commit_types_found" ""
    fail_with "multiple-type-labels"
fi

# -------------------------------------------------------
# Parse commits and collect types
# -------------------------------------------------------
declare -a found_types=()
commit_count=0
evaluated_count=0

while IFS= read -r commit_line; do
    [[ -z "${commit_line}" ]] && continue
    commit_count=$((commit_count + 1))
    subject="${commit_line%%|SUBJSEP|*}"
    full_message="${commit_line#*|SUBJSEP|}"

    if is_dependabot_commit "${full_message}"; then
        continue
    fi
    if should_skip_subject "${subject}"; then
        continue
    fi

    if ! commit_type="$(parse_commit_type "${subject}")"; then
        # Commitlint validates message format; ignore non-conventional commits here.
        continue
    fi

    if ! is_allowed_type "${commit_type}"; then
        continue
    fi

    evaluated_count=$((evaluated_count + 1))

    # Deduplicate types while preserving order
    already_seen=0
    if [[ "${#found_types[@]}" -gt 0 ]]; then
        for t in "${found_types[@]}"; do
            if [[ "${t}" == "${commit_type}" ]]; then
                already_seen=1
                break
            fi
        done
    fi
    if [[ "${already_seen}" -eq 0 ]]; then
        found_types+=("${commit_type}")
    fi
done < <(
    echo "${commits_json}" | node -e "
const commits = JSON.parse(require('fs').readFileSync(0, 'utf8'));
for (const c of commits) {
  const msg = c.commit.message || '';
  const subject = msg.split('\n')[0];
  console.log(subject + '|SUBJSEP|' + msg.replace(/\n/g, ' '));
}
")

if [[ "${evaluated_count}" -eq 0 ]]; then
    if [[ "${type_label_count}" -eq 1 ]]; then
        # Only non-conventional or skipped commits — manual type: label is authoritative.
        succeed_with "" "${existing_type_label}" "false" ""
    fi
    gha_output "commit_types_found" ""
    fail_with "no-committable-commits"
fi

types_found_str="$(IFS=,; echo "${found_types[*]}")"
unique_count="${#found_types[@]}"

if [[ "${unique_count}" -gt 1 ]]; then
    gha_output "commit_types_found" "${types_found_str}"
    if [[ "${type_label_count}" -eq 1 ]]; then
        # Mixed commit types — the manually set type: label is authoritative.
        succeed_with "" "${existing_type_label}" "false" "${types_found_str}"
    fi
    fail_with "mixed-commits-need-label"
fi

commit_type="${found_types[0]}"
label_suffix="$(map_commit_type_to_label_suffix "${commit_type}")"
inferred_label="type:${label_suffix}"

# Single commit type — label must match inferred label when set manually.
if [[ "${type_label_count}" -eq 1 ]]; then
    if [[ "${existing_type_label}" != "${inferred_label}" ]]; then
        gha_output "commit_types_found" "${types_found_str}"
        gha_output "inferred_label" "${inferred_label}"
        fail_with "label-mismatch"
    fi
    succeed_with "${commit_type}" "${inferred_label}" "false" "${types_found_str}"
fi

# No type: label — verify label exists in repo before applying
if [[ -z "${MOCK_PR_LABELS:-}" ]]; then
    if ! gh label list --json name --limit 500 --jq '.[].name' | grep -qx "${inferred_label}"; then
        echo "ERROR: label '${inferred_label}' does not exist in repository" >&2
        fail_with_context "missing-label-in-repo" "${types_found_str}" "${inferred_label}"
    fi
    gh pr edit "${PR_NUMBER}" --repo "${GITHUB_REPOSITORY}" --add-label "${inferred_label}"
    echo "Auto-applied label ${inferred_label}"
fi

succeed_with "${commit_type}" "${inferred_label}" "true" "${types_found_str}"
