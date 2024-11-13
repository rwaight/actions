# GitHub Find Pull Request Action

A GitHub Action for finding pull requests.

#### Source Action Information

The current version in this repo was based off of [**find-pull-request-action** v1.9.0](https://github.com/juliangruber/find-pull-request-action/releases/tag/v1.9.0)
- Specifically [this commit](https://github.com/juliangruber/find-pull-request-action/commit/48b6133aa6c826f267ebd33aa2d29470f9d9e7d0)
- This action is from https://github.com/juliangruber/find-pull-request-action

The [`juliangruber/find-pull-request-action`](https://github.com/juliangruber/find-pull-request-action) has an MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

### Updates to the action

None at this time

## Deploying this action

### Usage

```yaml
steps:
  - name: Find Pull Request
    id: find-pull-request
    uses: rwaight/actions/github/find-pull-request@main
    with:
      branch: my-branch-name
      #branch: ${{ github.base_ref || github.event.pull_request.base.ref }}
      repo: my-repo-name

  - name: Report the pull request from the find-pull-request step
    run: echo "Pull Request ${number} (${sha})"
    env:
      number: ${{ steps.find-pull-request.outputs.number }}
      sha: ${{ steps.find-pull-request.outputs.head-sha }}
```

Currently this will find a single open PR based on given `branch` input. For more options please open an issue.

### Inputs

See the [`inputs` section of the `action.yml` file](./action.yml).

### Outputs

See the [`outputs` section of the `action.yml` file](./action.yml).

## Related

- [approve-pull-request-action](https://github.com/juliangruber/approve-pull-request-action) &mdash; Approve a Pull Request
- [merge-pull-request-action](https://github.com/juliangruber/merge-pull-request-action) &mdash; Merge a Pull Request
- [octokit-action](https://github.com/juliangruber/octokit-action) &mdash; Generic Octokit.js Action

## License

MIT
