# Dynamic Multiline Entries Action

A composite GitHub Action for dynamically loading multiline entries from JSON configuration files with optional prefix support.

This action reads a JSON configuration file, extracts an array of entries, optionally prepends a common prefix to each entry, and outputs a formatted multiline string. This is particularly useful for actions that require multiline input in a specific format.

Reference GitHub's [creating a composite action guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) for more information.

## Features

- ✅ **Configuration-driven** - Read entries from JSON files
- ✅ **Prefix support** - Optionally prepend a common prefix to all entries
- ✅ **Flexible paths** - Configurable JSON paths for any structure
- ✅ **Formatted output** - Automatically formats entries with semicolons and newlines
- ✅ **Metadata outputs** - Provides entry count and prefix usage information
- ✅ **Verbose mode** - Optional detailed logging

## Deploying this action

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config-file` | Path to the JSON configuration file containing entries | Yes | `./project-config.json` |
| `entries-path` | JSON path to the entries array (e.g., `.config.entries`) | No | `.config.entries` |
| `prefix-path` | JSON path to the optional prefix (e.g., `.config.prefix`) | No | `.config.prefix` |
| `verbose` | Determine if the action should run verbose tasks | No | `false` |

See the `inputs` configured in the [action.yml](action.yml) file.

### Outputs

| Output | Description |
|--------|-------------|
| `entries` | The formatted multiline entries output from this action |
| `has-prefix` | Boolean indicating if a prefix was found and applied |
| `entry-count` | The number of entries processed |

See the `outputs` configured in the [action.yml](action.yml) file.

## Configuration File Structure

### With Prefix (Recommended)

```json
{
  "config": {
    "prefix": "path/to/common/base/",
    "entries": [
      "service1/resource key1 | OUTPUT_VAR1",
      "service2/resource key2 | OUTPUT_VAR2",
      "service3/resource key3 | OUTPUT_VAR3"
    ]
  }
}
```

**Result:** Each entry will be prepended with `path/to/common/base/`

### Without Prefix

```json
{
  "config": {
    "entries": [
      "path/to/service1/resource key1 | OUTPUT_VAR1",
      "path/to/service2/resource key2 | OUTPUT_VAR2"
    ]
  }
}
```

## Example Usage

### Basic Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:

```yaml
name: Use Dynamic Multiline Entries

on:
  push:
    branches:
      - 'main'

jobs:
  use-dynamic-entries:
    runs-on: ubuntu-latest
    name: Dynamic Entries Example
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Load entries from configuration
        id: load-entries
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './project-config.json'
          entries-path: '.config.entries'
          prefix-path: '.config.prefix'
          verbose: true

      - name: Display the formatted entries
        run: |
          echo "Formatted entries:"
          echo "${{ steps.load-entries.outputs.entries }}"
          echo ""
          echo "Entry count: ${{ steps.load-entries.outputs.entry-count }}"
          echo "Has prefix: ${{ steps.load-entries.outputs.has-prefix }}"

      - name: Use entries with another action
        uses: some-action/that-needs-multiline@v1
        with:
          formatted_input: ${{ steps.load-entries.outputs.entries }}
```

### Using with hashicorp/vault-action

```yaml
name: Load Configuration and Import from Vault

on:
  workflow_dispatch:

jobs:
  vault-example:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Load vault entries from configuration
        id: load-vault-entries
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './vault-config.json'
          entries-path: '.vault.entries'
          prefix-path: '.vault.prefix'

      - name: Import from Vault
        uses: hashicorp/vault-action@v3
        with:
          url: https://vault.example.com:8200
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          secrets: |
            ${{ steps.load-vault-entries.outputs.entries }}
        id: vault-import
```

### Custom JSON Paths

```yaml
- name: Load entries with custom paths
  id: load-custom
  uses: rwaight/actions/test/multiline-entries@main
  with:
    config-file: './my-config.json'
    entries-path: '.custom.path.to.items'
    prefix-path: '.custom.path.to.base'
    verbose: false
```

## Output Format

The action outputs entries in the following format:

```
path/to/entry1 key1 | VAR1 ;
path/to/entry2 key2 | VAR2 ;
path/to/entry3 key3 | VAR3
```

Each line:
- Ends with a semicolon (required by many actions like vault-action)
- Contains the full path (prefix + entry if prefix is defined)
- Preserves the original entry format

## Error Handling

The action will fail with a clear error message if:

- The runner OS is not Linux
- The configuration file doesn't exist
- The entries path is not found in the configuration file
- The JSON is malformed

## Debugging

Enable verbose mode to see detailed processing information:

```yaml
with:
  verbose: true
```

This will display:
- Input values
- Configuration file path
- Entries and prefix paths
- Whether a prefix was found
- The final formatted output
- Entry count

## Use Cases

This action is useful when you need to:

- Pass formatted lists to GitHub Actions requiring specific input formats
- Maintain project-specific configurations for reusable workflows
- Reduce duplication in configuration files with common prefixes
- Support multiple projects with different requirements
- Keep workflows DRY (Don't Repeat Yourself)

## Benefits

- **Reusable** - One action, many projects
- **Maintainable** - Change config files, not workflows
- **Flexible** - Works with or without prefixes
- **Clean** - Reduces repetitive path definitions
- **Validated** - Built-in error checking

## Requirements

- Runs on Linux runners only
- Requires `jq` (pre-installed on GitHub-hosted runners)
- Requires valid JSON configuration file in the repository

## Related Documentation

- [GitHub Actions: Creating a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [GitHub Actions: Metadata syntax](https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [GitHub Actions: Workflow commands](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions)

## License

Part of the rwaight/actions repository. See the main repository for license information.
