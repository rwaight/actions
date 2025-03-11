#!/bin/bash

# Define the error log file
error_log="import_configs_errors.log"
> "$error_log"  # Clear the log file at the start

# Print yq and jq versions for debugging
#echo "Running yq version: $(yq --version 2>&1)" | tee -a "$error_log"
echo "Running yq version: $(yq --version 2>&1)" >> "$error_log"
#echo "Running jq version: $(jq --version 2>&1)" | tee -a "$error_log"
echo "Running jq version: $(jq --version 2>&1)" >> "$error_log"

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Default exclusions array
default_exclusions=("README-examples.md" "example-custom-notes.md")

# Default import config file
default_config="import-config.yml"

# Array to track errors
error_actions=()

# Function to read the action.yml or action.yaml file
function read_action_file() {
    local action_dir=$1
    if [[ -f "${action_dir}/action.yml" ]]; then
        echo "${action_dir}/action.yml"
    elif [[ -f "${action_dir}/action.yaml" ]]; then
        echo "${action_dir}/action.yaml"
    else
        echo ""
    fi
}

# Function to sanitize values (removes backticks to avoid parsing issues)
function sanitize_value() {
    local value="$1"
    local sanitized_value=""
    #
    # Iterate through each character in the string
    for ((i=0; i<${#value}; i++)); do
        char="${value:$i:1}"
        #
        # Skip backticks (`), double quotes ("), and single quotes (')
        if [[ "$char" != "\"" && "$char" != "'" && "$char" != "\`" ]]; then
            sanitized_value+="$char"
        fi
    done
    #
    # Log warning if any modifications were made
    if [[ "$sanitized_value" != "$value" ]]; then
        #echo "[WARNING] Special characters removed: $value → $sanitized_value" | tee -a "$error_log"
        echo "[WARNING] Special characters removed: $value → $sanitized_value" >> "$error_log"
    fi
    #
    echo "$sanitized_value"
}

# Function to fetch the latest version from GitHub API
function fetch_latest_version() {
    local repo_owner="$1"
    local repo_name="$2"
    #
    # using 'curl' with the GitHub API now requires an access token
    ##latest_version=$(curl -s "https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" | jq -r .tag_name)
    # use 'gh release' or 'gh api' to fetch the latest version
    # https://docs.github.com/rest/releases/releases#get-the-latest-release
    latest_version=$(gh release list --json name,tagName,isLatest --jq '.[] | select(.isLatest)|.tagName' --repo "${repo_owner}/${repo_name}")
    #latest_version=$(gh release list --json name,tagName,isLatest --jq '.[] | select(.isLatest)|.tagName' --repo "${repo_owner}/${repo_name}")
    #latest_version=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${repo_owner}/${repo_name}/releases/latest")
    #
    if [[ "$latest_version" == "null" || -z "$latest_version" ]]; then
        #echo "[ERROR] Unable to fetch latest version for $repo_owner/$repo_name" | tee -a "$error_log"
        #latest_version=""
        echo "[ERROR] Unable to fetch latest version for $repo_owner/$repo_name" >> "$error_log"
        latest_version="error"
    fi
    #
    echo "$latest_version"
}

# Function to create or update import-config.yml for each action
function create_or_update_import_config() {
    local group_dir=$1
    local action_dir=$2
    # Set initial values for import-config.yml
    local group=$(basename "$group_dir")
    local name=$(basename "$action_dir")
    local import_config_file="${group_dir}/${action_dir}/import-config.yml"

    echo "Processing: Group = $group_dir, Action = $action_dir"

    # Determine the action file (either action.yml or action.yaml)
    action_file=$(read_action_file "${group_dir}/${action_dir}")
    if [[ -z "$action_file" ]]; then
        #echo "No action.yml or action.yaml found in ${group_dir}/${action_dir}. Skipping..."
        echo "[ERROR] No action.yml or action.yaml found in ${group_dir}/${action_dir}. Skipping..." | tee -a "$error_log"
        return
    fi

    # Extract the action file extension
    action_file_extension=$(basename "$action_file")
    #
    # the commented out code below worked prior to adding error checks
    # # Read first level keys of author, description, inputs, outputs, and runs from the action file
    # author=$(yq e '.author' "$action_file")
    # if [[ "$author" == "null" ]]; then unset author; fi
    # description=$(yq e '.description' "$action_file")
    # if [[ "$description" == "null" ]]; then unset description; fi
    # inputs=$(yq e '.inputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    # outputs=$(yq e '.outputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    # runs_using=$(yq e '.runs.using' "$action_file")
    # runs_main=$(yq e '.runs.main' "$action_file")
    # if [[ "$runs_main" == "null" ]]; then unset runs_main; fi
    # the commented out code above worked prior to adding error checks
    #
    # Read required fields from action file while filtering out null values
    {
        #author=$(sanitize_value "$(yq e '.author // "placeholder"' "$action_file" 2>/dev/null)")
        author=$(yq e '.author' "$action_file")
        if [[ "$author" == "null" ]]; then unset author; fi
        #
        #description=$(sanitize_value "$(yq e '.description // "placeholder"' "$action_file" 2>/dev/null)")
        description=$(yq e '.description' "$action_file")
        if [[ "$description" == "null" ]]; then unset description; fi
        #inputs=$(sanitize_value "$(yq e '.inputs | select(. != null) | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')")
        #nope#inputs=$(yq e '.inputs | select(. != null) | keys' "$action_file" 2>/dev/null | grep -v '^#')
        #inputs=$(yq e '.inputs | select(. != null) | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
        inputs=$(yq e '.inputs | select(. != null) | keys' "$action_file" | grep -v '^#' | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
        #outputs=$(sanitize_value "$(yq e '.outputs | select(. != null) | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')")
        #nope#outputs=$(yq e '.outputs | select(. != null) | keys' "$action_file" 2>/dev/null | grep -v '^#')
        #outputs=$(yq e '.outputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
        outputs=$(yq e '.outputs | keys' "$action_file" | grep -v '^#' | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
        runs_using=$(sanitize_value "$(yq e '.runs.using // empty' "$action_file" 2>/dev/null)")
        runs_main=$(sanitize_value "$(yq e '.runs.main // empty' "$action_file" 2>/dev/null)")
    } || {
        echo "[ERROR] A general issue occurred while reading fields in $action_file" | tee -a "$error_log"
        error_actions+=("${group_dir}/${action_dir}")
        return
    }

    #import_config_file="${group_dir}/${action_dir}/import-config.yml"
    import_config_file="${group_dir}/${action_dir}/${default_config}"
    # check to see if the import-config.yml file exists
    if [[ -f $import_config_file ]]; then
        #echo "" # Improve CLI readability
        #echo -n "Processing ${group_dir}/${action_dir} ... "
        echo "    Checking ${default_config} ..."
        #
        # Read existing import-config.yml
        import_config=$(yq eval '.' "$import_config_file")
        #
        # =( # this was SKIPPED in 'import_configs_broken.sh' # =( #
        # Update author, description, specs.action_file, specs.inputs, and specs.outputs fields
        if [[ -n $author ]]; then
            yq e -i ".author = \"$author\"" "$import_config_file"
        else
            yq e -i ".author = \"placeholder\"" "$import_config_file"
        fi
        #
        if [[ -n $description ]]; then
            yq e -i ".description = \"$description\"" "$import_config_file"
        else
            yq e -i ".description = \"placeholder\"" "$import_config_file"
        fi
        yq e -i ".specs.action_file = \"$action_file_extension\"" "$import_config_file"
        yq e -i ".specs.inputs = [$inputs]" "$import_config_file"
        yq -i '.specs.inputs style="flow"' "$import_config_file"
        #import_config=$(echo "$import_config" | yq eval ".specs.inputs = [$inputs]" -)
        yq e -i ".specs.outputs = [$outputs]" "$import_config_file"
        yq -i '.specs.outputs style="flow"' "$import_config_file"
        #import_config=$(echo "$import_config" | yq eval ".specs.outputs = [$outputs]" -)
        #
        # Update runs field if using and main are present
        if [[ -n $runs_using ]]; then
            yq e -i ".specs.runs.using = \"$runs_using\"" "$import_config_file"
            #import_config=$(echo "$import_config" | yq eval ".specs.runs.using = \"$runs_using\"" -)
            if [[ -n $runs_main ]]; then
                yq e -i ".specs.runs.main = \"$runs_main\"" "$import_config_file"
                #import_config=$(echo "$import_config" | yq eval ".specs.runs.main = \"$runs_main\"" -)
            else
                yq e -i "del(.specs.runs.main)" "$import_config_file"
                #import_config=$(echo "$import_config" | yq eval "del(.specs.runs.main)" -)
            fi
        fi
        #
        # Check for updates if imported
        if [[ $(yq e '.imported' "$import_config_file") == "true" ]]; then
            source_action_author=$(yq e '.source.author' "$import_config_file")
            #source_action_author=$(echo "$import_config" | yq eval '.source.author' -)
            source_repo_name=$(yq e '.source.repo_name' "$import_config_file")
            #source_repo_name=$(echo "$import_config" | yq eval '.source.repo_name' -)
            source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            current_version=$(yq e '.source.current_version' "$import_config_file")
            #current_version=$(echo "$import_config" | yq eval '.source.current_version' -)
            # did not have the 'fetch_latest_version' function before error checks
            #latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            latest_version=$(fetch_latest_version "$source_action_author" "$source_repo_name")
            # the commented out code below worked prior to adding error checks
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
            # the commented out code above worked prior to adding error checks
            # compare the current version with the latest version
            if [[ -n "$latest_version" && "$current_version" != "$latest_version" ]]; then
                yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
                #yq e -i ".source.update_available = true" "$import_config_file"
                yq e -i ".source.update_available = $update_available" "$import_config_file"
                #echo "[UPDATE] New version available for $source_repo_name: $latest_version" | tee -a "$error_log"
                echo "  [UPDATE] New version available for ${group_dir}/${action_dir}: $latest_version" | tee -a "$error_log"
            else
                #yq e -i ".source.update_available = false" "$import_config_file"
                yq e -i ".source.update_available = $update_available" "$import_config_file"
            fi
            # update the author field if it is set to 'placeholder'
            if [[ $(yq e '.author' "$import_config_file") == "placeholder" ]]; then
                yq e -i ".author = \"$source_action_author\"" "$import_config_file"
            fi
            # the commented out code below worked prior to adding error checks
            # # Update source fields
            # yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
            # #not-this#import_config=$(echo "$import_config" | yq eval ".source.latest_version = \"$latest_version\"" -)
            # yq e -i ".source.update_available = $update_available" "$import_config_file"
            # #not-this#import_config=$(echo "$import_config" | yq eval ".source.update_available = $update_available" -)
            # the commented out code above worked prior to adding error checks
        fi
        # Check if local.update.exclusions exists, and add it if missing
        exclusions_exist=$(yq e '.local.update.exclusions' "$import_config_file" 2>/dev/null)
        if [[ "$exclusions_exist" == "null" || -z "$exclusions_exist" ]]; then
            echo "Adding default exclusions to ${import_config_file}..."
            yq e -i '.local.update.exclusions = []' "$import_config_file"
        fi
        # Ensure default exclusions are present
        for exclusion in "${default_exclusions[@]}"; do
            exists=$(yq e ".local.update.exclusions | contains([\"$exclusion\"])" "$import_config_file")
            if [[ "$exists" != "true" ]]; then
                yq e -i ".local.update.exclusions += [\"$exclusion\"]" "$import_config_file"
            fi
        done
        # end of # if [[ -f $import_config_file ]]; then # block
    else
        # the import-config.yml file DOES NOT exist
        # Ask the user if the action is imported or locally created
        read -p "Is the action in ${group_dir}/${action_dir} imported or locally-created (imported/local)? " action_type
        #
        # Set initial variables
        imported=false
        local_author="rwaight"
        modifications=false
        #
        # Create an empty import-config.yml file
        echo "[INFO] Creating new ${import_config_file}..."
        touch "$import_config_file"
        #
        # =( # this was SKIPPED in 'import_configs_broken.sh' # =( #
        # Set initial fields
        yq e -i ".name = \"$name\"" "$import_config_file"
        if [[ -n $author ]]; then
            yq e -i ".author = \"$author\"" "$import_config_file"
        else
            yq e -i ".author = \"placeholder\"" "$import_config_file"
        fi
        #
        if [[ -n $description ]]; then
            yq e -i ".description = \"$description\"" "$import_config_file"
        else
            yq e -i ".description = \"placeholder\"" "$import_config_file"
        fi
        yq e -i ".group = \"$group\"" "$import_config_file"
        yq e -i ".imported = false" "$import_config_file"
        #
        # Add local and source blocks
        if [[ $action_type == "imported" ]]; then
            imported=true
            yq e -i ".imported = true" "$import_config_file"
            #
            # the commented out code below worked prior to adding error checks
            # read -p "Enter source action name [default: $name]: " source_action_name
            # source_action_name=${source_action_name:-$name}
            # read -p "Enter source action author: " source_action_author
            # read -p "Enter source GitHub repo name [default: $name]: " source_repo_name
            # source_repo_name=${source_repo_name:-$name}
            # source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            # read -p "Have there been any local modifications? (true/false): " modifications
            # read -p "Enter current version used: " current_version
            # latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            # did not have the 'fetch_latest_version' function before error checks
            # the commented out code above worked prior to adding error checks
            read -p "Enter source action name [default: $action_dir]: " source_action_name
            source_action_name=${source_action_name:-$action_dir}
            #
            read -p "Enter source action author: " source_action_author
            read -p "Enter source GitHub repo name [default: $action_dir]: " source_repo_name
            source_repo_name=${source_repo_name:-$action_dir}
            #
            source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            read -p "Have there been any local modifications? (true/false): " modifications
            read -p "Enter current version used: " current_version
            #
            latest_version=$(fetch_latest_version "$source_action_author" "$source_repo_name")
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
            #
            # =( # this was SKIPPED in 'import_configs_broken.sh' # =( #
            if [[ $(yq e '.author' "$import_config_file") == "placeholder" ]]; then
                yq e -i ".author = \"$source_action_author\"" "$import_config_file"
            fi
            #
            yq e -i ".local.modifications = $modifications" "$import_config_file"
            yq e -i ".source.action_name = \"$source_action_name\"" "$import_config_file"
            yq e -i ".source.author = \"$source_action_author\"" "$import_config_file"
            yq e -i ".source.repo_name = \"$source_repo_name\"" "$import_config_file"
            yq e -i ".source.repo_url = \"$source_repo_url\"" "$import_config_file"
            yq e -i ".source.current_version = \"$current_version\"" "$import_config_file"
            yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
            yq e -i ".source.update_available = $update_available" "$import_config_file"
            # end of # if [[ $action_type == "imported" ]]; then # block
        else
            yq e -i ".local.author = \"$local_author\"" "$import_config_file"
            yq e -i ".local.modifications = true" "$import_config_file"
        fi
        #
        # =( # this was SKIPPED in 'import_configs_broken.sh' # =( #
        # Add specs block, including action_file, inputs, outputs, and runs fields
        yq e -i ".specs.action_file = \"$action_file_extension\"" "$import_config_file"
        yq e -i ".specs.inputs = [$inputs]" "$import_config_file"
        yq -i '.specs.inputs style="flow"' "$import_config_file"
        yq e -i ".specs.outputs = [$outputs]" "$import_config_file"
        yq -i '.specs.outputs style="flow"' "$import_config_file"
        if [[ -n $runs_using ]]; then
            yq e -i ".specs.runs.using = \"$runs_using\"" "$import_config_file"
            if [[ -n $runs_main ]]; then
                yq e -i ".specs.runs.main = \"$runs_main\"" "$import_config_file"
            fi
        fi
        # Add the exclusions field with default values
        yq e -i ".local.update.exclusions = [\"README-examples.md\", \"example-custom-notes.md\"]" "$import_config_file"
        # Add tests block
        yq e -i ".tests._comment = \"reserved for future use\"" "$import_config_file"
    fi
    #
    # # Sort the import-config.yml file alphabetically
    # yq eval --inplace 'sort_keys(..)' "$import_config_file"
    #
    echo "    Processed import-config.yml for ${group_dir}/${action_dir}"
    echo ""
}

# Iterate through each group directory
for group_dir in "${target_dirs[@]}"; do
    for action_subdir in "$group_dir"/*; do
        if [[ -d "$action_subdir" ]]; then
            action_dir=$(basename "$action_subdir")
            create_or_update_import_config "$group_dir" "$action_dir"
        fi
    done
done

echo "[INFO] Finished processing. Check $error_log for error details."
