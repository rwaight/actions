# GitHub Composite Action - Repo version information

Provide version information from a git repo.
<!--- 
The current version in this repo was based off of [rwaight/actions **repo-version-info** v0.1.31](https://github.com/rwaight/actions/releases/tag/v0.1.31)
- This action is from https://github.com/rwaight/actions.
 --->

## Deploying this action

### Inputs

See the `inputs` section of the [action.yml](action.yml) file.

### Outputs

See the `outputs` section of the [action.yml](action.yml) file.

## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:

```yaml
name: Print repo version information
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - ready_for_review
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  version-info:
    name: Repo version information
    runs-on: ubuntu-latest
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4

      - name: Get repo version information
        id: repo-version-info
        uses: rwaight/actions/git/repo-version-info@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Print repo version information
        id: print-repo-info
        if: |
          ${{ steps.repo-version-info.outputs.latest-tag }} || 
          ${{ steps.repo-version-info.outputs.latest-release }}
        run: |
          echo "Here is the info from the repo-version-info step: "
          echo "latest release: ${{ steps.repo-version-info.outputs.latest-release }}"
          echo "latest tag: ${{ steps.repo-version-info.outputs.latest-tag }}"
```
