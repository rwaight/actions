# Check Semver Labels Action

Check a pull request for semver labels using the label-checker action

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.

## Example Usage

Create a file named `.github/workflows/check-semver-labels.yml` with the following:
```yml
name: PR Labeler
run-name: Pull request labeler

on:
  pull_request:
    branches: [main]
    types:
      - opened
      - synchronize
      - reopened
      - labeled
      - unlabeled

jobs:
  pr-labeler:
    name: Label pull requests
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref_name }}
          token: ${{ github.token }}

      - name: Apply non-versioning labels
        id: label-pull-request
        uses: actions/labeler@v5
        with:
          repo-token: ${{ github.token }}

      - name: Check for semantic version labels
        uses: rwaight/actions/github/check-semver-labels@main
        id: check-semver-labels
        with:
          gh-token: ${{ github.token }}
          allow-failure: true
          semver-fallback: 'triage:version-needed'
          semver-prefix: 'version:'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
```

### About `actions/checkout`

The token you use when setting up the repo with this action will determine what token `check-semver-labels` will use.  

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

