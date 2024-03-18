# GitHub Copycat Action

The current version in this repo is based off of [**copycat-action** v3.2.4](https://github.com/andstor/copycat-action/releases/tag/v3.2.4)
- **Note**: You must use the (classic) personal access tokens when configuring the `personal_token`
- This action is from https://github.com/andstor/copycat-action/.

The [`andstor/copycat-action`](https://github.com/andstor/copycat-action/) has a MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.


## Deploying this action

### Example with markdown files

In a separate repo, create a file named `.github/workflows/copy-markdown-to-remote.yml` with the following:
```
name: Copy markdown files to remote

on:
  push:
    # only when changes are pushed to main
    branches:
      - main
    paths:
      - '**.md'
      - 'docs/**'
      - '!**.yml'
      - '!**.json'
      - '!.github/**'
  workflow_dispatch:

env:
  my_identifier: "custom-cool-code-repo"

jobs:
  copycat:
    runs-on: ubuntu-22.04
    
    name: Run my-copycat-action
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4
      
      - name: Print the name of the branch
        run: echo running on branch ${GITHUB_REF##*/}

      - name: Run my custom copycat action
        #uses: rwaight/actions/utilities/copycat@main # can set to main or specific version
        uses: rwaight/actions/utilities/copycat@v1.0.0
        id: copycat
        # see https://github.com/rwaight/actions/blob/main/utilities/copycat/copycat_README.md for more detail
        with:
          #github-token: ${{ secrets.MY_COPYCAT_TOKEN }}
          # currently only supports the (classic) personal access tokens
          personal_token: ${{ secrets.MY_COPYCAT_TOKEN }}
          file_filter: '*.md'
          exclude: '.github/*'
          src_path: /.
          src_branch: main
          dst_path: /copycat/${{ env.my_identifier }}/
          dst_branch: copycat-markdown
          dst_owner: another-github-username
          dst_repo_name: my-other-repo-name
          username: another-github-username
          email: 8675309+another-github-username@users.noreply.github.com
          commit_message: "markdown file copies from the ${{ env.my_identifier }} repo"

```
