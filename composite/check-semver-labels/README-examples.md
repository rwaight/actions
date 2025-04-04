# Check Semver Labels Action


## Example Usage

Create a file named `.github/workflows/check-semver-labels.yml` with the following:
```yml
name: PR Labeler
run-name: Pull request labeler

on:
  pull_request:
    branches: [main]
    types:
      - opened
      - synchronize
      - reopened
      - labeled
      - unlabeled

jobs:
  pr-labeler:
    name: Label pull requests
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:

      - name: Checkout files from commit tree
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref_name }}
          token: ${{ github.token }}

      - name: Apply non-versioning labels
        id: label-pull-request
        uses: actions/labeler@v5
        with:
          repo-token: ${{ github.token }}

      - name: Check for semantic version labels
        uses: rwaight/actions/composite/check-semver-labels@main
        id: check-semver-labels
        with:
          gh-token: ${{ github.token }}
          allow_failure: true
          semver-fallback: 'triage:version-needed'
          semver-prefix: 'version:'
          verbose: true
```

