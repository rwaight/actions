# GitHub Public IP Action

The current version in this repo is based off of [**public-ip** v1.3](https://github.com/haythem/public-ip/releases/tag/v1.3)
- This action is from https://github.com/haythem/public-ip.

The [`haythem/public-ip`](https://github.com/haythem/public-ip) code has a MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

As identified in https://github.com/haythem/public-ip/issues/23, there are multiple `ETIMEDOUT` and `ECONNRESET` failures.  The changes listed in https://github.com/haythem/public-ip/pull/24 have been added to the public-ip action to try to reduce the amount of failures.

## Deploying this action

Example workflow:
```
name: Get the public IP of the GitHub runner

on: push

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Get the public IP of the GitHub runner
        id: runner-ip
        #uses: rwaight/actions/utilities/public-ip@main # can use version specific or main
        uses: rwaight/actions/utilities/public-ip@v1

      - name: Print the public IP of the GitHub runner
        run: |
          echo ${{ steps.runner-ip.outputs.ipv4 }}
          echo ${{ steps.runner-ip.outputs.ipv6 }}
```
