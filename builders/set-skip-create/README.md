# GitHub Composite Action - Builders: Set skip-create

This action is used with Packer to determine the `skip_create*` variable:
- `skip_create_image` for Google Cloud Platform
    - (bool) Skip creating the image. Useful for setting to `true` during a build test stage. Defaults to `false`.
    - [Packer Integration Docs: Builders - Google Cloud Platform](https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute)
- `skip_create_ami` for Amazon EBS
    - (bool) - If true, Packer will not create the AMI. Useful for setting to `true` during a build test stage. Default `false`.
    - [Packer Integration Docs: Builders - Amazon EBS](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs)

This action was created in https://github.com/rwaight/actions.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-skip-create-workflow.yml` with the following:
```
name: Run a GitHub workflow to set the build skip-create variable

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  set-skip-create:
    runs-on: ubuntu-latest
    name: Set the build skip-create
    steps:
      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Run the set-skip-create action
        id: run-set-skip-create
        uses: rwaight/actions/builders/set-skip-create@main
        with:
          checkout: false
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          strategy: 'simple'
          verbose: true

      - name: Report the output from the run-set-skip-create step
        if: ${{ steps.run-set-skip-create.outputs.build-skip-create }}
        run: echo "The output in the 'run-set-skip-create' step was ${build_skip_create} ."
        env:
          build_skip_create: ${{ steps.run-set-skip-create.outputs.build-skip-create }}

      - name: Fail if the 'run-set-skip-create' step did not provide output
        if: ${{ ! steps.run-set-skip-create.outputs.build-skip-create }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'run-set-skip-create' step hint::No output provided"
          exit 1

```
