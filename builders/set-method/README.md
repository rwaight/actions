# GitHub Composite Action - Builders: Set method

This action was created in https://github.com/rwaight/actions.


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-method-workflow.yml` with the following:
```
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

      - name: Run the set-method action
        id: run-set-method
        uses: rwaight/actions/builders/set-method@main
        with:
          checkout: false
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          strategy: 'simple'
          verbose: true

      - name: Report the output from the run-set-method step
        if: ${{ steps.run-set-method.outputs.build-method }}
        run: echo "The output in the 'run-set-method' step was ${build_method} ."
        env:
          build_method: ${{ steps.run-set-method.outputs.build-method }}

      - name: Fail if the 'run-set-method' step did not provide output
        if: ${{ ! steps.run-set-method.outputs.build-method }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-set-method' step hint::No output provided"
          exit 1

```
