# GitHub Keep-a-Changelog Action

The current version in this repo was based off of [**keep-a-changelog-action** v3.0.0](https://github.com/release-flow/keep-a-changelog-action/releases/tag/v3.0.0) (specifically [this commit](https://github.com/release-flow/keep-a-changelog-action/commit/74931dec7ecdbfc8e38ac9ae7e8dd84c08db2f32))
- This action is from https://github.com/release-flow/keep-a-changelog-action.


The [`release-flow/keep-a-changelog-action`](https://github.com/release-flow/keep-a-changelog-action) has an MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

None at this time.

## Keep-a-Changelog Action

A GitHub Action that performs various operations on changelogs that adhere to
[keep-a-changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/) conventions.

## Commands

### [bump](./docs/bump.md)

Updates a changelog by converting the '[Unreleased]' section to the latest release number. The release number is
automatically incremented according to the action parameters.

### [query](./docs/query.md)

Queries release information for a specified version from a changelog.

## Updating from V1 to V2

The upgrade is fairly straightforward, documented [here](./docs/upgrade-v2.md).

## License

The scripts and documentation in this project are released under the [MIT License](./LICENSE).
