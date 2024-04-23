# Get Next Semver Action

Get the next semantic version based on inputs.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

#### pre-release-id

The Pre-release identifier (only for pre-release builds). The only supported pre-release syntax is "rc" at this time.
* required: false
* default: `rc`

#### release-type

The release type, should be one of: major, minor, patch, or prerelease. The only supported pre-release syntax is "rc" at this time.
* required: true
* default: `not-set`

#### my_action_debug:

Determine if the workflow should run debug tasks, defaults to false.
* required: false
* default: `false`

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

#### current-version

The current release version in the repo.

#### next-version

The calculated next-release version in the repo, based on the provided inputs.


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
          #pre-release-id: ${{ inputs.preid }}
          release-type: ${{ inputs.release-type }}
          my_action_debug: true

      - name: Report the output from the get-next-semver step
        if: ${{ steps.get-next-semver.outputs.next-release-version }}
        run: |
          echo "The output from the 'get-next-semver' step was: "
          echo "current release version: ${{ env.current-release-version }} "
          echo "next release version: ${{ env.next-release-version }} "
        env:
          current-release-version: ${{ steps.get-next-semver.outputs.current-release-version }}
          next-release-version: ${{ steps.get-next-semver.outputs.next-release-version }}

      - name: Fail if the 'get-next-semver' step did not output the next release version
        if: ${{ ! steps.get-next-semver.outputs.next-release-version }}
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

