# Set build method

This GitHub [Composite Action](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) was created in [github.com/rwaight/actions](https://github.com/rwaight/actions).


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-method-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to set the build method

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  set-method:
    runs-on: ubuntu-latest
    name: Set the build method
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get the build method
        id: get-method
        uses: rwaight/actions/vars/build-method@main
        with:
          checkout: false
          #event-name: ${{ github.event_name }}
          #gh-token: ${{ secrets.GITHUB_TOKEN }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          strategy: 'github-event'
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build method
        id: print-build-method
        if: ${{ steps.get-method.outputs.build-method }}
        run: |
          echo "::group::starting step 'print-build-method' "
          echo ""
          echo "Output from the 'get-method' step"
          echo "    build-method: ${{ steps.get-method.outputs.build-method }} "
          echo ""
          echo "The output in the 'get-method' step was ${build_method} ."
          echo ""
          echo "completing the 'print-build-method' step. "
          echo "::endgroup::"
        env:
          build_method: ${{ steps.get-method.outputs.build-method }}
        shell: bash

      - name: Fail if the 'get-method' step did not provide output
        if: ${{ ! steps.get-method.outputs.build-method }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-method' step hint::No output provided"
          exit 1
        shell: bash
```
