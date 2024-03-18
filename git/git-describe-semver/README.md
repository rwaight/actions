# GitHub Action - git-describe-semver

The current version in this repo is based off of [**git-describe-semver** v0.3.11](https://github.com/choffmeister/git-describe-semver/releases/tag/v0.3.11) (specifically [this commit](https://github.com/choffmeister/git-describe-semver/commit/92b2c9cc7c405b6a97adb71caa41ec5f73639f1b))
- This action is from https://github.com/choffmeister/git-describe-semver/.

The [`choffmeister/git-describe-semver`](https://github.com/choffmeister/git-describe-semver/) has a **BSD-3-Clause** License:
> A permissive license similar to the BSD 2-Clause License, but with a 3rd clause that prohibits others from using the name of the copyright holder or its contributors to promote derived products without written consent.

## Updates to the action

None at this time.

## git-describe-semver

Replacement for `git describe --tags` that produces [semver](https://semver.org/) compatible versions that follow to semver sorting rules.

### Comparison

Previous git tag | git describe --tags | git-describe-semver --fallback v0.0.0
--- | --- | ---
`v1.2.3` | `v1.2.3` | `v1.2.3`
`v1.2.3` | `v1.2.3-23-gabc1234` | `v1.2.4-dev.23.gabc1234`
`v1.3.0-rc.1` | `v1.3.0-rc.1-23-gabc1234` | `v1.3.0-rc.1.dev.23.gabc1234`
`v1.3.0-rc.1+info` | `v1.3.0-rc.1+info-23-gabc1234` | `v1.3.0-rc.1.dev.23.gabc1234+info`
none | fail | `v0.0.0-dev.23.gabc1234`

### Usage

* Flag `--dir /some/git/worktree`: Git worktree directory (defaults to current directory)
* Flag `--fallback v0.0.0`: Fallback to given tag name if no tag is available
* Flag `--drop-prefix`: Drop any present prefix (like `v`) from the output
* Flag `--prerelease-suffix`: Adds a dash-separated suffix to the prerelease part
* Flag `--format`: Changes output (use `<version>` as placeholder)

#### GitHub action

```yaml
# .github/workflows/get-version-info.yml
name: get-version-info
jobs:
  workflow-with-get-version:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Get the semver version using rwaight/actions/git/git-describe-semver
      id: git-describe-semver
      #uses: rwaight/actions/git/git-describe-semver@main
      uses: rwaight/actions/git/git-describe-semver@v1
      with:
        version: latest
        # set 'dir' to 'git-describe-semver' due to the action being in a subdirectory
        dir: git-describe-semver
        fallback: v0.0.0
        drop-prefix: true
        #prerelease-prefix: dev
        #prerelease-suffix: SNAPSHOT
        #prerelease-timestamped: true
        #gh-token: ${{ secrets.GITHUB_TOKEN }}
        gh-debug: true

    - name: Info about semver versioning
      run: echo "See https://semver.org/ for more information"

    - name: Output the semver version from the git-describe-semver step
      if: ${{ steps.git-describe-semver.outputs.version }}
      run: echo "The version is ${{ steps.git-describe-semver.outputs.version }}"

    - name: Fail if the 'git-describe-semver' step did not output a semver version
      if: ${{ ! steps.git-describe-semver.outputs.version }}
      shell: bash
      run: |
        echo "::error title=⛔ error in the 'git-describe-semver' step hint::Unable to find a valid version"
        exit 1
      # https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#setting-an-error-message

```
