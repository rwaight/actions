# Configure GitHub CLI Action

Configure the GitHub CLI using either a GitHub App (`bot`) or a GitHub User Account (`user`).

#### GitHub [`steps` context](https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context)

Important note about the GitHub Actions [`steps` context](https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context):

> `steps.<step_id>.conclusion`. The result of a completed step after [`continue-on-error`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) is applied. Possible values are `success`, `failure`, `cancelled`, or `skipped`. When a `continue-on-error` step fails, the outcome is `failure`, but the final conclusion is `success`.
> 
> `steps.<step id>.outcome` The result of a completed step before [`continue-on-error`](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) is applied. Possible values are `success`, `failure`, `cancelled`, or `skipped`. When a `continue-on-error` step fails, the outcome is `failure`, but the final conclusion is `success`.


## Deploying this action

See the [examples README](README-examples.md) for usage examples.

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.
