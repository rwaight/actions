# Using the Python Script with a Virtual Environment

This guide explains how to set up and run the `api-get-tracks.py` script within a Python virtual environment.

> **Important Note**: The canonical source of the Python script is in the `action.yml` file within the `run-get-tracks-api` step. For local testing, you can extract the script to a standalone file using the instructions below.

## Prerequisites

- Python 3.7 or higher installed on your system
- Access to a terminal/command line
- `yq` command-line YAML processor (for extracting the script from `action.yml`)

## Extracting the Script from action.yml

The Python script is embedded in the `action.yml` file and must be extracted for local testing. The script in `action.yml` is the single source of truth.

### Installing yq (if not already installed)

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

### Extracting the Script

Navigate to the `instruqt/api-get-tracks` directory and run this command to extract the Python script from the `action.yml` file:

```bash
cd /path/to/repo/instruqt/api-get-tracks

# Extract the script from action.yml
yq eval '.runs.steps[] | select(.id == "run-get-tracks-api") | .run' action.yml > api-get-tracks.py
```

**Alternative method using sed (if yq is not available)**:

```bash
cd /path/to/repo/instruqt/api-get-tracks

# Extract everything between 'run: |' and 'shell: python' from the run-get-tracks-api step
sed -n '/- name: Run inline Python script to get tracks via Instruqt API/,/shell: python/p' action.yml | \
  sed -n '/run: |/,/shell: python/p' | \
  sed '1d;$d' | \
  sed 's/^        //' > api-get-tracks.py
```

**Simpler alternative using awk**:

```bash
cd /path/to/repo/instruqt/api-get-tracks

# Extract and fix indentation
awk '/- name: Run inline Python script to get tracks via Instruqt API/,/shell: python/ {
  if (/run: \|/) { capture=1; next }
  if (/shell: python/) { exit }
  if (capture) { sub(/^        /, ""); print }
}' action.yml > api-get-tracks.py
```

### Verify the Extraction

After extracting, verify the script looks correct:

```bash
# Check the first few lines
head -20 api-get-tracks.py

# Verify it's valid Python syntax
python3 -m py_compile api-get-tracks.py
```

The extracted file should start with the docstring and imports:

```python
"""
Instruqt GraphQL API Client - Get Tracks
...
```

## Setup Instructions

### 1. Create a Virtual Environment

Navigate to the repository root directory and create a virtual environment named `.venv`:

```bash
cd /path/to/repo/
python3 -m venv .venv
```

### 2. Activate the Virtual Environment

Activate the virtual environment using the appropriate command for your shell:

**On macOS/Linux (bash/zsh)**:
```bash
source .venv/bin/activate
```

**On Windows (PowerShell)**:
```powershell
.venv\Scripts\Activate.ps1
```

**On Windows (Command Prompt)**:
```cmd
.venv\Scripts\activate.bat
```

Once activated, your terminal prompt should be prefixed with `(.venv)`.

### 3. Install Dependencies

The script automatically installs the `requests` library if it's not found. However, you can manually install it:

```bash
pip install requests
```

Or specify a specific version using the `REQUESTS_VERSION` environment variable (see Configuration section below).

## Running the Script

### Option 1: With Activated Virtual Environment

After activating the virtual environment (step 2), navigate to the script directory and run it:

```bash
cd instruqt/api-get-tracks
python api-get-tracks.py
```

### Option 2: Without Activating (Direct Path)

You can run the script directly using the virtual environment's Python executable without activating it:

```bash
cd /path/to/repo/instruqt/api-get-tracks
/path/to/repo/.venv/bin/python api-get-tracks.py
```

Or from anywhere in the repository:

```bash
/path/to/repo/.venv/bin/python instruqt/api-get-tracks/api-get-tracks.py
```

## Configuration

### Required Environment Variables

Set the required environment variable before running the script:

```bash
export INSTRUQT_TOKEN="your-api-token-here"
```

### Optional Environment Variables

```bash
# Specify a team workspace (if not set, auto-detects from API key)
export TEAM_WORKSPACE="your-team-slug"

# Enable verbose output to print the full track list
export VERBOSE="true"

# Pin the requests module to a specific version
export REQUESTS_VERSION="2.32.3"
```

### Using a .env File

Alternatively, create a `.env` file in the `instruqt/api-get-tracks` directory:

```bash
# .env file example
INSTRUQT_TOKEN="your-api-token-here"
# TEAM_WORKSPACE="your-team-slug"  # Optional
# VERBOSE="false"
# REQUESTS_VERSION="2.32.3"
```

The script will automatically load variables from the `.env` file if the `python-dotenv` package is installed:

```bash
pip install python-dotenv
```

## Complete Example Workflow

Here's a complete example from start to finish:

```bash
# 1. Navigate to the repository root
cd /path/to/repo

# 2. Create virtual environment (one-time setup)
python3 -m venv .venv

# 3. Activate the virtual environment
source .venv/bin/activate

# 4. Install python-dotenv (optional, for .env file support)
pip install python-dotenv

# 5. Navigate to the script directory
cd instruqt/api-get-tracks

# 6. Extract the Python script from action.yml
yq eval '.runs.steps[] | select(.id == "run-get-tracks-api") | .run' action.yml > api-get-tracks.py

# Or if yq is not available, use awk:
# awk '/- name: Run inline Python script to get tracks via Instruqt API/,/shell: python/ {
#   if (/run: \|/) { capture=1; next }
#   if (/shell: python/) { exit }
#   if (capture) { sub(/^        /, ""); print }
# }' action.yml > api-get-tracks.py

# 7. Create or edit your .env file
echo 'INSTRUQT_TOKEN="your-token-here"' > .env

# 8. Run the script
python api-get-tracks.py

# 9. Deactivate virtual environment when done
deactivate
```

## Running with Environment Variables (No .env file)

If you prefer not to use a `.env` file, you can pass environment variables inline:

```bash
# With activated virtual environment
cd /path/to/repo/instruqt/api-get-tracks
INSTRUQT_TOKEN="your-token-here" python api-get-tracks.py

# Without activating (using direct path)
INSTRUQT_TOKEN="your-token-here" \
/path/to/repo/.venv/bin/python \
/path/to/repo/instruqt/api-get-tracks/api-get-tracks.py
```

With multiple environment variables:

```bash
INSTRUQT_TOKEN="your-token-here" \
TEAM_WORKSPACE="my-team" \
VERBOSE="true" \
/path/to/repo/.venv/bin/python \
/path/to/repo/instruqt/api-get-tracks/api-get-tracks.py
```

## Deactivating the Virtual Environment

When you're done working, deactivate the virtual environment:

```bash
deactivate
```

## Troubleshooting

### Virtual Environment Not Found

If you get an error that the virtual environment doesn't exist, make sure you created it in the correct location:

```bash
ls -la /path/to/repo/.venv
```

If it doesn't exist, create it:

```bash
cd /path/to/repo
python3 -m venv .venv
```

### Permission Denied

If you get a permission denied error when trying to activate the virtual environment:

```bash
chmod +x /path/to/repo/.venv/bin/activate
```

### Module Not Found

If you see "`ModuleNotFoundError: No module named 'requests'`", the script will automatically attempt to install it. If automatic installation fails, manually install it:

```bash
source /path/to/repo/.venv/bin/activate
pip install requests
```

Or using the direct path:

```bash
/path/to/repo/.venv/bin/pip install requests
```

## Important Reminders

### Source of Truth

- **The `action.yml` file is the single source of truth** for the Python script
- The `api-get-tracks.py` file is only for local testing and should **NOT** be committed to source control
- Always re-extract the script from `action.yml` after making changes to the action

### Re-extracting After Changes

If you make changes to the Python script in `action.yml`, you must re-extract it for local testing:

```bash
cd /path/to/repo/instruqt/api-get-tracks

# Re-extract using your preferred method
yq eval '.runs.steps[] | select(.id == "run-get-tracks-api") | .run' action.yml > api-get-tracks.py

# Or using awk
awk '/- name: Run inline Python script to get tracks via Instruqt API/,/shell: python/ {
  if (/run: \|/) { capture=1; next }
  if (/shell: python/) { exit }
  if (capture) { sub(/^        /, ""); print }
}' action.yml > api-get-tracks.py
```

### .gitignore Recommendation

Add `api-get-tracks.py` to your `.gitignore` to prevent accidentally committing the extracted file:

```bash
# In instruqt/api-get-tracks/.gitignore or root .gitignore
instruqt/api-get-tracks/api-get-tracks.py
```
