# GitHub Export Label Config Action

This action is meant to be used with the `rwaight/actions/github/label-sync` action.

The current version in this repo is based off of [**export-label-config** v1.0.1](https://github.com/EndBug/export-label-config/releases/tag/v1.0.1)
- **Note**: You must use the (classic) personal access tokens when configuring the `token`
- This action is from https://github.com/EndBug/export-label-config.

The [`EndBug/export-label-config`](https://github.com/EndBug/export-label-config) code has a MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.


## Deploying this action

Example workflow:
```
name: Export label config
on: 
  # You can run this with every event, but it's better to run it only when you actually need it.
  workflow_dispatch:

jobs:
  labels:
    runs-on: ubuntu-22.04
    
    name: Run My custom export-label-config action
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4

      - name: Branch
        run: echo running on branch ${GITHUB_REF##*/}

      - name: Run export label config action
        #uses: rwaight/actions/github/export-label-config@main # can use version specific or main
        uses: rwaight/actions/github/export-label-config@v1.1.0
        with:
          # This is needed if you're dealing with private repos.
          token: ${{ secrets.MY_ACTIONS_TOKEN }}

          # Set this to `true` if you want to get the raw API reponse. Defaults to `false`.
          raw-result: false

          # By default every label entry will have an `aliases` property set to an empty array.
          # It's for EndBug/label-sync, if you don't want it you can set this to `false`
          add-aliases: true
```
