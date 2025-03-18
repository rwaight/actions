# GitHub Runner Debug Mode Action

An action to check if the GitHub Runner is in Debug Mode

- https://github.com/actions/runner/issues/2204#issuecomment-1287947031
- https://github.com/orgs/community/discussions/27627#discussioncomment-3302259

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

There are no outputs from this action.


## Example Usage

Create a file named `.github/workflows/my-example-workflow.yml` with the following:
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

      - name: GitHub Runner Debug Mode
        id: runner-debug-mode
        #if: inputs.VERBOSE=='true' || ${{ runner.debug == '1' }}
        if: ${{ runner.debug == '1' }}
        uses: rwaight/actions/github/runner-debug@main
        with:
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

```
