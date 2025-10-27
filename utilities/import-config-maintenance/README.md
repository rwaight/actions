# Import Config Maintenance Action

A composite GitHub Action that scans all actions in the monorepo and updates/creates `import-config.yml` files for each action.

## Description

This action automates the maintenance of `import-config.yml` files across the entire actions monorepo. It:

- Reads action metadata from `action.yml` or `action.yaml` files
- Updates existing `import-config.yml` files with current specifications
- Checks for available updates to imported actions via GitHub API
- Ensures default exclusions are present for update operations
- Tracks processing statistics and errors

## Prerequisites

**This action requires the repository to be checked out first.** It reads the `target_dirs.conf` file from the repository root to determine which directories to scan.

## Inputs

### `working-directory`

**Required:** `false`  
**Default:** `'.'`

Working directory for the action (repository root). Use this if you need to run the action from a subdirectory.

### `dry-run`

**Required:** `false`  
**Default:** `'false'`

Run in dry-run mode (no file modifications). When set to `true`, the action will process all actions and report what would be updated without making any changes.

### `create-new-configs`

**Required:** `false`  
**Default:** `'false'`

Allow creation of new `import-config.yml` files. **Note:** Creating new config files requires interactive user input, so this should remain `false` for automated workflow runs. Use the standalone `import_configs.sh` script for creating new configs.

## Outputs

### `actions-processed`

Number of actions processed during the run.

### `actions-updated`

Number of `import-config.yml` files that were updated.

### `errors-found`

Number of errors encountered during processing.

### `error-log-path`

Full path to the error log file (typically `import_configs_errors.log` in the working directory).

## Usage

### Basic Usage

```yaml
name: Maintain Import Configs

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  maintain-configs:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install yq
        id: install-yq
        # https://github.com/rwaight/actions/tree/main/utilities/install-yq
        uses: rwaight/actions/utilities/install-yq@main
        with:
            version: latest
            verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Maintain import configs
        id: maintain
        # https://github.com/rwaight/actions/tree/main/utilities/import-config-maintenance
        uses: rwaight/actions/utilities/import-config-maintenance@main
      
      - name: Display results
        run: |
          echo "Actions processed: ${{ steps.maintain.outputs.actions-processed }}"
          echo "Actions updated: ${{ steps.maintain.outputs.actions-updated }}"
          echo "Errors found: ${{ steps.maintain.outputs.errors-found }}"
      
      - name: Commit changes
        if: steps.maintain.outputs.actions-updated > 0
        uses: rwaight/actions/git/add-and-commit@main
        with:
          message: 'chore: update import-config.yml files'
          add: '*/*/import-config.yml'
```

### Dry-Run Mode

```yaml
- name: Maintain import configs (dry-run)
  id: maintain
  uses: rwaight/actions/utilities/import-config-maintenance@main
  with:
    dry-run: 'true'

- name: Check what would be updated
  run: |
    echo "Would update ${{ steps.maintain.outputs.actions-updated }} actions"
    cat import_configs_errors.log
```

### Custom Working Directory

```yaml
- name: Maintain import configs
  uses: rwaight/actions/utilities/import-config-maintenance@main
  with:
    working-directory: './my-actions-repo'
```

### With Error Handling

```yaml
- name: Maintain import configs
  id: maintain
  uses: rwaight/actions/utilities/import-config-maintenance@main
  continue-on-error: true

- name: Upload error log if errors found
  if: steps.maintain.outputs.errors-found > 0
  uses: actions/upload-artifact@v4
  with:
    name: import-config-errors
    path: ${{ steps.maintain.outputs.error-log-path }}

- name: Create issue if errors found
  if: steps.maintain.outputs.errors-found > 0
  uses: actions/github-script@v7
  with:
    script: |
      await github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: 'Import Config Maintenance Errors',
        body: `Found ${{ steps.maintain.outputs.errors-found }} errors while maintaining import configs.\n\nSee workflow run: ${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`
      });
```

## What It Updates

For each action in the monorepo, this action updates the following fields in `import-config.yml`:

- `author` - From the action's `author` field
- `description` - From the action's `description` field
- `specs.action_file` - The filename (`action.yml` or `action.yaml`)
- `specs.inputs` - List of input keys from the action
- `specs.outputs` - List of output keys from the action
- `specs.runs.using` - The runtime environment
- `specs.runs.main` - The main entry point (if applicable)

For imported actions, it also:
- Fetches the latest version from GitHub API
- Updates `source.latest_version`
- Sets `source.update_available` to `true` or `false`
- Updates the `author` field if set to "placeholder"

Additionally, it ensures:
- Default exclusions are present in `local.update.exclusions`
- The exclusions list includes `README-examples.md` and `example-custom-notes.md`

## Dependencies

This action requires the following tools:
- **yq** - YAML processor (automatically installed if not present)
- **jq** - JSON processor (typically pre-installed on GitHub runners)
- **gh** - GitHub CLI (pre-installed on GitHub runners)

## Notes

- This action will **not** create new `import-config.yml` files in automated runs
- To create new config files, use the standalone `import_configs.sh` script manually
- The action respects the `target_dirs.conf` file in the repository root
- Error details are logged to `import_configs_errors.log` in the working directory

## Local Testing

For local testing and development, you can extract the bash script from this action and run it manually. See the [Local Usage Guide](./LOCAL_USAGE.md) for detailed instructions on:

- Extracting the script from `action.yml`
- Setting up the required environment variables
- Running the script locally
- Testing changes before committing

The `action.yml` file is the canonical source for the bash script.

## Related Actions

- [`check-imported-updates`](../check-imported-updates) - Check for and apply updates to imported actions
- [`install-yq`](../install-yq) - Install the yq YAML processor

## See Also

- [Actions Scripts Documentation](../../docs/actions-scripts-README.md)
- [Import Config File Specifications](../../docs/actions-scripts-README.md#import-config-file-specifications)
