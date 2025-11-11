# Composite Action Implementation Guide

This guide explains how to use the Dynamic Multiline Entries composite action in your GitHub workflows.

## Overview

The Dynamic Multiline Entries action is a composite GitHub Action that reads configuration from JSON files and outputs formatted multiline strings. It's designed to replace inline configuration with file-based configuration for better maintainability.

## What It Does

1. **Reads** a JSON configuration file
2. **Extracts** an array of entries from a specified path
3. **Optionally prepends** a common prefix to each entry
4. **Formats** the entries as a multiline string with semicolons
5. **Outputs** the formatted string and metadata

## Key Benefits

- ✅ **Eliminates hardcoding** - Configuration lives in JSON files, not workflows
- ✅ **Reduces duplication** - Use prefix to avoid repeating common paths
- ✅ **Improves maintainability** - Change config files instead of workflows
- ✅ **Provides flexibility** - Works with any JSON structure via configurable paths
- ✅ **Includes validation** - Built-in error checking and clear error messages

## Quick Start

### 1. Create a Configuration File

Create a file named `project-config.json`:

```json
{
  "config": {
    "prefix": "path/to/common/base/",
    "entries": [
      "service1/resource key | OUTPUT1",
      "service2/resource key | OUTPUT2"
    ]
  }
}
```

### 2. Use the Action in Your Workflow

```yaml
- name: Load entries from configuration
  id: load-entries
  uses: rwaight/actions/test/multiline-entries@main
  with:
    config-file: './project-config.json'
    entries-path: '.config.entries'
    prefix-path: '.config.prefix'
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

- name: Use the entries
  run: echo "${{ steps.load-entries.outputs.entries }}"
```

## Detailed Usage

### Input Parameters

#### `config-file` (required)
Path to your JSON configuration file.

**Examples:**
```yaml
config-file: './project-config.json'
config-file: './configs/production.json'
config-file: '${{ inputs.CONFIG_FILE }}'
```

#### `entries-path` (optional, default: `.config.entries`)
JSON path to the array of entries.

**Examples:**
```yaml
entries-path: '.config.entries'              # Nested object
entries-path: '.items'                       # Top-level array
entries-path: '.application.settings.list'   # Deep nesting
```

#### `prefix-path` (optional, default: `.config.prefix`)
JSON path to the optional prefix string.

**Examples:**
```yaml
prefix-path: '.config.prefix'
prefix-path: '.base_path'
prefix-path: '.application.common_prefix'
```

#### `verbose` (optional, default: `false`)
Enable detailed logging.

**Examples:**
```yaml
verbose: 'true'   # Show all processing details
verbose: 'false'  # Minimal output
```

### Output Values

The action provides three outputs:

#### `entries`
The formatted multiline string with all entries.

**Example:**
```
path/to/common/base/service1/resource key | OUTPUT1 ;
path/to/common/base/service2/resource key | OUTPUT2
```

**Usage:**
```yaml
- name: Use entries
  run: echo "${{ steps.load-entries.outputs.entries }}"
```

#### `has-prefix`
Boolean string indicating if a prefix was found and applied.

**Values:** `"true"` or `"false"`

**Usage:**
```yaml
- name: Check if prefix was used
  if: steps.load-entries.outputs.has-prefix == 'true'
  run: echo "Prefix was applied to entries"
```

#### `entry-count`
The number of entries that were processed.

**Usage:**
```yaml
- name: Report entry count
  run: echo "Processed ${{ steps.load-entries.outputs.entry-count }} entries"
```

## Configuration File Formats

### Format 1: With Prefix (Recommended)

**When to use:** All or most entries share a common base path

```json
{
  "config": {
    "prefix": "common/base/path/",
    "entries": [
      "item1 key | VAR1",
      "item2 key | VAR2"
    ]
  }
}
```

**Result:**
```
common/base/path/item1 key | VAR1 ;
common/base/path/item2 key | VAR2
```

### Format 2: Without Prefix

**When to use:** Entries have different base paths

```json
{
  "config": {
    "entries": [
      "path1/item1 key | VAR1",
      "path2/item2 key | VAR2"
    ]
  }
}
```

**Result:**
```
path1/item1 key | VAR1 ;
path2/item2 key | VAR2
```

### Format 3: Custom Structure

**When to use:** Integrating with existing configuration files

```json
{
  "application": {
    "common_base": "my/base/",
    "resources": [
      "res1 key | VAR1",
      "res2 key | VAR2"
    ]
  }
}
```

**Action configuration:**
```yaml
with:
  entries-path: '.application.resources'
  prefix-path: '.application.common_base'
```

## Complete Examples

### Example 1: Using with hashicorp/vault-action

```yaml
name: Load from Vault

jobs:
  vault-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Load vault configuration
        id: vault-config
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './vault-config.json'
          entries-path: '.vault.entries'
          prefix-path: '.vault.prefix'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
      
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

### Example 2: Reusable Workflow

**Reusable workflow file:** `.github/workflows/reusable-build.yml`

```yaml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      CONFIG_FILE:
        required: true
        type: string

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Load build configuration
        id: config
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: ${{ inputs.CONFIG_FILE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
      
      - name: Run build
        run: |
          echo "Building with ${{ steps.config.outputs.entry-count }} configurations"
          # Your build logic here
```

**Caller workflow:**

```yaml
name: Build Project

on: [push]

jobs:
  build-dev:
    uses: ./.github/workflows/reusable-build.yml
    with:
      CONFIG_FILE: './configs/dev.json'
  
  build-prod:
    uses: ./.github/workflows/reusable-build.yml
    with:
      CONFIG_FILE: './configs/prod.json'
```

### Example 3: Multiple Configurations

```yaml
name: Multi-Environment Deploy

jobs:
  load-all-configs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Load dev config
        id: dev
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './configs/dev.json'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
      
      - name: Load staging config
        id: staging
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './configs/staging.json'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
      
      - name: Load production config
        id: prod
        uses: rwaight/actions/test/multiline-entries@main
        with:
          config-file: './configs/prod.json'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
      
      - name: Display all configurations
        run: |
          echo "=== Dev Config (${{ steps.dev.outputs.entry-count }} entries) ==="
          echo "${{ steps.dev.outputs.entries }}"
          echo ""
          echo "=== Staging Config (${{ steps.staging.outputs.entry-count }} entries) ==="
          echo "${{ steps.staging.outputs.entries }}"
          echo ""
          echo "=== Production Config (${{ steps.prod.outputs.entry-count }} entries) ==="
          echo "${{ steps.prod.outputs.entries }}"
```

## Troubleshooting

### Error: Configuration file not found

**Problem:** The action cannot find your configuration file.

**Solution:**
1. Check the file path is correct and relative to repository root
2. Ensure the file is committed to your repository
3. Use `ls` in a previous step to verify the file exists

```yaml
- name: Debug - List files
  run: ls -la
```

### Error: Entries not found at path

**Problem:** The specified JSON path doesn't exist in your configuration.

**Solution:**
1. Verify the JSON structure matches your path
2. Test locally with `jq`:
   ```bash
   jq '.config.entries' your-config.json
   ```
3. Enable verbose mode to see what's being searched

### Error: This action supports Linux only

**Problem:** You're trying to run on a Windows or macOS runner.

**Solution:** Use a Linux runner:
```yaml
runs-on: ubuntu-latest
```

### Output is empty or incorrect

**Problem:** The formatted output doesn't look right.

**Solution:**
1. Enable verbose mode:
   ```yaml
   with:
     verbose: 'true'
   ```
2. Check the entry format in your JSON
3. Verify the prefix is being applied correctly

## Best Practices

### 1. Use Descriptive Configuration Files

**Good:**
```
configs/
  production.json
  staging.json
  development.json
```

**Avoid:**
```
config1.json
config2.json
temp.json
```

### 2. Add Comments to JSON

```json
{
  "_comment": "Production configuration",
  "config": {
    "_comment": "Common prefix for all production resources",
    "prefix": "prod/",
    "entries": [...]
  }
}
```

### 3. Validate JSON Locally

Before committing, validate your JSON:
```bash
jq . your-config.json
```

### 4. Use Workflow Inputs for Flexibility

```yaml
on:
  workflow_dispatch:
    inputs:
      config_file:
        description: 'Configuration file to use'
        required: true
        type: choice
        options:
          - './configs/dev.json'
          - './configs/staging.json'
          - './configs/prod.json'
```

### 5. Enable Verbose Mode During Development

```yaml
with:
  verbose: 'true'  # Enable during development
```

### 6. Store Metadata with Entries

```json
{
  "metadata": {
    "environment": "production",
    "last_updated": "2025-11-10",
    "maintainer": "team@example.com"
  },
  "config": {
    "prefix": "prod/",
    "entries": [...]
  }
}
```

## Advanced Usage

### Dynamic Path Selection

```yaml
- name: Load entries with dynamic paths
  id: load
  uses: rwaight/actions/test/multiline-entries@main
  with:
    config-file: ${{ inputs.config_file }}
    entries-path: ${{ inputs.entries_path }}
    prefix-path: ${{ inputs.prefix_path }}
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
```

### Conditional Processing

```yaml
- name: Load entries
  id: load
  uses: rwaight/actions/test/multiline-entries@main
  with:
    config-file: './config.json'
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

- name: Process if prefix was used
  if: steps.load.outputs.has-prefix == 'true'
  run: echo "Using prefixed entries"

- name: Process if no prefix
  if: steps.load.outputs.has-prefix == 'false'
  run: echo "Using full-path entries"
```

### Combining Multiple Outputs

```yaml
- name: Combine configurations
  run: |
    echo "Total entries: $(( ${{ steps.config1.outputs.entry-count }} + ${{ steps.config2.outputs.entry-count }} ))"
    echo ""
    echo "=== Config 1 ==="
    echo "${{ steps.config1.outputs.entries }}"
    echo ""
    echo "=== Config 2 ==="
    echo "${{ steps.config2.outputs.entries }}"
```

## Testing

Test your configuration locally before using in workflows:

```bash
# Test JSON validity
jq . your-config.json

# Test entries extraction
jq '.config.entries' your-config.json

# Test prefix extraction
jq '.config.prefix' your-config.json

# Test full transformation (with prefix)
PREFIX=$(jq -r '.config.prefix' your-config.json)
jq -r ".config.entries | map(\"${PREFIX}\" + .) | join(\" ;\n\")" your-config.json
```

## Migration Guide

### From Hardcoded Values

**Before:**
```yaml
- uses: some-action@v1
  with:
    input: |
      path/to/resource1 key | VAR1 ;
      path/to/resource2 key | VAR2 ;
      path/to/resource3 key | VAR3
```

**After:**
1. Create `config.json`:
   ```json
   {
     "config": {
       "prefix": "path/to/",
       "entries": [
         "resource1 key | VAR1",
         "resource2 key | VAR2",
         "resource3 key | VAR3"
       ]
     }
   }
   ```

2. Update workflow:
   ```yaml
   - name: Load config
     id: config
     uses: rwaight/actions/test/multiline-entries@main
     with:
       config-file: './config.json'
       verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
   
   - uses: some-action@v1
     with:
       input: ${{ steps.config.outputs.entries }}
   ```

## Support

For issues or questions:
1. Check this guide first
2. Review the [README](README.md)
3. Look at [example-workflow.yml](example-workflow.yml)
4. Enable verbose mode for debugging
5. Validate JSON locally with `jq`

## Related Resources

- [Action README](README.md)
- [Example Workflow](example-workflow.yml)
- [Example Configuration](example-config.json)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [jq Manual](https://stedolan.github.io/jq/manual/)
