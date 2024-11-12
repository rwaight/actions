# Infra-sourced label asset files

This folder contains label configuration files used in GitHub automations.

The following label asset files are sourced from the 'infra' repo in the `infra/assets/labels/` directory:

```bash
./labels/
├── my-labels-actions.yml
├── my-labels-core.yml
└── my-labels-versioning.yml
```

## Use of the label configuration files

The `my-labels-*` files are used by the **label-sync** action (see [`rwaight/actions/github/label-sync`](https://github.com/rwaight/actions/tree/main/github/label-sync)), which is configured in the repos as the `./github/workflows/label-manager.yml` workflow.
