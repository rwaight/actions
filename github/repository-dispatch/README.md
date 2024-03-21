# GitHub Repository Dispatch Action

The current version in this repo was based off of [**repository-dispatch** v3.0.0](https://github.com/peter-evans/repository-dispatch/releases/tag/v3.0.0) (specifically [this commit](https://github.com/peter-evans/repository-dispatch/commit/ff45666b9427631e3450c54a1bcbee4d9ff4d7c0))
- This action is from https://github.com/peter-evans/repository-dispatch.


The [`peter-evans/repository-dispatch`](https://github.com/peter-evans/repository-dispatch) has an MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

None at this time.

## Repository Dispatch

A GitHub action to create a repository dispatch event.

## Usage

Dispatch an event to the current repository.
```yml
      - name: Repository Dispatch
        uses: rwaight/actions/github/repository-dispatch@main
        with:
          event-type: my-event
```

Dispatch an event to a remote repository using a `repo` scoped [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
```yml
      - name: Repository Dispatch
        uses: rwaight/actions/github/repository-dispatch@main
        with:
          token: ${{ secrets.PAT }}
          repository: username/my-repo
          event-type: my-event
```

### Action inputs

| Name | Description | Default |
| --- | --- | --- |
| `token` | `GITHUB_TOKEN` (permissions `contents: write`) or a `repo` scoped [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). See [token](#token) for further details. | `GITHUB_TOKEN` |
| `repository` | The full name of the repository to send the dispatch. | `github.repository` (current repository) |
| `event-type` | (**required**) A custom webhook event name. | |
| `client-payload` | JSON payload with extra information about the webhook event that your action or workflow may use. | `{}` |

#### Token

This action creates [`repository_dispatch`](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event) events.
The default `GITHUB_TOKEN` token can only be used if you are dispatching the same repository that the workflow is executing in.

To dispatch to a remote repository you must create a [Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the `repo` scope and store it as a secret.
If you will be dispatching to a public repository then you can use the more limited `public_repo` scope.

You can also use a [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) (beta). It needs the following permissions on the target repositories:
 - `contents: read & write`
 - `metadata: read only` (automatically selected when selecting the contents permission)

## Example

Here is an example setting all of the input parameters.

```yml
      - name: Repository Dispatch
        uses: rwaight/actions/github/repository-dispatch@main
        with:
          token: ${{ secrets.PAT }}
          repository: username/my-repo
          event-type: my-event
          client-payload: '{"ref": "${{ github.ref }}", "sha": "${{ github.sha }}"}'
```

Here is an example `on: repository_dispatch` workflow to receive the event.
Note that repository dispatch events will only trigger a workflow run if the workflow is committed to the default branch.

```yml
name: Repository Dispatch
on:
  repository_dispatch:
    types: [my-event]
jobs:
  myEvent:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.client_payload.ref }}
      - run: echo ${{ github.event.client_payload.sha }}
```

### Dispatch to multiple repositories

You can dispatch to multiple repositories by using a [matrix strategy](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix). In the following example, after the `build` job succeeds, an event is dispatched to three different repositories.

```yml
jobs:
  build:
    # Main workflow job that builds, tests, etc.

  dispatch:
    needs: build
    strategy:
      matrix:
        repo: ['my-org/repo1', 'my-org/repo2', 'my-org/repo3']
    runs-on: ubuntu-latest
    steps:
      - name: Repository Dispatch
        uses: rwaight/actions/github/repository-dispatch@main
        with:
          token: ${{ secrets.PAT }}
          repository: ${{ matrix.repo }}
          event-type: my-event
```

## Client payload

The GitHub API allows a maximum of 10 top-level properties in the `client-payload` JSON.
If you use more than that you will see an error message like the following.

```
No more than 10 properties are allowed; 14 were supplied.
```

For example, this payload will fail because it has more than 10 top-level properties.

```yml
client-payload: ${{ toJson(github) }}
```

To solve this you can simply wrap the payload in a single top-level property.
The following payload will succeed.

```yml
client-payload: '{"github": ${{ toJson(github) }}}'
```

Additionally, there is a limitation on the total data size of the `client-payload`. A very large payload may result in a `client_payload is too large` error.

### Multiline

A multiline `client-payload` can be set directly in YAML, as in the following example.

```yml
      - name: Repository Dispatch
        uses: rwaight/actions/github/repository-dispatch@main
        with:
          token: ${{ secrets.PAT }}
          repository: username/my-repo
          event-type: my-event
          client-payload: |-
            {
              "repo": {
                "name": "${{ github.repository }}",
                "branch": "${{ needs.build_cfg.outputs.REPO_BRANCH }}",
                "tag": "${{ needs.build_cfg.outputs.REPO_TAG }}"
              },
              "deployment": {
                "project": "${{ env.MY_PROJECT }}",
                "container": "${{ env.MY_CONTAINER }}",
                "deploy_msg": "${{ env.SLACK_DEPLOY_MSG }}",
              }
            }
```

## License

[MIT](LICENSE)
