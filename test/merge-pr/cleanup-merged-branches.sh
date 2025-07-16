#!/bin/bash

# from https://github.com/cli/cli/issues/9073#issuecomment-2677224454

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 owner/repo"
    exit 1
fi

# Variables
REPO="$1"
GITHUB_SERVER_URL="https://github.com"

# Get all branches
BRANCHES=$(git ls-remote $GITHUB_SERVER_URL/$REPO 2>/dev/null | { grep -o 'refs/heads/.*' || true; } | sed 's/refs\/heads\///' | jq -Rn '{branches: [inputs]}')

# Get all closed pull requests
PRS=$(gh pr list --repo $REPO --state closed --limit 100000 --json number,headRefName --jq '{prs: .}')

# Calculate difference
CLOSED_PRS_WITH_BRANCHES=$(jq -s 'add' <(echo "$BRANCHES") <(echo "$PRS") | jq -c '[.branches[] as $branches | .prs[] | select(.headRefName | IN($branches))] | sort_by(.number)')

# Iterate over each pull request
echo "$CLOSED_PRS_WITH_BRANCHES" | jq -c '.[]' | while read -r pr; do
    pr_number=$(echo "$pr" | jq -r '.number')
    branch_name=$(echo "$pr" | jq -r '.headRefName')

    gh api -X DELETE "repos/$REPO/git/refs/heads/$branch_name"
    echo "PR #$pr_number deleted branch: $branch_name"
done
