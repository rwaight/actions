# Update JSON Field Action

Update a field to a custom value in a JSON file.

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `inputs` configured in the [action.yml](action.yml) file.


## Example Usage


### Update the value in a JSON file

Create a file named `.github/workflows/update-json-field.yml` with the following:
```
name: Update JSON field
run-name: Update JSON field on branch ${{ github.ref_name }}

on:
  workflow_dispatch:
    inputs:
      my-custom-notes:
        description: 'custom note to update'
        default: for-science
        required: false

jobs:
  update-json-field:
    runs-on: ubuntu-latest
    name: Update JSON field
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

      - name: Update the JSON field
        id: update-json-field
        uses: rwaight/actions/test/update-json-field@main
        with:
          json-file: 'my-json-file.json'
          vars-field: 'my-custom-field'
          #vars-new-value: 'my-new-value'
          vars-new-value: ${{ inputs.my-custom-notes || 'my-fallback-value' }}
          action-verbose: true

      - name: Report the output from the update-json-field step
        if: ${{ steps.update-json-field.outputs.new-value }}
        run: |
          echo "The output from the 'update-json-field' step was: "
          echo "previous value: ${{ env.previous-value }} "
          echo "new value     : ${{ env.new-value }} "
        env:
          previous-value: ${{ steps.update-json-field.outputs.previous-value }}
          new-value: ${{ steps.update-json-field.outputs.new-value }}

      - name: Fail if the 'update-json-field' step did not output the new value
        if: ${{ ! steps.update-json-field.outputs.new-value }}
        # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message
        run: |
          echo "::error title=⛔ error in the 'update-json-field' step hint::Updated JSON field value was not provided"
          exit 1

```

## About `actions/checkout`

The token you use when setting up the repo with this action will determine what token `update-json-field` will use.  

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

