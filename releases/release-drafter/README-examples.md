# GitHub Release Drafter Action Examples

## Updates to the action

None at this time.

## Deploying this action

### Usage

You can use the [Release Drafter GitHub Action](https://github.com/marketplace/actions/release-drafter) in a [GitHub Actions Workflow](https://help.github.com/en/articles/about-github-actions) by configuring a YAML-based workflow file, e.g. `.github/workflows/release-drafter.yml`, with the following:

```yaml
name: Release Drafter

on:
  push:
    # branches to consider in the event; optional, defaults to all
    branches:
      - master
  # pull_request event is required only for autolabeler
  pull_request:
    # Only following types are handled by the action, but one can default to all as well
    types: [opened, reopened, synchronize]
  # pull_request_target event is required for autolabeler to support PRs from forks
  # pull_request_target:
  #   types: [opened, reopened, synchronize]

permissions:
  contents: read

jobs:
  update_release_draft:
    permissions:
      # write permission is required to create a github release
      contents: write
      # write permission is required for autolabeler
      # otherwise, read permission is required at least
      pull-requests: write
    runs-on: ubuntu-latest
    steps:
      # (Optional) GitHub Enterprise requires GHE_HOST variable set
      #- name: Set GHE_HOST
      #  run: |
      #    echo "GHE_HOST=${GITHUB_SERVER_URL##https:\/\/}" >> $GITHUB_ENV

      # Drafts your next Release notes as Pull Requests are merged into "master"
      - name: Run my custom release-drafter
        uses: rwaight/actions/releases/release-drafter@v1
        id: run-release-drafter
        # (Optional) specify config name to use, relative to .github/. Default: release-drafter.yml
        # with:
        #   config-name: my-config.yml
        #   disable-autolabeler: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Provide output from release-drafter
        # Run this step if the 'id' output was set in the 'run-release-drafter' step
        if: ${{ steps.run-release-drafter.outputs.id }}
        run: |
         echo "The release drafter step outputs are: "
         echo "id: ${{ steps.run-release-drafter.outputs.id }}" 
         echo "name: ${{ steps.run-release-drafter.outputs.name }}" 
         echo "tag_name: ${{ steps.run-release-drafter.outputs.tag_name }}" 
         echo ""
         echo "URLs: "
         echo "html_url: ${{ steps.run-release-drafter.outputs.html_url }}" 
         echo "upload_url: ${{ steps.run-release-drafter.outputs.upload_url }}" 
         echo ""
         echo "Version Info: "
         echo "major_version: ${{ steps.run-release-drafter.outputs.major_version }}" 
         echo "minor_version: ${{ steps.run-release-drafter.outputs.minor_version }}" 
         echo "patch_version: ${{ steps.run-release-drafter.outputs.patch_version }}" 
         echo "resolved_version: ${{ steps.run-release-drafter.outputs.resolved_version }}" 
         echo ""
         echo "body: "
         echo "${{ steps.run-release-drafter.outputs.body }}"
         echo " === end of body === "
         echo ""
         echo "End of output from the release drafter step. "

```

If you're unable to use GitHub Actions, you can use the Release Drafter GitHub App. Please refer to the [Release Drafter GitHub App documentation](docs/github-app.md) for more information.
