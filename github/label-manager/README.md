# GitHub Issue Label Manager Action

The current version in this repo is based off of [**issue-label-manager-action** v4.0.0](https://github.com/lannonbr/issue-label-manager-action/releases/tag/4.0.0)
- **Note**: You must use the (classic) personal access tokens when configuring the `GITHUB_TOKEN`
- This action is from https://github.com/lannonbr/issue-label-manager-action.

The [`lannonbr/issue-label-manager-action`](https://github.com/lannonbr/issue-label-manager-action) has a MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

### Important Notice
Consider using the [`rwaight/actions/github/label-sync` action](https://github.com/rwaight/actions/github/tree/main/github/label-sync) before deploying this action.


## Deploying this action

Here is an example to deploy the action:
```
on:
  issues: # You can run this whenever an issue is actioned, but not a great idea
  # You can run this with every event, but it's better to run it only when you actually need it.
  workflow_dispatch:

name: Create Default Labels
jobs:
  labels:
    name: DefaultLabelsActions
    runs-on: ubuntu-latest
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4

      - name: Run the label-manager action
        uses: rwaight/actions/github/label-manager@main # can use version specific or main
        #uses: rwaight/actions/github/label-manager@v1.2.0 # can use version specific or main
        env:
          GITHUB_TOKEN: ${{ secrets.MY_ACTIONS_TOKEN }}
        with:
          #delete: true # will delete any labels that aren't in the .github/labels.json (this is set to false by default)
          delete: false # will delete any labels that aren't in the .github/labels.json (this is set to false by default)
```

### Example labels configuration file

Here is an example `.github/labels.json` file:
```
[
    { "name": "Foobar", "color": "f000ff", "description": "This was updated with GitHub Actions!" },
    { "name": "baz", "color": "000000", "description": "just black" },
    { "name": "Docs", "color": "0000ff", "description": "Documentation label" }
]
```
