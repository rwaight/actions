# Autorelease Process

### About the autorelease process

The goal of autorelease process is to reduce time spent on the overall "release" process.  This includes, but is not limited to: code changes; software updates; deploying new containers or images; deploying updated templates and files; reviewing and verifying built applications, artifacts, images, tools, etc.

### Process Overview

The "autorelease process" currently exists as 5 steps, with _hopefully minimal_ time spent on the actual "release".

### Inputs and outputs

this section is incomplete

## Autorelease Reusable Workflows

The autorelease process currently leverages [GitHub's reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows).
- Future state is that **most** of the actual jobs below would become _composite GitHub Actions_ that are called by the reusable workflows.
- There is a [limitation that subdirectories are not supported for reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows#creating-a-reusable-workflow)
    - See https://github.com/orgs/community/discussions/15935
    > Reusable workflows are YAML-formatted files, very similar to any other workflow file. As with other workflow files, you locate reusable workflows in the `.github/workflows` directory of a repository. Subdirectories of the `workflows` directory are not supported.

The numbering for autorelease workflows should be as follows

### Step 1

The process starts when the user runs the **Autorelease - prepare release PR** workflow
- For repos without builds, this should be the `autorelease-01-prep-pr` workflow file
- For repos **with** builds, this should be the `autorelease-01-prep-build` workflow file

#### 01. prepare-release

Check inputs, get next version, determine next steps
- for repos with packer, this is called from 'prep-build'?

1. check the user inputs             (tbd???)
2. get the next version              (reuse-next-version)
3. determine the next step for inputs and outputs... (tbd???)

#### 02. prep-build

**if applicable**

1. validate the reviewed image ID    (reuse-verify-reviewed-image)
2. call 'test-build'
3. gather build results
4. send results to 'prepare-pr'

#### 03. prepare-pr

this job is the last part of the "first step" for the **autorelease process**

1. prepare the release items    (prepare-pr)
    - prepare and create the initial release draft
    - prepare and create the release pull request
2. print the prepare-release outputs
3. (wish-list item) update the repo changelog
    - for repos with builds, this would also update the "build log"
4. (wish-list item) check to make sure no other PRs are opened (or pushes to the default branch)
    - it would probably be part of this job... and would **auto-close the release pull request**, since a change was made??

### Step 2

The process starts when the **release pull request is merged into the default branch**
- For all repos, this should be the `autorelease-02-pr-merged` workflow file

#### 04. pr-merged

1. get the version from the autorelease branch;                             (check-autorelease-branch)    ## done
2. get the version, type, and reviewed image id from the JSON_VARS_FILE;    (check-json-file)             ## done
3. get the commit SHA's from the merged pull request;                       (check-commit-sha)            ## done
4. validate the versions match (between autorelease and the file);          (validate-version)            ## done
5. **create the full-version tag** with the new version;                    (create-tag)                  ## broken

### Step 3

The process starts when the **full version tag is created** (by the **pr-merged** job)
- For repos without builds, this should be the `autorelease-03-prep-release` workflow file
- For repos **with** builds, this should be the `autorelease-03-build-prod` workflow file

#### 05. validate-tag   (was autorelease 03 - validate from created tag)

1. get the version from the tag;                                            (check-tag)             ## done
2. get the version, type, and reviewed image id from the JSON_VARS_FILE;    (check-json-file)       ## done  (update to call the new reusable workflow..)
3. (wish-list item) update a separate "release log"
    - for repos with builds, this would also update the "build log"
4. check for any non-build outputs that might need to go to the 'prepare-final-draft' job 

#### 06. build-prod     (was autorelease 03 - build-prod)

**if applicable** this job should be called by the 'validate-tag' job in the remote repo

1. validate the reviewed image ID from the JSON_VARS_FILE;             (check-image-id)          (validate-image-id)       (update to call the new reusable workflow..)
2. validate the versions match (between autorelease and the file);     (validate-version)        (use the same job from the '02 pr-merged' workflow)
3. call the builder using the 'convert-to-prod' build method;               (call-build-prod)
4. print the build results
5. gather the AMI info and upload the artifact somewhere??
    - upload the AMI artifact file to the draft release
6. update the release template file (or send the proper outputs to the 'prepare-final-draft' job)
    - probably use `sed` or something to find/replace the new AMI ID into the file
7. print output that the new image has been built and to check the status of the 'prepare-final-draft' job

#### 07. prepare-final-draft     (was autorelease 04 - update FINAL draft release)

1. verify the draft release has the proper updates (either from **validate-tag** or **build-prod**)
    - for **build-prod**, verify the new AMI ID.  If an update needs to be made, use `sed` or something
    - for **validate-tag**, need to verify the applicable outputs or updates.  If an update needs to be made, use `sed` or something
2. verify the applicable artifacts are added to the draft release
    - for **build-prod**, verify the AMI artifact file is uploaded
3. update the release draft
4. maybe a check to ensure the draft release is valid?
5. print output that the release draft is ready for review
6. the next step is manual, requiring someone to review the release draft

### Step 4

This step starts with a manual review of the release draft.

Once the release draft has been reviewed and verified, click **Publish release**

### Step 5

The process starts when the **release is published manually by the person reviewing the release draft**
- For all repos, this should be the `autorelease-04-update-tags` workflow file

#### 08. update-tags    (maybe rename this??)

1. Update major and minor tags on release (update-tags-on-release)   **this might be the last step**
2. (wish-list item) send a notification (maybe on Slack, Discord, etc)
3. (wish-list item) **if applicable** make updates with any needed IDs or artifacts from the release, then open a PR with post-release notes??
4. celebrate!
