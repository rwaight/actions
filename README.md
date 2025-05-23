# GitHub Actions Monorepo

A collection of GitHub actions to run from your own GitHub repo.

This repo currently **does not include** [actions](https://docs.github.com/actions/automating-your-workflow-with-github-actions/using-github-marketplace-actions) from [authors with the `Verified creator` badge](https://docs.github.com/en/apps/github-marketplace/github-marketplace-overview/about-marketplace-badges).

### Actions in scope

This repo contains [GitHub Actions](https://github.com/marketplace?type=actions) that are **not** [verified Actions](https://docs.github.com/actions/automating-your-workflow-with-github-actions/using-github-marketplace-actions).  Actions that **do not** have the `Verified creator` badge should be copied to this repo and run from this repo.
- ***Note***: Any actions that run in a Docker container **must** be run by the default Docker user, `root`, per [the Dockerfile support for GitHub Actions **USER** section](https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user).


### Categories

The actions are currently organized by the following categories:
```bash
.
├── builders
├── chatops
├── composite
├── git
├── github
├── instruqt
├── releases
├── utilities
└── vars
```

#### Actions by category

<details>
<summary>Actions by category (click to expand)</summary>

Here is a current list of actions by category
```bash
.
├── builders
│   ├── nested-virtualization
│   └── packer-docker
├── chatops
│   ├── create-or-update-comment
│   └── find-comment
├── git
│   ├── add-and-commit
│   ├── changed-files
│   ├── git-describe-semver
│   ├── keep-a-changelog-action
│   ├── repo-version-info
│   └── semver-git-version
├── github
│   ├── approve-pull-request
│   ├── create-pull-request
│   ├── export-label-config
│   ├── find-pull-request
│   ├── issue-triage
│   ├── label-checker
│   ├── label-manager
│   ├── label-sync
│   ├── projectnext-label-assigner
│   ├── repository-dispatch
│   ├── runner-debug
│   └── semantic-pull-request
├── instruqt
│   ├── track-delete
│   ├── track-dev
│   ├── track-promote
│   ├── track-pull
│   ├── track-push
│   ├── track-tags
│   ├── track-test
│   └── track-validate
├── releases
│   ├── release-drafter
│   ├── release-tag-updater
│   └── semantic-release
├── utilities
│   ├── copycat
│   ├── install-yq
│   ├── paths-filter
│   ├── public-ip
│   └── render-template
└── vars
    ├── build-method
    ├── build-type
    ├── build-version
    └── packer-skip-create
```

</details>


#### GitHub Actions Category Overview

While the long-term plan _was_ to use the [category list from the GitHub Actions Marketplace](https://github.com/marketplace?category=&type=actions), the categories above have been chosen as marketplace actions can select more than one category.
<!--- ~Before the first official release~, ~the categories will be changed to align with the GitHub Actions categories~. ~They will use~ the category list from https://github.com/marketplace?category=&type=actions: --->

<details><summary>GitHub Actions Marketplace Categories</summary>

The current [categories from the GitHub Actions Marketplace](https://github.com/marketplace?category=&type=actions) are:
```markdown
**Categories**
API management
Chat
Code quality
Code review
Continuous integration
Dependency management
Deployment
Deployment Protection Rules
IDES
Learning
Localization
Mobile
Monitoring
Project management
Publishing
Recently added
Security
Support
Testing
Utilities
```

</details>

