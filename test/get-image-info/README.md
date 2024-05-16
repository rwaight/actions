# GitHub Composite Action - Get image info

Get information about an image from a cloud provider.


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
  get-image-info:
    runs-on: ubuntu-latest
    name: Get image info
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4

      - name: Run the get image info action
        id: run-get-image-info
        uses: rwaight/actions/test/get-image-info@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          my-example-input1: 'hello'
          verbose: true

      - name: Report the output from the run-get-image-info step
        if: ${{ steps.run-get-image-info.outputs.action-output1 }}
        run: echo "The output in the 'run-get-image-info' step was ${example_output1} ."
        env:
          example_output1: ${{ steps.run-get-image-info.outputs.action-output1 }}

      - name: Fail if the 'run-get-image-info' step did not provide output
        if: ${{ ! steps.run-get-image-info.outputs.action-output1 }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-get-image-info' step hint::No output provided"
          exit 1

```
