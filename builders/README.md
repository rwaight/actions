# Actions used for builds

This directory contains actions that are used for building packages, images, etc.

###

### Using KVM (Nested virtualization) in GitHub Actions

If you need to leverage nested virtualization (for example: [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine)) in order to build images using GitHub Actions, then review the following:
- https://github.blog/changelog/2023-02-23-hardware-accelerated-android-virtualization-on-actions-windows-and-linux-larger-hosted-runners/, **and**
- https://github.com/actions/runner-images/issues/183#issuecomment-1442154492
    - Migrated to https://github.com/actions/runner-images/discussions/7191

As well as:
- https://actuated.dev/blog/kvm-in-github-actions
- https://github.com/actions/runner-images/issues/183
    - Specifically, https://github.com/actions/runner-images/issues/183#issuecomment-1442154492, links to the GitHub changelog

## Example usage

Create a file named `.github/workflows/my-build-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to determine build variables

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:

  set-vars:
    runs-on: ubuntu-latest
    name: Set the build variables
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          fetch-depth: 0

      - name: Get the build version using rwaight/actions builders/set-version
        id: get-version
        uses: rwaight/actions/builders/set-version@main
        with:
          checkout: false
          #event-name: ${{ github.event_name }}
          #gh-token: ${{ secrets.GITHUB_TOKEN }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          strategy: 'simple'
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build version
        id: print-build-version
        if: ${{ steps.get-version.outputs.build-version }}
        shell: bash
        run: |
            echo "::group::starting step 'print-build-version' "
            echo ""
            echo "Output from the 'get-version' step"
            echo "    build-version: ${{ steps.get-version.outputs.build-version }} "
            echo ""
            echo "completing the 'print-build-version' step. "
            echo "::endgroup::"

      - name: Get the build method using rwaight/actions builders/set-method
        id: get-method
        uses: rwaight/actions/builders/set-method@main
        with:
          checkout: false
          #event-name: ${{ github.event_name }}
          #gh-token: ${{ secrets.GITHUB_TOKEN }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          strategy: 'github-event'
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print build method
        id: print-build-method
        if: ${{ steps.get-method.outputs.build-method }}
        shell: bash
        run: |
            echo "::group::starting step 'print-build-method' "
            echo ""
            echo "Output from the 'get-method' step"
            echo "    build-method: ${{ steps.get-method.outputs.build-method }} "
            echo ""
            echo "completing the 'print-build-method' step. "
            echo "::endgroup::"
```
