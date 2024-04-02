# GitHub Actions Monorepo

A collection of GitHub actions to run from your own GitHub repo.

This repo currently **does not include** [actions](https://docs.github.com/actions/automating-your-workflow-with-github-actions/using-github-marketplace-actions) from [authors with the `Verified creator` badge](https://docs.github.com/en/apps/github-marketplace/github-marketplace-overview/about-marketplace-badges).

### Actions in scope

This repo contains [GitHub Actions](https://github.com/marketplace?type=actions) that are **not** [verified Actions](https://docs.github.com/actions/automating-your-workflow-with-github-actions/using-github-marketplace-actions).  Actions that **do not** have the `Verified creator` badge should be copied to this repo and run from this repo.
- ***Note***: Any actions that run in a Docker container **must** be run by the dfeault Docker user, `root`, per [the Dockerfile support for GitHub Actions **USER** section](https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user).


### Categories

The actions are currently organized by the following categories:
```bash
.
├── builders
├── git
├── github
├── releases
└── utilities
```

#### Actions by category

Here is a current list of actions by category
```bash
.
├── builders
├── git
│   ├── add-and-commit
│   ├── git-describe-semver
│   ├── repo-version-info
│   └── semantic-pull-request
├── github
│   ├── create-or-update-comment
│   ├── create-pull-request
│   ├── export-label-config
│   ├── find-comment
│   ├── find-pull-request
│   ├── github-changelog-generator
│   ├── issue-triage
│   ├── label-checker
│   ├── label-manager
│   ├── label-sync
│   ├── paths-filter
│   ├── projectnext-label-assigner
│   └── repository-dispatch
├── releases
│   ├── release-drafter
│   └── release-tag-updater
└── utilities
    ├── copycat
    ├── packer
    ├── public-ip
    └── render-template
```
