# GitHub Composite Action - Builders: Set version

This action was created in https://github.com/rwaight/actions.


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
name: Run a GitHub workflow to set the version

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

      - name: Run the set-version action
        id: run-set-version
        uses: rwaight/actions/builders/set-version@main
        with:
          checkout: false
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          strategy: 'simple'
          verbose: ${{ runner.debug == '1' }}

      - name: Report the output from the run-set-version step
        if: ${{ steps.run-set-version.outputs.build-version }}
        run: echo "The output in the 'run-set-version' step was ${build_version} ."
        env:
          build_version: ${{ steps.run-set-version.outputs.build-version }}

      - name: Fail if the 'run-set-version' step did not provide output
        if: ${{ ! steps.run-set-version.outputs.build-version }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-set-version' step hint::No output provided"
          exit 1

```
