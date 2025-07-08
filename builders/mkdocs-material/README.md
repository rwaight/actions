# GitHub Build Material for MkDocs Action

A composite action to build Material for MkDocs.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:
```yml
# from https://squidfunk.github.io/mkdocs-material/publishing-your-site/#with-github-actions
name: Publish site
run-name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
      - '.github/workflows/publish-pages.yml'
    tags:
      - 'v*.*.*'
      - '!v*.*'
      - '!v*'

permissions:
  contents: write
  id-token: write
  pages: write

jobs:
  build:
    runs-on: ubuntu-latest
    #name: Build Material for MkDocs Action
    steps:

      - name: Checkout files from commit tree
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 0
          # 'sparse-checkout' includes all files in the root directory, so we do not need to specify 'mkdocs.yml'
          # https://squidfunk.github.io/mkdocs-material/blog/2023/09/22/using-git-sparse-checkout-for-faster-documentation-builds/#github-actions
          sparse-checkout: |
            docs
            includes

      - name: Configure Git Credentials for github-actions bot
        run: |
          git config user.name github-actions[bot]
          git config user.email 41898282+github-actions[bot]@users.noreply.github.com

      - name: Run the 'Build Material for MkDocs' action
        id: build-mkdocs-material
        uses: rwaight/actions/builders/mkdocs-material@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          plugins: '["mkdocs-awesome-nav"]'
          python-version: '3.x'
          #verbose: true

      - name: Report the output from the build-mkdocs-material step
        if: ${{ steps.build-mkdocs-material.outputs.action-output1 }}
        run: echo "The output in the 'build-mkdocs-material' step was ${template_output1} ."
        env:
          template_output1: ${{ steps.build-mkdocs-material.outputs.action-output1 }}

      - name: Fail if the 'build-mkdocs-material' step did not provide output
        if: ${{ ! steps.build-mkdocs-material.outputs.action-output1 }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'build-mkdocs-material' step hint::No output provided"
          exit 1

```
