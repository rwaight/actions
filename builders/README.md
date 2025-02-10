# Actions used for builds

This directory contains actions that are used for building packages, images, etc.

###

### Using KVM (Nested virtualization) in GitHub Actions

If you need to leverage nested virtualization (for example: [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine)) in order to build images using GitHub Actions, then review the following:
- https://github.blog/changelog/2023-02-23-hardware-accelerated-android-virtualization-on-actions-windows-and-linux-larger-hosted-runners/, **and**
- https://github.com/actions/runner-images/issues/183#issuecomment-1442154492
    - Migrated to https://github.com/actions/runner-images/discussions/7191

As well as:
- https://actuated.dev/blog/kvm-in-github-actions
- https://github.com/actions/runner-images/issues/183
    - Specifically, https://github.com/actions/runner-images/issues/183#issuecomment-1442154492, links to the GitHub changelog
