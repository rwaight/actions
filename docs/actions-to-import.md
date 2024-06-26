# Actions to import

An attempt to keep track of what actions should be imported into this monorepo.

## Future planning - actions to import to this repo

The following actions should be copied/imported to this repo:
- **builders**
    - None at this time.
- **chatops**
    - See https://www.pagerduty.com/blog/what-is-chatops/
    - [`peter-evans/slash-command-dispatch`](https://github.com/peter-evans/slash-command-dispatch)
        - A GitHub action that facilitates "ChatOps" by creating repository dispatch events for slash commands
    - [`peter-evans/slash-command-dispatch-processor`](https://github.com/peter-evans/slash-command-dispatch-processor)
        - A command processor for slash-command-dispatch, a GitHub action that facilitates "ChatOps"
- **git**
    - None at this time.
- **github**
    - [`imjohnbo/issue-bot` action](https://github.com/imjohnbo/issue-bot)
        - GitHub Actions powered Issue Bot
    - [`imjohnbo/extract-issue-template-fields` action](https://github.com/imjohnbo/extract-issue-template-fields)
        - Extract issue template fields with GitHub Actions
    - [`robvanderleek/create-issue-branch` action](https://github.com/robvanderleek/create-issue-branch)
        - GitHub App/Action that automates the creation of issue branches
- **releases**
    - None at this time.
- **utilities**
    - [`DamianReeves/write-file-action`](https://github.com/DamianReeves/write-file-action)
        - A GitHub action to write a file
        - Use case: overwrite, append, or preserve files
    - [`c-py/action-dotenv-to-setenv`](https://github.com/c-py/action-dotenv-to-setenv)
        - GitHub Action to export a dotenv file to environment variables (via set-env)
    - [`imjohnbo/action-to-mermaid`](https://github.com/imjohnbo/action-to-mermaid)
        - GitHub action that generates a Mermaid diagram out of an action's metadata file
    - [`jakejarvis/s3-sync-action`](https://github.com/jakejarvis/s3-sync-action)
        - GitHub Action to sync a directory with a remote S3 bucket

The actions should have their `branding` section updated according to the [update standards](#update-standards-for-imported-actions) listed below.

## Actions pending import

The following actions are pending import to this repo:
- **builders**
    - None at this time.
- **chatops**
    - None at this time.
- **git**
    - None at this time.
- **github**
    - None at this time.
- **releases**
    - None at this time.
- **utilities**
    - None at this time.

## Other actions to review

The following actions should be reviewed as candidates to import to this repo:
- **builders**
    - None at this time.
- **chatops**
    - None at this time.
- **git**
    - [`stefanzweifel/git-auto-commit-action`](https://github.com/stefanzweifel/git-auto-commit-action)
        - Automatically commit and push changed files back to GitHub with this GitHub Action for the 80% use case.
    - [`mdomke/git-semver`](https://github.com/mdomke/git-semver)
        - Semantic Versioning with git tags
    - [`peter-evans/rebase`](https://github.com/peter-evans/rebase)
        - A GitHub action to rebase pull requests in a repository
    - [`actions-ecosystem/action-get-latest-tag`](https://github.com/actions-ecosystem/action-get-latest-tag)
        - GitHub Action to get a latest Git tag
    - [`WyriHaximus/github-action-get-previous-tag`](https://github.com/WyriHaximus/github-action-get-previous-tag)
        - Get the previous tag
    - [`WyriHaximus/github-action-next-semvers`](https://github.com/WyriHaximus/github-action-next-semvers)
        - Github Action that output the next version for major, minor, and patch version based on the given semver version.
    - [`phish108/autotag-action`](https://github.com/phish108/autotag-action)
        - A lightning fast autotagger for semver tagging in github actions
    - [`codedesignplus/semver-git-version`](https://github.com/codedesignplus/semver-git-version)
        - Semver versioning based on the git history and commit messages of your repository.
    - [`auguwu/git-tag-action`](https://github.com/auguwu/git-tag-action)
        - GitHub action to split your Git release tag into SemVer 2.0 parts
- **github**
    - [`actions-cool/issues-helper`](https://github.com/actions-cool/issues-helper)
        - A GitHub Action easily helps you automatically manage issues.
    - [`Ismoh-Games/find-linked-issues`](https://github.com/Ismoh-Games/find-linked-issues)
        - Marketplace action for finding the linked issues of a pull request.
    - [`peter-evans/enable-pull-request-automerge`](https://github.com/peter-evans/enable-pull-request-automerge)
        - A GitHub action to enable auto-merge on a pull request
        - **NOTE** same functionality exists in the GitHub CLI. See the [`gh pr merge` documentation](https://cli.github.com/manual/gh_pr_merge)
        ```yml
            - name: Enable Pull Request Automerge
              run: gh pr merge --merge --auto "1"
              env:
                GH_TOKEN: ${{ secrets.PAT }}
        ```
- **releases**
    - [`huggingface/semver-release-action`](https://github.com/huggingface/semver-release-action)
        - Github Action to release projects using Semantic Release.
        - Uses [`semantic-release/semantic-release`](https://github.com/semantic-release/semantic-release)
    - [`K-Phoen/semver-release-action`](https://github.com/K-Phoen/semver-release-action/)
        - GitHub Action to automatically create SemVer compliant releases based on PR labels.
        - Based on the [`github_tag_and_release.yml`](https://github.com/agilepathway/label-checker/blob/master/.github/workflows/github_tag_and_release.yml) workflow
    - [`phish108/release-check`](https://github.com/phish108/release-check)
        - Check if a push or pull request should trigger a release.
    - [`InsonusK/get-latest-release`](https://github.com/InsonusK/get-latest-release)
        - Get latest release, include all types of release
    - [`cardinalby/git-get-release-action`](https://github.com/cardinalby/git-get-release-action)
        - Github Action that allows you to get release information by release id, tag, commit SHA (current commit or specified).
- **utilities**
    - [`peter-evans/ghaction-import-gpg`](https://github.com/peter-evans/ghaction-import-gpg)
        - GitHub Action to import a GPG key
    - [`EndBug/version-check`](https://github.com/EndBug/version-check)
        - An action that allows you to check whether your npm package version has been updated
    - [`technote-space/package-version-check-action`](https://github.com/technote-space/package-version-check-action)
        - GitHub Actions to check package version before publish
    - [`antifree/json-to-variables`](https://github.com/antifree/json-to-variables)
        - GitHub action reads JSON file and writes its content as environment variables.
    - [`tomwhross/write-good-action`](https://github.com/tomwhross/write-good-action)
        - A Markdown prose linting action based on [`write-good`](https://github.com/btford/write-good)



## Reviewed actions

This section should contain the actions that have been reviewed and status.

#### Tracking Table Legend

<details><summary> Legend for tracking imports (click to expand) </summary>

#### Legend
We can use emoji and reference an [emoji cheat sheet](https://github.com/ikatyang/emoji-cheat-sheet) ([punctuation link](https://github.com/ikatyang/emoji-cheat-sheet#punctuation)).

| Icon | Description |
|:----:|:-----------:|
| :white_check_mark: | Imported |
| :large_orange_diamond: | Partially imported |
| :exclamation: | Update is needed |
| :grey_question: | Under review |
| :grey_exclamation: | Review needed |
| :x: | Not selected for import, <br/> needs a comment |
| :wavy_dash: | Not applicable |
| :coffee: | Created in this repo |

</details>

### Reviewed actions by category

- **builders**
    - `set-version` :coffee:
        - Determine a **build version** using `git describe`.
        - Source: Created within this repo.
- **chatops**
    - `create-or-update-comment` :white_check_mark:
        - Create or update an issue or pull request comment.
        - Source: [`peter-evans/create-or-update-comment`](https://github.com/peter-evans/create-or-update-comment)
    - `find-comment` :white_check_mark:
        - Find an issue or pull request comment.
        - Source: [`peter-evans/find-comment`](https://github.com/peter-evans/find-comment)
- **git**
    - `add-and-commit` :white_check_mark:
        - Commit changes made in your workflow run directly to your repo: for example, you use it to lint your code, update documentation, commit updated builds, etc...
        - Source: [`EndBug/add-and-commit`](https://github.com/EndBug/add-and-commit)
    - `git-describe-semver` :white_check_mark:
        - Replacement for `git describe --tags` that produces [semver](https://semver.org/) compatible versions that follow to semver sorting rules.
        - Source: [`choffmeister/git-describe-semver`](https://github.com/choffmeister/git-describe-semver/)
    - `keep-a-changelog-action` :white_check_mark:
        - A GitHub Action that performs various operations on changelogs that adhere to [keep-a-changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/) conventions.
        - Source: [`release-flow/keep-a-changelog-action`](https://github.com/release-flow/keep-a-changelog-action)
    - `repo-version-info` :coffee:
        - Provide version information from a git repo
        - Source: Created within this repo.
    - `semver-git-version` :white_check_mark:
        - Semver versioning based on the git history and commit messages of your repository.
        - Source: [`codedesignplus/semver-git-version`](https://github.com/codedesignplus/semver-git-version)
- **github**
    - This section needs to be updated.
    - `create-pull-request` :white_check_mark:
        - Create a pull request for changes to your repository in the actions workspace.
        - Source: [`peter-evans/create-pull-request`](https://github.com/peter-evans/create-pull-request)
    - `export-label-config` :exclamation:
        - description
        - Source: 
    - `find-pull-request` :exclamation:
        - description
        - Source: 
    - `github-changelog-generator` :exclamation:
        - description
        - Source: 
    - `issue-triage` :exclamation:
        - description
        - Source: 
    - `label-checker` :white_check_mark:
        - Check pull requests (PRs) for the presence or absence of specified labels
        - Source: [`agilepathway/label-checker`](https://github.com/agilepathway/label-checker)
    - `label-manager` :exclamation:
        - description
        - Source: 
    - `label-sync` :exclamation:
        - description
        - Source: 
    - `projectnext-label-assigner` :exclamation:
        - description
        - Source: 
    - `repository-dispatch` :white_check_mark:
        - A GitHub action to create a repository dispatch event.
        - Source: [`peter-evans/repository-dispatch`](https://github.com/peter-evans/repository-dispatch)
    - `semantic-pull-request` :white_check_mark:
        - Ensure that your pull request titles match the [Conventional Commits spec](https://www.conventionalcommits.org/).
        - Source: [`amannn/action-semantic-pull-request`](https://github.com/amannn/action-semantic-pull-request)
- **releases**
    - This section needs to be updated.
    - `release-drafter` :exclamation:
        - description
        - Source: 
    - `release-tag-updater` :exclamation:
        - description
        - Source: 
    - `semantic-release` :white_check_mark:
        - GitHub Action for Semantic Release
        - Uses [`semantic-release/semantic-release`](https://github.com/semantic-release/semantic-release)
        - Source: [`cycjimmy/semantic-release-action`](https://github.com/cycjimmy/semantic-release-action)
- **utilities**
    - This section needs to be updated.
    - `copycat` :exclamation:
        - description
        - Source: 
    - `packer` :exclamation:
        - description
        - Source: 
    - `paths-filter` :white_check_mark:
        - Enables conditional execution of workflow steps and jobs, based on the files modified by pull request, on a feature branch, or by the recently pushed commits.
        - Source: [`dorny/paths-filter`](https://github.com/dorny/paths-filter)
    - `public-ip` :exclamation:
        - description
        - Source: 
    - `render-template` :exclamation:
        - description
        - Source: 

##### Template for entries in this section

```
    - `name` :exclamation:
        - description
        - Source: 
```

## Created Actions

This section contains the actions that have been created within this repo and have been moved out of testing.

- **builders**
    - [`rwaight/actions` set-version](https://github.com/rwaight/actions/blob/main/builders/set-version) :coffee:
- **git**
    - [`rwaight/actions` repo-version-info](https://github.com/rwaight/actions/blob/main/git/repo-version-info) :coffee:

