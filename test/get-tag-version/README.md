# GitHub Composite Action - Get Tag Version

A GitHub action that provides the tag version from a `push` event, specifically when a tag is created.  The action expects the `github.ref_type` to be `'tag'`

## Deploying this action

This action uses `git` commands to detect changes, the repository **must** be already [checked out](https://github.com/actions/checkout):
```yml
      - name: Checkout files from commit tree
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@1d96c772d19495a3b5c517cd2bc0cb401ea0529f # v4.1.3
        id: checkout
        with:
          fetch-depth: 0
```


### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

## Example Usage

Create a file named `.github/workflows/my-tag-version.yml` with the following:
```yml
name: Get the tag version

on: 
  push:
    tags:
      - 'v*.*.*'

jobs:
  run-get-tag-action:
    runs-on: ubuntu-latest
    name: Get the tag version
    steps:
      - name: Checkout files from commit tree
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@44c2b7a8a4ea60a981eaca3cf939b5f4305c123b # v4.1.5
        id: checkout
        with:
          fetch-depth: 0

      - name: get-tag-version
        id: get-tag-version
        uses: rwaight/actions/test/get-tag-version@main
        if: (github.ref_type == 'tag')
        with:
          verbose: true

      - name: get-tag-version | Print outputs
        id: check-get-tag-version
        #if: (github.ref_type == 'tag')
        if: ${{ steps.get-tag-version.outputs.full-version-ref }}
        shell: bash
        run: |
          echo "starting step 'check-get-tag-version' "
          echo "## get-tag-version outputs"
          echo "Full version : ${{ env.FULL_VERSION_REF }} "
          echo "Major ref    : ${{ env.MAJOR_REF }} "
          echo "Minor ref    : ${{ env.MINOR_REF }} "
          echo "Patch ref    : ${{ env.PATCH_REF }} "
          echo "Prerelease   : ${{ env.PRERELEASE }} "
          echo "Is prerelease: ${{ env.IS_PRERELEASE }} "
          echo ""
          echo "Major num    : ${{ env.MAJOR_NUM }} "
          echo "Minor num    : ${{ env.MINOR_NUM }} "
          echo "Patch num    : ${{ env.PATCH_NUM }} "
          echo ""
          echo "completing the 'check-get-tag-version' step. "
        env:
          #FULL_VERSION_TAG: ${{ steps.get-tag-version.outputs.full-version-tag }}
          FULL_VERSION_REF: ${{ steps.get-tag-version.outputs.full-version-ref }}
          MAJOR_REF: ${{ steps.get-tag-version.outputs.major-ref }}
          MINOR_REF: ${{ steps.get-tag-version.outputs.minor-ref }}
          PATCH_REF: ${{ steps.get-tag-version.outputs.patch-ref }}
          MAJOR_NUM: ${{ steps.get-tag-version.outputs.major-num }}
          MINOR_NUM: ${{ steps.get-tag-version.outputs.minor-num }}
          PATCH_NUM: ${{ steps.get-tag-version.outputs.patch-num }}
          PRERELEASE: ${{ steps.get-tag-version.outputs.prerelease }}
          IS_PRERELEASE: ${{ steps.get-tag-version.outputs.is-prerelease }}

      - name: Fail if the 'get-tag-version' step did not provide output
        if: ${{ ! steps.get-tag-version.outputs.full-version-ref }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-tag-version' step hint::No output provided"
          exit 1

```
