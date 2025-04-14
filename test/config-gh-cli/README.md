# GitHub Template Composite Action

A template for building composite actions.

Reference GitHub's [creating a composite action guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) for more information.

#### GitHub [`steps` context](https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context)

Important note about the GitHub Actions [`steps` context](https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context):

> `steps.<step_id>.conclusion`. The result of a completed step after [`continue-on-error`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) is applied. Possible values are `success`, `failure`, `cancelled`, or `skipped`. When a `continue-on-error` step fails, the outcome is `failure`, but the final conclusion is `success`.
> 
> `steps.<step id>.outcome` The result of a completed step before [`continue-on-error`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) is applied. Possible values are `success`, `failure`, `cancelled`, or `skipped`. When a `continue-on-error` step fails, the outcome is `failure`, but the final conclusion is `success`.


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:
```yml
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
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@44c2b7a8a4ea60a981eaca3cf939b5f4305c123b # v4.1.5

      - name: Run the composite template action
        id: run-template-composite
        uses: rwaight/actions/test/template-composite@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          my-example-input1: 'hello'
          verbose: true

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
