# Actions used for builds

This directory contains actions that are used for building packages, images, etc.  Composite actions created for building should be stored here.

### Using KVM (Nested virtualization) in GitHub Actions

If we need to leverage nested virtualization, we may need to use KVM, in order to build specific images using GitHub Actions.

Review the following:
- https://github.blog/changelog/2023-02-23-hardware-accelerated-android-virtualization-on-actions-windows-and-linux-larger-hosted-runners/, **and**
- https://github.com/actions/runner-images/issues/183#issuecomment-1442154492
    - Migrated to https://github.com/actions/runner-images/discussions/7191

As well as:
- https://actuated.dev/blog/kvm-in-github-actions
- https://github.com/actions/runner-images/issues/183
    - Specifically, https://github.com/actions/runner-images/issues/183#issuecomment-1442154492, links to the GitHub changelog
