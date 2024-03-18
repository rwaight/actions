# Release Tag Updater Action

Consider migrating the [`sersoft-gmbh/running-release-tags-action`](https://github.com/sersoft-gmbh/running-release-tags-action) to this repo. 

The current version in this repo is based off of [**running-release-tags-action** v3.0.0](https://github.com/sersoft-gmbh/running-release-tags-action/tree/v3.0.0)
- This action is from https://github.com/sersoft-gmbh/running-release-tags-action.

The [`sersoft-gmbh/running-release-tags-action`](https://github.com/sersoft-gmbh/running-release-tags-action) code has a Apache License 2.0 license:
> A permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of patent rights. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

None at this time.

## Deploying this action

Use the following snippet to create a major and minor release for the tag `1.2.3`:
```yaml
name: Update release tags

on:
  # https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#release
  release:
    types: [published]
    # types: [published, updated]
  push:
    tags:
      - 'v*.*.*'
      #- v2.*
    #branches:
      #- 'releases/**'

jobs:
  update-tags:
    runs-on: ubuntu-latest
    env:
      PUBLISHED_TAG: ${{ github.ref }}

    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4

      - name: Update release tags
        id: release-tag-updater
        uses: rwaight/actions/releases/release-tag-updater@v1
        with:
          #tag: 1.2.3
          tag: ${{ env.PUBLISHED_TAG }}
          prefix-regex: 'v?'
          fail-on-non-semver-tag: true # default is false
          update-major: true
          update-minor: true
          skip-repo-setup: true # default is false
          create-release: false # default is true
        #if: github.event.release.prerelease == false
        if: (github.ref_type == 'tag' && github.event.release.prerelease == false)

```

