## Future planning - actions to import to this repo

The following actions should be copied/imported to this repo:
- **github**
    - [`imjohnbo/issue-bot` action](https://github.com/imjohnbo/issue-bot)
    - [`imjohnbo/extract-issue-template-fields` action](https://github.com/imjohnbo/extract-issue-template-fields)
    - [`c-py/action-dotenv-to-setenv`](https://github.com/c-py/action-dotenv-to-setenv)
    - [`robvanderleek/create-issue-branch` action](https://github.com/robvanderleek/create-issue-branch)
- **releases**
    - [`semantic-release/semantic-release`](https://github.com/semantic-release/semantic-release)
- **utilities**
    - [`imjohnbo/action-to-mermaid`](https://github.com/imjohnbo/action-to-mermaid)
    - [`jakejarvis/s3-sync-action`](https://github.com/jakejarvis/s3-sync-action)

The actions should have their `branding` section updated according to the [update standards](#update-standards-for-imported-actions) listed below.

##### Actions pending import

The following actions are pending import to this repo:
- **git**
    - [`release-flow/keep-a-changelog-action`](https://github.com/release-flow/keep-a-changelog-action)
- **github**
    - [`peter-evans/create-pull-request`](https://github.com/peter-evans/create-pull-request)
- **utilities**
    - None at this time.

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
    - [`WyriHaximus/github-action-next-semvers`](https://github.com/WyriHaximus/github-action-next-semvers)
    - [`phish108/autotag-action`](https://github.com/phish108/autotag-action)
- **github**
    - [`actions-cool/issues-helper`](https://github.com/actions-cool/issues-helper)
    - [`Ismoh-Games/find-linked-issues`](https://github.com/Ismoh-Games/find-linked-issues)
- **utilities**
    - [`EndBug/version-check`](https://github.com/EndBug/version-check)
    - [`technote-space/package-version-check-action`](https://github.com/technote-space/package-version-check-action)


## Update standards for imported actions

#### Updating the README

Keep the README updated with the current list of actions.

<details><summary>commands to list directories (click to expand)</summary>

##### Get the categories from the root directory
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 1 -I '.git|archive|assets|composite|examples|test' --noreport
```

##### Get the actions by category
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|archive|assets|composite|examples|test' --noreport
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
categories=(builders git github releases utilities)

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
categories=(builders git github releases utilities)

# get the action names by category, using tree
for item in ${categories[@]}; do tree $item -d -L 1; done
```

##### Filter out the non-category directories with `tree`
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|archive|assets|composite|examples|test' --noreport
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
