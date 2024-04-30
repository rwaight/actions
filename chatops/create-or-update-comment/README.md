# GitHub Create or Update Comment Action

The current version in this repo was based off of [**create-or-update-comment** commit `a6e9cd3`](https://github.com/peter-evans/create-or-update-comment/commit/a6e9cd36f51df4b62eda17117243a51ea193c133) (newer than [version 3.1.0](https://github.com/peter-evans/create-or-update-comment/releases/tag/v3.1.0))
- This action is from https://github.com/peter-evans/create-or-update-comment.

The [`peter-evans/create-or-update-comment`](https://github.com/peter-evans/create-or-update-comment) code has an MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Create or Update Comment

A GitHub action to create or update an issue or pull request comment.

## Usage

### Add a comment to an issue or pull request

```yml
      - name: Create comment
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          issue-number: 1
          body: |
            This is a multi-line test comment
            - With GitHub **Markdown** :sparkles:
            - Created by [create-or-update-comment][1]

            [1]: https://github.com/rwaight/actions/tree/main/github/create-or-update-comment
          reactions: '+1'
```

### Update a comment

```yml
      - name: Update comment
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          comment-id: 008675309
          body: |
            **Edit:** Some additional info
          reactions: eyes
```

### Add comment reactions

```yml
      - name: Add reactions
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          comment-id: 008675309
          reactions: |
            heart
            hooray
            laugh
```

### Action inputs

| Name | Description | Default |
| --- | --- | --- |
| `token` | `GITHUB_TOKEN` (`issues: write`, `pull-requests: write`) or a `repo` scoped [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). | `GITHUB_TOKEN` |
| `repository` | The full name of the repository in which to create or update a comment. | Current repository |
| `issue-number` | The number of the issue or pull request in which to create a comment. | |
| `comment-id` | The id of the comment to update. | |
| `body` | The comment body. Cannot be used in conjunction with `body-path`. | |
| `body-path` | The path to a file containing the comment body. Cannot be used in conjunction with `body`. | |
| `edit-mode` | The mode when updating a comment, `replace` or `append`. | `append` |
| `append-separator` | The separator to use when appending to an existing comment. (`newline`, `space`, `none`) | `newline` |
| `reactions` | A comma or newline separated list of reactions to add to the comment. (`+1`, `-1`, `laugh`, `confused`, `heart`, `hooray`, `rocket`, `eyes`) | |
| `reactions-edit-mode` | The mode when updating comment reactions, `replace` or `append`. | `append` |

Note: In *public* repositories this action does not work in `pull_request` workflows when triggered by forks.
Any attempt will be met with the error, `Resource not accessible by integration`.
This is due to token restrictions put in place by GitHub Actions. Private repositories can be configured to [enable workflows](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#enabling-workflows-for-forks-of-private-repositories) from forks to run without restriction. See [here (in the `peter-evans/create-pull-request` repo)](https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#restrictions-on-repository-forks) for further explanation. Alternatively, use the [`pull_request_target`](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request_target) event to comment on pull requests.

#### Outputs

The ID of the created comment will be output for use in later steps.
Note that in order to read the step output the action step must have an id.

```yml
      - name: Create comment
        uses: rwaight/actions/github/create-or-update-comment@main
        id: couc
        with:
          issue-number: 1
          body: |
            My comment
      - name: Check outputs
        run: |
          echo "Comment ID - ${{ steps.couc.outputs.comment-id }}"
```

### Where to find the id of a comment

How to find the id of a comment will depend a lot on the use case.
Here is one example where the id can be found in the `github` context during an `issue_comment` event.

```yml
on:
  issue_comment:
    types: [created]
jobs:
  commentCreated:
    runs-on: ubuntu-latest
    steps:
      - name: Add reaction
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          comment-id: ${{ github.event.comment.id }}
          reactions: eyes
```

Some use cases might find the [find-comment](https://github.com/rwaight/actions/tree/main/github/find-comment) action useful.
This will search an issue or pull request for the first comment containing a specified string, and/or by a specified author.
See the repository for detailed usage.

In the following example, find-comment is used to determine if a comment has already been created on a pull request.
If the find-comment action output `comment-id` returns an empty string, a new comment will be created.
If it returns a value, the comment already exists and the content is replaced.
```yml
    - name: Find Comment
      uses: rwaight/actions/github/find-comment@v2
      id: fc
      with:
        issue-number: ${{ github.event.pull_request.number }}
        comment-author: 'github-actions[bot]'
        body-includes: Build output

    - name: Create or update comment
      uses: rwaight/actions/github/create-or-update-comment@main
      with:
        comment-id: ${{ steps.fc.outputs.comment-id }}
        issue-number: ${{ github.event.pull_request.number }}
        body: |
          Build output
          ${{ steps.build.outputs.build-log }}
        edit-mode: replace
```

If required, the create and update steps can be separated for greater control.
```yml
    - name: Find Comment
      uses: rwaight/actions/github/find-comment@v2
      id: fc
      with:
        issue-number: ${{ github.event.pull_request.number }}
        comment-author: 'github-actions[bot]'
        body-includes: This comment was written by a bot!

    - name: Create comment
      if: steps.fc.outputs.comment-id == ''
      uses: rwaight/actions/github/create-or-update-comment@main
      with:
        issue-number: ${{ github.event.pull_request.number }}
        body: |
          This comment was written by a bot!
        reactions: rocket

    - name: Update comment
      if: steps.fc.outputs.comment-id != ''
      uses: rwaight/actions/github/create-or-update-comment@main
      with:
        comment-id: ${{ steps.fc.outputs.comment-id }}
        body: |
          This comment has been updated!
        reactions: hooray
```

### Setting the comment body from a file

```yml
      - name: Create comment
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          issue-number: 1
          body-path: 'comment-body.md'
```

### Using a markdown template

In this example, a markdown template file is added to the repository at `.github/comment-template.md` with the following content.
```
This is a test comment template
Render template variables such as {{ .foo }} and {{ .bar }}.
```

The template is rendered using the [render-template](https://github.com/chuhlomin/render-template) action and the result is used to create the comment.
```yml
      - name: Render template
        id: template
        uses: chuhlomin/render-template@v1.4
        with:
          template: .github/comment-template.md
          vars: |
            foo: this
            bar: that

      - name: Create comment
        uses: rwaight/actions/github/create-or-update-comment@main
        with:
          issue-number: 1
          body: ${{ steps.template.outputs.result }}
```

### Accessing issues and comments in other repositories

You can create and update comments in another repository by using a [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) instead of `GITHUB_TOKEN`.
The user associated with the PAT must have write access to the repository.

## License

[MIT](LICENSE)
