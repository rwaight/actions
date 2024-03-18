# GitHub Find Comment Action

The current version in this repo was based off of [**find-comment** commit `d362b58`](https://github.com/peter-evans/find-comment/commit/d362b58d73ad53d089dd54460397ec1b8b47dbfd) (newer than [version 2.4.0](https://github.com/peter-evans/find-comment/releases/tag/v2.4.0))
- This action is from https://github.com/peter-evans/find-comment.

The [`peter-evans/find-comment`](https://github.com/peter-evans/find-comment) code has an MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Find Comment

A GitHub action to find an issue or pull request comment.

The action will output the comment ID of the comment matching the search criteria.

## Usage

### Find the first comment for a specific GitHub issue

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          comment-author: 'github-actions[bot]'
```

### Find the first comment containing the specified string

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          body-includes: search string 1
```

### Find the first comment by the specified author

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          comment-author: my-custom-bot
```

### Find the first comment by the github-actions bot
```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          comment-author: 'github-actions[bot]'
```

### Find the first comment containing the specified string AND by the specified author

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          #issue-number: 1
          issue-number: ${{ github.event.number }}
          comment-author: my-custom-bot
          body-includes: search string 1
```

### Find the first comment matching the specified regular expression

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          body-regex: '^.*search string 1.*$'
```

### Find the last comment containing the specified string

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          body-includes: search string 1
          direction: last
```

### Find the nth comment containing the specified string

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: ${{ github.event.number }}
          body-includes: search string 1
          nth: 1 # second matching comment (0-indexed)
```

### Action inputs

| Name | Description | Default |
| --- | --- | --- |
| `token` | `GITHUB_TOKEN` or a `repo` scoped [PAT](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token). | `GITHUB_TOKEN` |
| `repository` | The full name of the repository containing the issue or pull request. | `github.repository` (Current repository) |
| `issue-number` | The number of the issue or pull request in which to search. | |
| `comment-author` | The GitHub user name of the comment author. | |
| `body-includes` | A string to search for in the body of comments. | |
| `body-regex` | A regular expression to search for in the body of comments. | |
| `direction` | Search direction, specified as `first` or `last` | `first` |
| `nth` | 0-indexed number, specifying which comment to return if multiple are found | 0 |

#### Outputs

The `comment-id`, `comment-body`, `comment-author` and `comment-created-at` of the matching comment found will be output for use in later steps.
They will be empty strings if no matching comment was found.
Note that in order to read the step outputs the action step must have an id.

Tip: Empty strings evaluate to zero in GitHub Actions expressions.
e.g. If `comment-id` is an empty string `steps.fc.outputs.comment-id == 0` evaluates to `true`.

```yml
      - name: Find Comment
        uses: rwaight/actions/github/find-comment@main
        id: fc
        with:
          issue-number: 1
          body-includes: search string 1
      - run: |
          echo ${{ steps.fc.outputs.comment-id }}
          echo ${{ steps.fc.outputs.comment-body }}
          echo ${{ steps.fc.outputs.comment-author }}
          echo ${{ steps.fc.outputs.comment-created-at }}
```

### Accessing issues and pull requests in other repositories

You can search the comments of issues and pull requests in another repository by using a [PAT](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) instead of `GITHUB_TOKEN`.

## License

[MIT](LICENSE)
