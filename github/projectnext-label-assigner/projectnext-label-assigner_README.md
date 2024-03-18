# GitHub ProjectV2 issue assigner action

**Update 2022-08-07**: GitHub Projects Beta is now [generally available](https://github.blog/changelog/2022-06-23-the-new-github-issues-june-23rd-update/) and referred to as ProjectsV2 in the API reference. This action is now updated to use the ProjectsV2 API.

This action operates on the new [GitHub Projects](https://docs.github.com/en/issues/trying-out-the-new-projects-experience/about-projects).

This action does not work on legacy GitHub projects.

This action:
  - Assigns an issue or pull request to a project when a specified label is applied
  - Removes an issue from a project when a specified label is removed. Note that Pull Requests aren't supported yet (it's possible to implement, I simply haven't needed this capability myself).

You can provide multiple label to project mappings as the action input.

## Example usage

In order to use this action, create a workflow configuration file (e.g. `projectv2-workflow.yml`) in your repository's `.github/workflows` directory. *Note that you need to have GitHub Actions enabled for your repository in order for this to work!*

### A workflow configuration for assigning issues to projects

See [examples/projectv2-workflow.yml](examples/projectv2-workflow.yml).

### GitHub Token

Specify a secret GitHub API token with access to read/write issues, PRs, and project cards for the target project and repo.

The `GITHUB_TOKEN` secret is available by default on all action environments. This token has sufficient permissions to add and remove cards from any projects within the issue or PR's own repository.

Or generate an API token with additional privileges under https://github.com/settings/tokens. Store the secret in the workflow repository's secrets as `PAT_TOKEN` and it will take precedence over the `GITHUB_TOKEN` when the action runs. See `https://github.com/$ORG/$REPO/settings/secrets/actions`.

## Development

To make changes to this action's source code, fork this repository and make any edits you need.

Rebuild the `dist/index.js` file to include all packages by running:
```
npm run build
```

If you are pushing many changes to your own fork and testing iteratively, your workflow yml file can specify a particular branch or commit of this action, e.g. `richkuz/projectnext-label-assigner@main`.

GitHub's [GraphQL Explorer](https://docs.github.com/en/graphql/overview/explorer) helps when debugging queries.

See the [GraphQL example queries](examples/example-queries.md) for full example requests and responses using the GitHub Projects APIs.

### Testing

#### Unit testing
```
npm test
```
