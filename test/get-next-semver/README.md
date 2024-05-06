# Get Next Semver Action

Get the next semantic version based on inputs.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

#### release-type

* required: true
* default: `not-set`

The release type, input one of: 
* `major`,
* `minor`,
* `patch`,
* `prerelease`,
* `premajor`,
* `preminor`,
* `prepatch`, or
* `pretoprod`

For production releases, select the appropriate: `major`, `minor`, or `patch`

For prereleases, select prerelease when you are already working on a prerelease tag (example: 0.2.1-rc1):
* select premajor when you need to create a new premajor prerelease; 
* select preminor when you need to create a new preminor prerelease; or 
* select prepatch when you need to create a new prepatch prerelease.
 
Note that only `rc` has been tested as a pre-release syntax.

#### pre-release-id

* required: false
* default: `rc`

The Pre-release identifier (only for pre-release builds). Currently, only `rc` has been tested as a pre-release syntax.

#### action-verbose

Determine if the action should run verbose tasks, defaults to false.
* required: false
* default: `false`

#### gh-token

* required: true
* default: `${{ github.token }}`

The `GITHUB_TOKEN` or a `repo` scoped Personal Access Token (PAT), may be needed to run the `gh release` command depending on permissions granted to the default GitHub token.


### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

#### next-version

The calculated next-release version in the repo, based on the provided inputs. 

<details><summary>Determining the next-version output</summary>

The `next-version` output is currently determined using:
```bash
# Increment a PRERELEASE '-rc' version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="-rc"} {$2+=1} 1'
# Increment a PATCH version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$3+=1} 1'
# Increment a MINOR version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$2+=1;$3=0} 1'
# Increment a MAJOR version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$1+=1;$2=0;$3=0} 1'
# Create a PREPATCH version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$3+=1} 1' | awk 'BEGIN{FS=OFS="-rc"} {$2+=1} 1'
# Create a PREMINOR version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$2+=1;$3=0} 1' | awk 'BEGIN{FS=OFS="-rc"} {$2+=1} 1'
# Create a PREMAJOR version:
echo "${current-version}" | awk 'BEGIN{FS=OFS="."} {$1+=1;$2=0;$3=0} 1' | awk 'BEGIN{FS=OFS="-rc"} {$2+=1} 1'
```

</details>


#### is-next-prerelease

If the calculated next-release version is a prerelease (**true**) or not (**false**), based on the provided inputs.

This can be used with the `include-pre-releases` option in [`release-drafter`](https://github.com/release-drafter/release-drafter):
```yml
      - name: Run release-drafter
        uses: release-drafter/release-drafter@v6.0.0
        id: draft-release
        with:
          # https://github.com/release-drafter/release-drafter/pull/1302
          include-pre-releases: ${{ steps.get-next-semver.outputs.is-next-prerelease }}
          #include-pre-releases: true
```

#### current-tag

The current tag from the repo. 

<details><summary>Determining the current-tag output</summary>

The `current-tag` output is currently determined using:
```bash
git describe --tags `git rev-list --tags --max-count=1`
```

</details>


#### current-version

The current GitHub release version in the repo. 

<details><summary>Determining the current-version output</summary>

The `current-version` output is currently determined using:
```bash
# for production: major, minor, patch releases
gh release list --exclude-drafts --exclude-pre-releases --limit 1 --json tagName | jq -r ".[].tagName"

# for pre-releases: prerelease, premajor, preminor, prepatch
gh release list --exclude-drafts --limit 1 --json tagName | jq -r ".[].tagName"
```

</details>



## Example Usage

Create a file named `.github/workflows/get-next-semver.yml` with the following:
```
name: Get Next Semver
run-name: Get Next Semver

on:
  workflow_dispatch:
    inputs:
      release-type:
        description: 'Release type'
        type: choice
        required: true
        options:
          - major
          - minor
          - patch
          - premajor
          - preminor
          - prepatch
          - prerelease
        default: patch
      preid:
        description: 'Pre-release identifier (only for pre-release builds)'
        default: rc
        required: false

jobs:
  get-next-semver:
    runs-on: ubuntu-latest
    name: Get Next Semver
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4
        with:
          fetch-depth: '0'
          fetch-tags: true
          ref: ${{ github.ref_name }}
          token: ${{ github.token }}

      - name: Set up git config
        id: set-up-git
        run: |
          git --version
          git config user.name "github-actions"
          git config user.email "<github-actions@github.com>"
          git status
          echo "the 'set-up-git' step has completed. "

      - name: Get Next Semver
        id: get-next-semver
        uses: rwaight/actions/test/get-next-semver@main
        with:
          gh-token: ${{ github.token }}
          pre-release-id: ${{ inputs.preid }}
          release-type: ${{ inputs.release-type }}
          action-verbose: true

      - name: Report the output from the get-next-semver step
        if: ${{ steps.get-next-semver.outputs.next-version }}
        run: |
          echo "The output from the 'get-next-semver' step was: "
          echo "current tag       : ${{ env.current-tag }} "
          echo "current version   : ${{ env.current-version }} "
          echo "next version      : ${{ env.next-version }} "
          echo "is next prerelease: ${{ env.is-next-prerelease }} "
        env:
          current-tag: ${{ steps.get-next-semver.outputs.current-tag }}
          current-version: ${{ steps.get-next-semver.outputs.current-version }}
          next-version: ${{ steps.get-next-semver.outputs.next-version }}
          is-next-prerelease: ${{ steps.get-next-semver.outputs.is-next-prerelease }}

      - name: Fail if the 'get-next-semver' step did not output the next release version
        if: ${{ ! steps.get-next-semver.outputs.next-version }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-next-semver' step hint::Next release version was not provided"
          exit 1

```

### About `actions/checkout`

The token you use when setting up the repo with this action will determine what token `get-next-semver` will use.  

### Working with PRs

By default, when you use `actions/checkout` on a PR, it will checkout the head commit in a detached head state.
If you want to make some changes, you have to checkout the branch the PR is coming from in the head repo.  
You can set it up like this:

```yaml
- uses: actions/checkout@v4
  with:
    repository: ${{ github.event.pull_request.head.repo.full_name }}
    ref: ${{ github.event.pull_request.head.ref }}
```

You can find the full docs for payloads of `pull_request` events [here](https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#webhook-payload-example-32).

