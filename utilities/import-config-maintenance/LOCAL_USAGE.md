# Using the Bash Script Locally

This guide explains how to extract and run the `maintain-import-configs.sh` script locally for testing and development.

> **Important Note**: The canonical source of the bash script is in the `action.yml` file within the `maintain-configs` step. For local testing, you can extract the script to a standalone file using the instructions below.

## Prerequisites

- Bash shell (macOS, Linux, or WSL on Windows)
- Access to a terminal/command line
- `yq` command-line YAML processor (for extracting the script from `action.yml`)
- `jq` command-line JSON processor (typically pre-installed)
- `gh` CLI (GitHub CLI) for fetching version information

## Extracting the Script from action.yml

The bash script is embedded in the `action.yml` file and must be extracted for local testing. The script in `action.yml` is the single source of truth.

### Installing Required Tools (if not already installed)

**Installing yq:**

**On macOS**:
```bash
brew install yq
```

**On Linux**:
```bash
# Using snap
sudo snap install yq

# Or download from GitHub releases
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq
```

**Installing gh CLI (GitHub CLI):**

**On macOS**:
```bash
brew install gh
```

**On Linux**:
```bash
# Debian/Ubuntu
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Extracting the Script

Navigate to the `utilities/import-config-maintenance` directory and run this command to extract the bash script from the `action.yml` file:

```bash
cd /path/to/repo/utilities/import-config-maintenance

# Extract the script from action.yml using yq
yq eval '.runs.steps[] | select(.id == "maintain-configs") | .run' action.yml > maintain-import-configs.sh
```

**Alternative method using awk (if yq is not available)**:

```bash
cd /path/to/repo/utilities/import-config-maintenance

# Extract the script using awk
awk '/- name: Maintain import configs/,/shell: bash/ {
  if (/run: \|/) { capture=1; next }
  if (/shell: bash/) { exit }
  if (capture) { sub(/^        /, ""); print }
}' action.yml > maintain-import-configs.sh
```

**Alternative method using sed**:

```bash
cd /path/to/repo/utilities/import-config-maintenance

# Extract using sed
sed -n '/- name: Maintain import configs/,/shell: bash/p' action.yml | \
  sed -n '/run: |/,/shell: bash/p' | \
  sed '1d;$d' | \
  sed 's/^        //' > maintain-import-configs.sh
```

### Verify the Extraction

After extracting, verify the script looks correct:

```bash
# Check the first few lines
head -20 maintain-import-configs.sh

# Verify it's valid bash syntax
bash -n maintain-import-configs.sh
```

The extracted file should start with:

```bash
# Define the error log file
error_log="${FILE_ERROR_LOG}"
> "$error_log"  # Clear the log file at the start
...
```

## Running the Script Locally

### 1. Navigate to the Repository Root

The script expects to be run from the repository root directory where `target_dirs.conf` is located:

```bash
cd /path/to/repo
```

### 2. Set Environment Variables

The script uses environment variables that are normally set by GitHub Actions. You need to set them manually:

```bash
# Required environment variables
export FILE_ERROR_LOG="import_configs_errors.log"
export FILE_TARGET_DIRS="target_dirs.conf"
export FILE_DEFAULT_CONFIG="import-config.yml"

# Optional: Run in dry-run mode (recommended for testing)
export DRY_RUN="true"

# Optional: Allow creation of new configs (requires interactive input)
export CREATE_NEW_CONFIGS="false"

# Required for GitHub Actions output (can be set to a file for local testing)
export GITHUB_OUTPUT="github_output.txt"
```

### 3. Make the Script Executable

```bash
chmod +x utilities/import-config-maintenance/maintain-import-configs.sh
```

### 4. Run the Script

```bash
# Run from the repository root
./utilities/import-config-maintenance/maintain-import-configs.sh
```

Or run it directly with bash:

```bash
bash utilities/import-config-maintenance/maintain-import-configs.sh
```

## Configuration

### Required Environment Variables

```bash
# File paths (these should match the defaults)
export FILE_ERROR_LOG="import_configs_errors.log"
export FILE_TARGET_DIRS="target_dirs.conf"
export FILE_DEFAULT_CONFIG="import-config.yml"

# GitHub Actions output file (for local testing, use a temporary file)
export GITHUB_OUTPUT="/tmp/github_output.txt"
```

### Optional Environment Variables

```bash
# Run in dry-run mode (no file modifications)
export DRY_RUN="true"

# Allow creation of new import-config.yml files (requires interactive input)
export CREATE_NEW_CONFIGS="false"
```

### Using a Script to Set Environment Variables

Create a helper script to set all required variables:

```bash
# File: utilities/import-config-maintenance/set-env.sh
#!/bin/bash

# Set required environment variables
export FILE_ERROR_LOG="import_configs_errors.log"
export FILE_TARGET_DIRS="target_dirs.conf"
export FILE_DEFAULT_CONFIG="import-config.yml"
export GITHUB_OUTPUT="/tmp/github_output_$(date +%s).txt"

# Set optional variables
export DRY_RUN="${DRY_RUN:-true}"
export CREATE_NEW_CONFIGS="${CREATE_NEW_CONFIGS:-false}"

echo "Environment variables set:"
echo "  FILE_ERROR_LOG: $FILE_ERROR_LOG"
echo "  FILE_TARGET_DIRS: $FILE_TARGET_DIRS"
echo "  FILE_DEFAULT_CONFIG: $FILE_DEFAULT_CONFIG"
echo "  GITHUB_OUTPUT: $GITHUB_OUTPUT"
echo "  DRY_RUN: $DRY_RUN"
echo "  CREATE_NEW_CONFIGS: $CREATE_NEW_CONFIGS"
```

Then source it before running:

```bash
source utilities/import-config-maintenance/set-env.sh
```

## Complete Example Workflow

Here's a complete example from start to finish:

```bash
# 1. Navigate to the repository root
cd /path/to/repo

# 2. Extract the script from action.yml (one-time or after updates)
cd utilities/import-config-maintenance
yq eval '.runs.steps[] | select(.id == "maintain-configs") | .run' action.yml > maintain-import-configs.sh

# Or if yq is not available, use awk:
# awk '/- name: Maintain import configs/,/shell: bash/ {
#   if (/run: \|/) { capture=1; next }
#   if (/shell: bash/) { exit }
#   if (capture) { sub(/^        /, ""); print }
# }' action.yml > maintain-import-configs.sh

# 3. Make the script executable
chmod +x maintain-import-configs.sh

# 4. Return to repository root
cd ../..

# 5. Set environment variables
export FILE_ERROR_LOG="import_configs_errors.log"
export FILE_TARGET_DIRS="target_dirs.conf"
export FILE_DEFAULT_CONFIG="import-config.yml"
export GITHUB_OUTPUT="/tmp/github_output.txt"
export DRY_RUN="true"  # Start with dry-run mode
export CREATE_NEW_CONFIGS="false"

# 6. Run the script
./utilities/import-config-maintenance/maintain-import-configs.sh

# 7. Check the outputs
cat /tmp/github_output.txt
cat import_configs_errors.log
```

## Running with Different Modes

### Dry-Run Mode (Recommended for Testing)

```bash
export DRY_RUN="true"
./utilities/import-config-maintenance/maintain-import-configs.sh
```

This will process all actions and report what would be updated without making any changes.

### Live Mode (Make Actual Changes)

```bash
export DRY_RUN="false"
./utilities/import-config-maintenance/maintain-import-configs.sh
```

**Warning**: This will modify `import-config.yml` files. Make sure you have committed any pending changes first.

### One-Line Execution

```bash
# Dry-run from repository root
FILE_ERROR_LOG="import_configs_errors.log" \
FILE_TARGET_DIRS="target_dirs.conf" \
FILE_DEFAULT_CONFIG="import-config.yml" \
GITHUB_OUTPUT="/tmp/github_output.txt" \
DRY_RUN="true" \
CREATE_NEW_CONFIGS="false" \
./utilities/import-config-maintenance/maintain-import-configs.sh
```

## Viewing Results

### Check Processing Statistics

The script outputs statistics at the end:

```bash
cat /tmp/github_output.txt
```

Example output:
```
actions-processed=45
actions-updated=12
errors-found=0
error-log-path=/path/to/repo/import_configs_errors.log
```

### Check Error Log

```bash
cat import_configs_errors.log
```

### Check What Would Change (Dry-Run)

In dry-run mode, look for lines like:
```
[DRY-RUN] Would update utilities/example-action/import-config.yml
```

## Troubleshooting

### Script Not Found

If you get an error that the script doesn't exist:

```bash
# Verify you're in the correct directory
pwd
# Should show: /path/to/repo

# Check if the script exists
ls -la utilities/import-config-maintenance/maintain-import-configs.sh
```

If it doesn't exist, extract it from `action.yml` first.

### Permission Denied

If you get a permission denied error:

```bash
chmod +x utilities/import-config-maintenance/maintain-import-configs.sh
```

### Missing yq or gh Commands

If you see errors about missing commands:

```bash
# Check if yq is installed
which yq

# Check if gh is installed
which gh

# Install using the instructions in the Prerequisites section
```

### target_dirs.conf Not Found

Make sure you're running from the repository root:

```bash
cd /path/to/repo  # Must be at the root
./utilities/import-config-maintenance/maintain-import-configs.sh
```

## Important Reminders

### Source of Truth

- **The `action.yml` file is the single source of truth** for the bash script
- The `maintain-import-configs.sh` file is only for local testing and should **NOT** be committed to source control
- Always re-extract the script from `action.yml` after making changes to the action

### Re-extracting After Changes

If you make changes to the bash script in `action.yml`, you must re-extract it for local testing:

```bash
cd /path/to/repo/utilities/import-config-maintenance

# Re-extract using your preferred method
yq eval '.runs.steps[] | select(.id == "maintain-configs") | .run' action.yml > maintain-import-configs.sh

# Or using awk
awk '/- name: Maintain import configs/,/shell: bash/ {
  if (/run: \|/) { capture=1; next }
  if (/shell: bash/) { exit }
  if (capture) { sub(/^        /, ""); print }
}' action.yml > maintain-import-configs.sh
```

### .gitignore Recommendation

Add `maintain-import-configs.sh` to your `.gitignore` to prevent accidentally committing the extracted file:

```bash
# In utilities/import-config-maintenance/.gitignore or root .gitignore
utilities/import-config-maintenance/maintain-import-configs.sh
```

## Comparing with Production Script

To ensure your local script matches the action:

```bash
# Extract the latest version
yq eval '.runs.steps[] | select(.id == "maintain-configs") | .run' action.yml > /tmp/latest-script.sh

# Compare with your local version
diff utilities/import-config-maintenance/maintain-import-configs.sh /tmp/latest-script.sh
```

If there are differences, re-extract the script.

## Advanced Usage

### Running Against Specific Directories

You can modify the `target_dirs.conf` file temporarily or create a custom config:

```bash
# Create a custom config for testing
echo "utilities" > test_dirs.conf

# Run with custom config
export FILE_TARGET_DIRS="test_dirs.conf"
./utilities/import-config-maintenance/maintain-import-configs.sh
```

### Capturing Output for Analysis

```bash
# Run and capture all output
./utilities/import-config-maintenance/maintain-import-configs.sh 2>&1 | tee run_output.log

# Search for updates
grep "UPDATE" run_output.log

# Search for errors
grep "ERROR" run_output.log
```

### Testing Changes Before Committing

```bash
# 1. Create a feature branch
git checkout -b test-import-config-updates

# 2. Run in dry-run mode first
export DRY_RUN="true"
./utilities/import-config-maintenance/maintain-import-configs.sh

# 3. Review what would change
# ... check output ...

# 4. Run in live mode
export DRY_RUN="false"
./utilities/import-config-maintenance/maintain-import-configs.sh

# 5. Review changes
git status
git diff

# 6. If satisfied, commit
git add */*/import-config.yml
git commit -m "chore: update import-config.yml files"
```
