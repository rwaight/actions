# Get Commit Hash Action

Get the current commit hash suffix. The hash suffix is `-g` + an unambiguous abbreviation for the tip commit of parent.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

#### gh-token

* required: true
* default: `${{ github.token }}`

The `GITHUB_TOKEN` or a `repo` scoped Personal Access Token (PAT), may be needed to run the `git describe` command depending on permissions granted to the default GitHub token.

#### action-verbose

Determine if the action should run verbose tasks, defaults to false.
* required: false
* default: `false`


### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

#### current-version-tag

The full version tag from the repo.

#### current-hash-suffix

The hash suffix is '-g' + an unambiguous abbreviation for the tip commit of parent.


## Example Usage

Create a file named `.github/workflows/get-commit-hash.yml` with the following:
```
name: Get Commit Hash
run-name: Get Commit Hash

on: [push, pull_request]

jobs:
  commit-hash:
    runs-on: ubuntu-latest
    steps:
      - name: Run the checkout action
        uses: actions/checkout@v4
        with:
          fetch-depth: '0'
          fetch-tags: true
          ref: ${{ github.ref_name }}
          token: ${{ github.token }}


      - name: Get Commit Hash
        id: get-commit-hash
        uses: rwaight/actions/test/get-commit-hash@main
        with:
          gh-token: ${{ github.token }}
          action-verbose: true

      - name: Report the output from the get-commit-hash step
        if: ${{ steps.get-commit-hash.outputs.current-hash-suffix }}
        run: |
          echo "The output from the 'get-commit-hash' step was: "
          echo "current version tag: ${{ env.current-version-tag }} "
          echo "current hash suffix: ${{ env.current-hash-suffix }} "
        env:
          current-version-tag: ${{ steps.get-commit-hash.outputs.current-version-tag }}
          current-hash-suffix: ${{ steps.get-commit-hash.outputs.current-hash-suffix }}

      - name: Fail if the 'get-commit-hash' step did not output the current hash suffix
        if: ${{ ! steps.get-commit-hash.outputs.current-hash-suffix }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'get-commit-hash' step hint::The current hash suffix was not provided"
          exit 1

```

### About `actions/checkout`

The token you use when setting up the repo with this action will determine what token `get-commit-hash` will use.  

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

