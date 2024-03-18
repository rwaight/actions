# GitHub Packer Build Action

The current version in this repo was based off of [**packer-build-action** v1.5](https://github.com/riznob/packer-build-action/releases/tag/v1.5)
- This action is from https://github.com/riznob/packer-build-action.


The [`riznob/packer-build-action`](https://github.com/riznob/packer-build-action) has an Apache-2.0 license:
> A permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of patent rights. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

None at this time.

## Packer build action

This action runs packer build.

## Inputs

### `templateFile`

**Optional** Packer template file to use for packer build. Default `"packer-template.json"`.

### `varFile`

**Optional** Var file to use for packer build. Default `"packer-vars.json"`.

### `workingDir`

**Optional** Directory where the packer template and var file reside. Default `"."`.

## Outputs

## Deploying this action

### Example usage

To configure the action simply add the following lines to your `.github/workflows/packer-build.yml` workflow file:

```
name: Run packer build on a template file

on:
  push:
    branches:
        - 'main'
jobs:
  packer_build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4

      - name: Run packer build action
        uses: rwaight/actions/builders/packer@v1
        with:
          templateFile: 'packer-template.json'
          varFile: 'packer-vars.json'
          workingDir: '.'
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: us-west-2
```
