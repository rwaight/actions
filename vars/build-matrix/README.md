# Set build matrix

This GitHub [Composite Action](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) was created in [github.com/rwaight/actions](https://github.com/rwaight/actions).


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-matrix-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to set the build matrix

on:
  workflow_dispatch:
    inputs:
      WHICH_BASE_IMAGE:
        description: 'The base image to build'
        type: choice
        options:
        - "invalid"
        - "rocky8"
        - "rocky9"
        #- "all"
        default: "invalid"
      WHICH_PROVIDER:
        description: 'The cloud provider to build the image on'
        type: choice
        options:
        - "invalid"
        - "aws"
        - "azure"
        - "gcp"
        - "all"
        default: "invalid"

env:
  JSON_VARS_FILE: 'my-custom-vars.json'

jobs:
  set-matrix:
    runs-on: ubuntu-latest
    name: Set the build matrix
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get the build matrix
        id: get-matrix
        uses: rwaight/actions/vars/build-matrix@main
        with:
          input-base-image: ${{ inputs.WHICH_BASE_IMAGE || 'all' }}
          input-provider: ${{ inputs.WHICH_PROVIDER || 'all' }}
          json-vars-file: ${{ env.JSON_VARS_FILE }}
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build matrix
        id: print-build-matrix
        if: ${{ steps.get-matrix.outputs.build-matrix }}
        run: |
          echo "::group::starting step 'print-build-matrix' "
          echo ""
          echo "Output from the 'get-matrix' step"
          echo "    build-matrix: ${{ steps.get-matrix.outputs.build-matrix }} "
          echo ""
          echo "The output in the 'get-matrix' step was ${build_matrix} ."
          echo ""
          echo "completing the 'print-build-matrix' step. "
          echo "::endgroup::"
        env:
          build_matrix: ${{ steps.get-matrix.outputs.build-matrix }}
        shell: bash

      - name: Fail if the 'get-matrix' step did not provide output
        if: ${{ ! steps.get-matrix.outputs.build-matrix }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-matrix' step hint::No output provided"
          exit 1
        shell: bash
```
