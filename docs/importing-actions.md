## Update standards for imported actions

**Note**: Once the action has been imported, be sure to [keep the repo README updated](actions-repo-update-readme.md)

### Branding Imported Actions

Use the code block below to add `branding` to the imported actions.
```yml
branding:
  icon: 'copy'
  color: 'blue'
  # Ref: https://haya14busa.github.io/github-action-brandings/
  # fork: https://github.com/rwaight/github-action-brandings
```

### Copying documentation in place

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

### Documentation for imported actions

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

### Update the repo README

Once the action has been imported, be sure to [keep the repo README updated](actions-repo-update-readme.md)
