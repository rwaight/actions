# Install Instruqt CLI Action

Installs the Instruqt CLI into the GitHub Runner


## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:
```yml
name: Install the Instruqt CLI

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  instruqt-cli:
    runs-on: ubuntu-latest
    name: Template Composite Action
    steps:
      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Run the Install Instruqt CLI action
        id: install-instruqt-cli
        uses: rwaight/actions/instruqt/install-cli@main
        with:
          version: latest
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

```
