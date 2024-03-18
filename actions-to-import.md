## Future planning - actions to import to this repo

The following actions should be copied/imported to this repo:
- **github**
    - [`peter-evans/repository-dispatch`](https://github.com/peter-evans/repository-dispatch)
    - [`dorny/paths-filter`](https://github.com/dorny/paths-filter)
    - [`imjohnbo/issue-bot` action](https://github.com/imjohnbo/issue-bot)
    - [`imjohnbo/extract-issue-template-fields` action](https://github.com/imjohnbo/extract-issue-template-fields)
    - [`agilepathway/label-checker` action](https://github.com/agilepathway/label-checker)
    - [`c-py/action-dotenv-to-setenv`](https://github.com/c-py/action-dotenv-to-setenv)
    - [`robvanderleek/create-issue-branch` action](https://github.com/robvanderleek/create-issue-branch)
- **utilities**
    - [`imjohnbo/action-to-mermaid`](https://github.com/imjohnbo/action-to-mermaid)
    - [`jakejarvis/s3-sync-action`](https://github.com/jakejarvis/s3-sync-action)

The actions should have their `branding` section updated according to the [update standards](#update-standards-for-imported-actions) listed below.

#### Other actions to review

The following actions should be reviewed as candidates to import to this repo:
- **releases**
    - [`K-Phoen/semver-release-action`](https://github.com/K-Phoen/semver-release-action/)
        - Based on the [`github_tag_and_release.yml`](https://github.com/agilepathway/label-checker/blob/master/.github/workflows/github_tag_and_release.yml) workflow
    - [`phish108/release-check`](https://github.com/phish108/release-check)
    - [`InsonusK/get-latest-release`](https://github.com/InsonusK/get-latest-release)
    - [`cardinalby/git-get-release-action`](https://github.com/cardinalby/git-get-release-action)
- **git**
    - [`mdomke/git-semver`](https://github.com/mdomke/git-semver)
    - [`actions-ecosystem/action-get-latest-tag`](https://github.com/actions-ecosystem/action-get-latest-tag)
    - [`WyriHaximus/github-action-get-previous-tag`](https://github.com/WyriHaximus/github-action-get-previous-tag)
- **github**
    - [`actions-cool/issues-helper`](https://github.com/actions-cool/issues-helper)
    - [`Ismoh-Games/find-linked-issues`](https://github.com/Ismoh-Games/find-linked-issues)
- **utilities**
    - [`EndBug/version-check`](https://github.com/EndBug/version-check)
    - [`technote-space/package-version-check-action`](https://github.com/technote-space/package-version-check-action)


## Update standards for imported actions

Use the code block below to add `branding` to the imported actions.
```yml
branding:
  icon: 'copy'
  color: 'blue'
  # Ref: https://haya14busa.github.io/github-action-brandings/
  # fork: https://github.com/rwaight/github-action-brandings
```
