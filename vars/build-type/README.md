# Set build type

This GitHub [Composite Action](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) was created in [github.com/rwaight/actions](https://github.com/rwaight/actions).


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-type-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to set the build type

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  set-type:
    runs-on: ubuntu-latest
    name: Set the build type
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 0

      - name: Get the build type
        id: get-type
        uses: rwaight/actions/vars/build-type@main
        with:
          checkout: false
          #event-name: ${{ github.event_name }}
          #gh-token: ${{ secrets.GITHUB_TOKEN }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build type
        id: print-build-type
        if: ${{ steps.get-type.outputs.build-type }}
        run: |
          echo "::group::starting step 'print-build-type' "
          echo ""
          echo "Output from the 'get-type' step"
          echo "    build-type: ${{ steps.get-type.outputs.build-type }} "
          echo ""
          echo "The output in the 'get-type' step was ${build_type} ."
          echo ""
          echo "completing the 'print-build-type' step. "
          echo "::endgroup::"
        env:
          build_type: ${{ steps.get-type.outputs.build-type }}
        shell: bash

      - name: Fail if the 'get-type' step did not provide output
        if: ${{ ! steps.get-type.outputs.build-type }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-type' step hint::No output provided"
          exit 1
        shell: bash
```
