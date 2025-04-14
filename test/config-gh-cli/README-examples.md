# Configure GitHub CLI Action

Configure the GitHub CLI using either a GitHub App (`bot`) or a GitHub User Account (`user`).


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
  github-cli:
    runs-on: ubuntu-latest
    name: Configure GitHub CLI
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Configure the GitHub CLI
        id: config-cli
        uses: rwaight/actions/test/config-gh-cli@main
        with:
          account-type: user
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          verbose: ${{ runner.debug == '1' }}

      - name: Report the output from the config-cli step
        if: ${{ steps.config-cli.outputs.user-login }}
        run: echo "The output in the 'config-cli' step was ${user-login} ."
        env:
          user-login: ${{ steps.config-cli.outputs.user-login }}

      - name: Fail if the 'config-cli' step did not provide output
        if: ${{ ! steps.config-cli.outputs.user-login }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'config-cli' step hint::No output provided"
          exit 1
```
