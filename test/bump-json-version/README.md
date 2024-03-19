# Bump JSON Version Action

Bump a custom version field in a JSON file.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/bump-json-version.yml` with the following:
```
name: Bump JSON version
run-name: Bump JSON version

on:
  workflow_dispatch:
    inputs:
      release-type:
        description: 'Release type'
        type: choice
        required: true
        options:
          - major
          - minor
          - patch
          - prerelease
        default: patch

jobs:
  run-bump-version:
    runs-on: ubuntu-latest
    name: Bump JSON version
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4

      - name: Bump the JSON version
        id: run-template-composite
        uses: rwaight/actions/test/bump-json-version@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          # you should instead 
          gh-setup: true
          gh-user-name: 'my-custom-bot'
          gh-user-email: '<noreply@github.com>'
          json-vars-file: 'hello'
          json-vars-field: true
          release-type: 
          my_action_debug: true

      - name: Report the output from the run-template-composite step
        if: ${{ steps.run-template-composite.outputs.my_action_output }}
        run: echo "The output in the 'run-template-composite' step was $template_output ."
        env:
          template_output: ${{ steps.run-template-composite.outputs.my_action_output }}

      - name: Fail if the 'run-template-composite' step did not provide output
        if: ${{ ! steps.run-template-composite.outputs.my_action_output }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-template-composite' step hint::No output provided"
          exit 1

```
