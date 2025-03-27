# Set build version

This GitHub [Composite Action](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) was created in [github.com/rwaight/actions](https://github.com/rwaight/actions).


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

**Note**: If checkout is being performed before the action is called, you must include either `fetch-depth: 0` or `fetch-tags: true`
- This is needed until [actions/checkout#1467](https://github.com/actions/checkout/issues/1467) is resolved

### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-version-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to set the build version

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  set-version:
    runs-on: ubuntu-latest
    name: Set the build version
    steps:
      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 0

      - name: Get the build version
        id: get-version
        uses: rwaight/actions/vars/build-version@main
        with:
          checkout: false
          #event-name: ${{ github.event_name }}
          #gh-token: ${{ secrets.GITHUB_TOKEN }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          strategy: 'simple'
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build version
        id: print-build-version
        if: ${{ steps.get-version.outputs.build-version }}
        run: |
          echo "::group::starting step 'print-build-version' "
          echo ""
          echo "Output from the 'get-version' step"
          echo "    build-version: ${{ steps.get-version.outputs.build-version }} "
          echo ""
          echo "The output in the 'get-version' step was ${build_version} ."
          echo ""
          echo "completing the 'print-build-version' step. "
          echo "::endgroup::"
        env:
          build_version: ${{ steps.get-version.outputs.build-version }}
        shell: bash

      - name: Fail if the 'get-version' step did not provide output
        if: ${{ ! steps.get-version.outputs.build-version }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-version' step hint::No output provided"
          exit 1
        shell: bash
```
