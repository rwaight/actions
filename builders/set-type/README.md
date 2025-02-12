# GitHub Composite Action - Builders: Set type

This action was created in https://github.com/rwaight/actions.


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

      - name: Run the set-type action
        id: run-set-type
        uses: rwaight/actions/builders/set-type@main
        with:
          checkout: false
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          strategy: 'simple'
          verbose: ${{ runner.debug == '1' }}

      - name: Report the output from the run-set-type step
        if: ${{ steps.run-set-type.outputs.build-type }}
        run: echo "The output in the 'run-set-type' step was ${build_type} ."
        env:
          build_type: ${{ steps.run-set-type.outputs.build-type }}

      - name: Fail if the 'run-set-type' step did not provide output
        if: ${{ ! steps.run-set-type.outputs.build-type }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-set-type' step hint::No output provided"
          exit 1

```
