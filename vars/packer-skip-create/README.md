# Set Packer skip-create

This action is used with Packer to determine the `skip_create*` variable:
- `skip_create_image` for Google Cloud Platform
    - (bool) Skip creating the image. Useful for setting to `true` during a build test stage. Defaults to `false`.
    - [Packer Integration Docs: Builders - Google Cloud Platform](https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute)
- `skip_create_ami` for Amazon EBS
    - (bool) - If true, Packer will not create the AMI. Useful for setting to `true` during a build test stage. Default `false`.
    - [Packer Integration Docs: Builders - Amazon EBS](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs)


This GitHub [Composite Action](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) was created in [github.com/rwaight/actions](https://github.com/rwaight/actions).

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.


### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage

Create a file named `.github/workflows/my-skip-create-workflow.yml` with the following:
```yml
name: Run a GitHub workflow to set the build skip-create variable

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'
  workflow_dispatch:
    inputs:
      create_image:
        description: 'Create an image from build'
        required: true
        default: false
        # if this 'create_image' input is 'false', then it will set the `skip_create*` variable to 'true'
        type: boolean
  schedule:
    - cron: '15 14 * * 2'  # once a week on Tuesday at 14:15 UTC, https://www.timeanddate.com/worldclock/timezone/utc

jobs:
  set-skip-create:
    runs-on: ubuntu-latest
    name: Set Packer skip-create
    steps:

      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Packer image-skip-create
        id: get-skip-create
        uses: rwaight/actions/vars/packer-skip-create@main
        with:
          create-image: ${{ inputs.create_image }}
          #event-name: ${{ github.event_name }}
          #ref: ${{ github.ref }}
          #ref-name: ${{ github.ref_name }}
          #ref-type: ${{ github.ref_type }}
          #release-tag-name: ${{ github.event.release.tag_name }}
          #workflow: ${{ github.workflow }}
          #workflow-summary: false
          #verbose: true
          verbose: ${{ runner.debug == '1' }}

      - name: Print image-skip-create
        id: print-image-skip-create
        if: ${{ steps.get-skip-create.outputs.image-skip-create }}
        run: |
          echo "::group::starting step 'print-image-skip-create' "
          echo ""
          echo "Output from the 'get-skip-create' step"
          echo "    image-skip-create: ${{ steps.get-skip-create.outputs.image-skip-create }} "
          echo "    image-skip-note  : ${{ steps.get-skip-create.outputs.image-skip-note }} "
          echo "    image-skip-reason: "
          echo "        ${{ steps.get-skip-create.outputs.image-skip-reason }} "
          echo ""
          echo "The output in the 'get-skip-create' step was ${image_skip_create} ."
          echo ""
          echo "completing the 'print-image-skip-create' step. "
          echo "::endgroup::"
        env:
          image_skip_create: ${{ steps.get-skip-create.outputs.image-skip-create }}
        shell: bash

      - name: Fail if the 'get-skip-create' step did not provide output
        if: ${{ ! steps.get-skip-create.outputs.image-skip-create }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-skip-create' step hint::No output provided"
          exit 1
        shell: bash
```
