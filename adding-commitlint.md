# Adding commitlint to this repo


The new [`actions-ci` workflow](.github/workflows/actions-ci.yml), which is based off of [**commitlint**](https://commitlint.js.org/) ([commitlint GitHub](https://github.com/conventional-changelog/commitlint)), has been added in an effort to enforce good **git hygiene**.

The workflow originated from [the _CI setup_ **GitHub Actions** section](https://commitlint.js.org/guides/ci-setup.html#github-actions) of the [commitlint guides](https://commitlint.js.org/guides/ci-setup.html).  The example workflow needed to be updated in order to run, but it should be working now.

The default commitlint configuration:
```js
module.exports = {
    extends: [
        "@commitlint/config-conventional"
    ],
}
```

#### Resources
commitlint guide links:
- [Guide: Getting started](https://commitlint.js.org/guides/getting-started.html)
- [Guide: Local setup](https://commitlint.js.org/guides/local-setup.html)
- [Guide: CI Setup](https://commitlint.js.org/guides/ci-setup.html)

Actions that can be used with `commitlint`:
- https://github.com/webiny/action-conventional-commits
- https://github.com/wagoid/commitlint-github-action
- https://github.com/commitizen/conventional-commit-types
- https://github.com/amannn/action-semantic-pull-request
- (deprecated) https://github.com/squash-commit-app/squash-commit-app
- (deprecated) https://github.com/zeke/semantic-pull-requests


Examples with a `semantic.yml` file within a GitHub repo:
- https://github.com/GoogleChrome/lighthouse-ci/blob/main/.github/semantic.yml
- https://github.com/minecrafthome/minecrafthome/blob/master/semantic.yml
- https://github.com/meltano/sdk/blob/main/.github/semantic.yml
- https://github.com/vectordotdev/vector/blob/master/.github/semantic.yml


Here are links to other resources:
- https://github.blog/changelog/2022-05-11-default-to-pr-titles-for-squash-merge-commit-messages/
- https://semantic-release.gitbook.io/semantic-release/recipes/ci-configurations/github-actions
- https://jamiewen00.medium.com/integrate-commitlint-to-your-repository-67d6524d0d24
- https://ajcwebdev.com/semantic-github/

