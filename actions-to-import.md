## Future planning - actions to import to this repo

The following actions should be copied/imported to this repo:
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
    - [`cycjimmy/semantic-release-action`](https://github.com/cycjimmy/semantic-release-action)
        - GitHub Action for Semantic Release
        - Uses [`semantic-release/semantic-release`](https://github.com/semantic-release/semantic-release)
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

##### Actions pending import

The following actions are pending import to this repo:
- **chatops**
    - None at this time.
- **git**
    - [`codedesignplus/semver-git-version`](https://github.com/codedesignplus/semver-git-version)
    - [`WyriHaximus/github-action-next-semvers`](https://github.com/WyriHaximus/github-action-next-semvers)
    - [`WyriHaximus/github-action-get-previous-tag`](https://github.com/WyriHaximus/github-action-get-previous-tag)
- **github**
    - None at this time.
- **releases**
    - None at this time.
- **utilities**
    - None at this time.

#### Other actions to review

The following actions should be reviewed as candidates to import to this repo:
- **chatops**
    - None at this time.
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


## Update standards for imported actions

#### Updating the README

Keep the README updated with the current list of actions.

<details><summary>commands to list directories (click to expand)</summary>

##### Get the categories from the root directory
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 1 -I '.git|.github|archive|assets|composite|examples|test' --noreport
```

##### Get the actions by category
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|.github|archive|assets|composite|examples|test' --noreport
```


##### Get the top two levels of directories from the root directory of the repo
```bash
# two levels of directories, using find
find . -type d -maxdepth 2

# two levels of directories, using tree
tree . -d -L 2

# two levels of directories, using tree, without the report
tree . -d -L 2 --noreport
```

##### Get the directories by category with `find`
```bash
# store the categories into an array to use in a for loop
categories=(builders chatops git github releases utilities)

# get the action names by category, using find
for item in ${categories[@]}; do find $item -type d -maxdepth 1; done

# not fancy way, using cut, to get the action names below their category
for item in ${categories[@]}; do find $item -type d -maxdepth 1 | cut -d'/' -f2-; done

# similar to above, but with sed
for item in ${categories[@]}; do find $item -type d -maxdepth 1 | sed 's,^[^/]*/,,'; done
```

##### Get the directories by category with `tree`
```bash
# store the categories into an array to use in a for loop
categories=(builders chatops git github releases utilities)

# get the action names by category, using tree
for item in ${categories[@]}; do tree $item -d -L 1; done
```

##### Filter out the non-category directories with `tree`
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|.github|archive|assets|composite|examples|test' --noreport
```

</details>


#### Branding Imported Actions

Use the code block below to add `branding` to the imported actions.
```yml
branding:
  icon: 'copy'
  color: 'blue'
  # Ref: https://haya14busa.github.io/github-action-brandings/
  # fork: https://github.com/rwaight/github-action-brandings
```

#### Copying documentation in place

When importing a new action, `cd` into the directory then run the following commands to keep an original copy of specific files:
```bash
import=example-action
# cd into the directory
cd $import
# rename the '.github' directory
mv .github __dot_github
# copy and rename the '.md' file(s)
for f in *.md; do cp "$f" "${import}__$f"; done
# copy and rename the '.yml' file(s)
for f in *.yml; do cp "$f" "${import}__$f"; done
```

#### Documentation for imported actions

The source actions repository README should be **renamed** to `<reponame>__README.md` and a new README should be created, using the following as a template:
````markdown
# GitHub ACTION_TITLE Action

The current version in this repo was based off of [**REPO_NAME_ONLY** RELEASE_TAG_VERSION_HERE](https://github.com/REPO_OWNER_SLASH_REPO_NAME/releases/tag/RELEASE_TAG_VERSION_HERE)
- for specific commits, include the following _after_ the tag link: `(specifically [this commit](https://github.com/REPO_OWNER_SLASH_REPO_NAME/commit/HASH_OF_UNIQUE_COMMIT_IN_SOURCE_REPO))`
- This action is from https://github.com/REPO_OWNER_SLASH_REPO_NAME.


The [`REPO_OWNER_SLASH_REPO_NAME`](https://github.com/REPO_OWNER_SLASH_REPO_NAME) has a (an) LICENSE_NAME_HERE:
> LICENSE_SUMMARY_TEXT_HERE

## Updates to the action

None at this time.

## ACTION_TITLE action

ACTION_SUMMARY_DESCRIPTION_HERE

## Inputs

ACTION_INPUTS_SUMMARY_HERE

## Outputs

ACTION_OUTPUTS_SUMMARY_HERE

## Deploying this action

Example workflow:
```yml
name: EXAMPLE_WORKFLOW_NAME_HERE
run-name: EXAMPLE_WORKFLOW_RUN_NAME_HERE

on:
  push:
    branches:
        - 'main'

jobs:
  EXAMPLE_JOB_NAME:
    runs-on: ubuntu-latest

    steps:
      - name: EXAMPLE_STEP_WITH_ACTION
        id: example_step_id
        #uses: rwaight/actions/ACTION_CATEGORY/ACTION_DIRECTORY@main # can use version specific or main
        uses: rwaight/actions/ACTION_CATEGORY/ACTION_DIRECTORY@v1

```

````
