# GitHub approve-pull-request Action

The current version in this repo was based off of [**approve-pull-request-action** v2.0.6](https://github.com/juliangruber/approve-pull-request-action/releases/tag/v2.0.6)
- Specifically [this commit](https://github.com/juliangruber/approve-pull-request-action/commit/b71c44ff142895ba07fad34389f1938a4e8ee7b0)
- This action is from https://github.com/juliangruber/approve-pull-request-action


The [`juliangruber/approve-pull-request-action`](https://github.com/juliangruber/approve-pull-request-action) has an MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

None at this time.

## approve-pull-request action

A GitHub Action for approving pull requests.

## Inputs

See the `inputs` section in the [action.yml](./action.yml) file.

## Outputs

None

## Deploying this action

Example in a workflow:
```yaml
    steps:
      - name: Approve Pull Request
        id: approve-pr
        uses: rwaight/actions/github/approve-pull-request@main
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          #number: ${{ github.event.pull_request.number }}
          number: 1
          repo: rwaight/actions  # optional
```

## Related

- [find-pull-request-action](https://github.com/juliangruber/find-pull-request-action) &mdash; Find a Pull Request
- [merge-pull-request-action](https://github.com/juliangruber/merge-pull-request-action) &mdash; Merge a Pull Request
- [octokit-action](https://github.com/juliangruber/octokit-action) &mdash; Generic Octokit.js Action

## License

MIT
