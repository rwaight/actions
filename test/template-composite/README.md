# GitHub Template Composite Action

A template for building composite actions.

Reference GitHub's [creating a composite action guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) for more information.


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:
```
name: Run a GitHub workflow

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  run-example-action:
    runs-on: ubuntu-latest
    name: Template Composite Action
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4

      - name: Run the composite template action
        id: run-template-composite
        uses: rwaight/actions/test/template-composite@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          my-example-input1: 'hello'
          action-verbose: true

      - name: Report the output from the run-template-composite step
        if: ${{ steps.run-template-composite.outputs.action-output1 }}
        run: echo "The output in the 'run-template-composite' step was ${template_output1} ."
        env:
          template_output1: ${{ steps.run-template-composite.outputs.action-output1 }}

      - name: Fail if the 'run-template-composite' step did not provide output
        if: ${{ ! steps.run-template-composite.outputs.action-output1 }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-template-composite' step hint::No output provided"
          exit 1

```
