#!/bin/bash

# Prompt for required inputs
# read -p "Enter the GitHub repo owner: " sourceActionRepoOwner
# read -p "Enter the GitHub repo name: " sourceActionRepoName
# read -p "Enter the GitHub repo tag: " sourceActionRepoTag
# read -p "Enter the GitHub repo commit: " sourceActionRepoCommit

# Load environment variables from .env file
if [[ -f .env ]]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found. Exiting."
    exit 1
fi

# old #read -p "Enter the GitHub repo .zip URL: " zip_url
# old #read -p "Enter the commit or tag (leave empty if not applicable): " ref
# old #read -p "Enter the target directory to extract the zip file: " target_dir
# old #read -p "Enter the action type to extract the zip file: " action_type_dir
# old #read -p "Enter the subdirectory name for extracted files: " sub_dir

#### example URLs for a repo
# example repo and commit info:
#   - commit: 8675309ee8675309ffgg86753097hh8675309hhi
#   - repo owner: gh_repo_owner
#   - repo name: gh_repo_name
#   - tag: v1.2.3
# commit URL:  https://github.com/gh_repo_owner/gh_repo_name/tree/8675309ee8675309ffgg86753097hh8675309hhi
#   - zip file:  https://github.com/gh_repo_owner/gh_repo_name/archive/8675309ee8675309ffgg86753097hh8675309hhi.zip
# tag URL:  https://github.com/gh_repo_owner/gh_repo_name/releases/tag/v1.2.3
#   - zip file:  https://github.com/gh_repo_owner/gh_repo_name/archive/refs/tags/v1.2.3.zip

# Define the source repo and tag URLs
source_action_name_tag="${sourceActionRepoName}-${sourceActionRepoTag}"
source_tag_zip_url=https://github.com/${sourceActionRepoOwner}/${sourceActionRepoName}/archive/refs/tags/${sourceActionRepoTag}.zip
source_tag_release_url=https://github.com/${sourceActionRepoOwner}/${sourceActionRepoName}/releases/tag/${sourceActionRepoTag}
source_commit_files_url=https://github.com/${sourceActionRepoOwner}/${sourceActionRepoName}/tree/${sourceActionRepoCommit}
source_commit_zip_url=https://github.com/${sourceActionRepoOwner}/${sourceActionRepoName}/archive/${sourceActionRepoCommit}.zip
#source_action_import_temp="temp-${sourceActionRepoName}"
zip_url=${source_tag_zip_url}

# Define the final extraction path
#extraction_path="$target_dir/$sub_dir"
#extraction_path="${action_type_dir}/$sub_dir"
#extraction_path="_pending_import/${source_action_name_tag}"
#extraction_path="_pending_import/${source_action_import_temp}"
extraction_path="_pending_import"
#extraction_path=${sourceActionGroup}

if [[ -d "${extraction_path}" ]]; then
    echo "  The extraction path already exists: ${extraction_path} "
else
    echo "  The extraction path DOES NOT exist, creating directory: ${extraction_path} "
    mkdir -p "${extraction_path}"
fi

# # Form the final URL with the reference, if provided
# if [[ -n "$ref" ]]; then
#     zip_url="${zip_url/tree/main/${ref}}"
# fi

# Create a temporary directory to download the .zip file
temp_dir=$(mktemp -d)
zip_file="$temp_dir/tempzip-${sourceActionRepoName}-${sourceActionRepoTag}.zip"

# Download the .zip file
echo "Downloading .zip file from: ${zip_url}"
curl -L -o "${zip_file}" "${zip_url}"

# Check if download was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to download the .zip file. Exiting."
    rm -rf "$temp_dir"
    exit 1
else
    echo "The download exit code was $?, continuing... "
fi

# Extract the .zip file to the specified path
echo "Extracting .zip file to: ${extraction_path}"
unzip -q "${zip_file}" -d "${extraction_path}"

# Check if extracting the .zip file was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to extract the .zip file. Exiting."
    rm -rf "${extraction_path}"
    rm -rf "$temp_dir"
    exit 1
else
    echo "Successfully extracted the .zip file. The exit code was $?, continuing... "
fi

# Find the actual directory where the files were extracted
inner_dir=$(find "${extraction_path}" -mindepth 1 -maxdepth 1 -type d)

# declare old and new '.github' directories
old_github_dir="${inner_dir}/.github"
dot_github_dir="${inner_dir}/__dot_github"

if [[ -d "${inner_dir}" ]]; then
    echo "Inner directory found: ${inner_dir}"
else
    echo "No inner directory found within extraction path."
fi

# Check if an inner directory was found
if [[ -n "${inner_dir}" ]]; then
    # Look for the `.github` directory within the inner directory
    if [[ -d "${old_github_dir}" ]]; then
        echo "Renaming .github to __dot_github"
        mkdir -p "${dot_github_dir}"
        rsync -a "${old_github_dir}/" "${dot_github_dir}/"
        rm -rf "${old_github_dir}"
        #mv "${old_github_dir}/*" "${dot_github_dir}"
        #rmdir "${old_github_dir}"
        #
        if [[ -d "${dot_github_dir}" ]]; then
            # rename the '.yml' file(s) in the '__dot_github' directory
            gh_yml_search=$(find ${dot_github_dir} -type f -name '*.yml')
            #for f in "${dot_github_dir}/*.yml"; do
            for f in "${gh_yml_search}"; do
                #fdir=$(dirname "$f")
                file=$(basename "$f")
                echo "    renaming '$file' to '$file.disabled' "
                mv -f "$f" "$f.disabled"
            done
            # # rename the '.yml' file(s) in the '__dot_github/workflows' directory
            # wf_yml_search=$(find "${dot_github_dir}/workflows" -type f -name *.yml)
            # #for f in "${dot_github_dir}/workflows/*.yml"; do
            # for f in "${wf_yml_search}"; do
            #     echo "    renaming $f to $f.disabled "
            #     mv "$f" "$f.disabled"
            # done
            #
        else
            echo "the '__dot_github' directory was not found in extracted files."
        fi
    else
        echo "the '.github' directory was not found in extracted files."
    fi
    #
    # copy and rename the '.md' and '.yml' files in the inner directory
    if [[ -d "${inner_dir}" ]]; then
        # copy and rename the '.md' file(s)
        inner_md_search=$(find ${inner_dir} -maxdepth 1 -type f -name '*.md')
        #for f in "${inner_dir}/*.md"; do
        for f in "${inner_md_search}"; do
            file=$(basename "$f")
            echo "found file: $f "
            echo "    the file basename is $file "
            echo "    copying '$file' and renaming to '${sourceActionRepoName}__$file' "
            cp "${inner_dir}/$file" "${inner_dir}/${sourceActionRepoName}__$file"
        done
        # copy and rename the '.yml' file(s)
        inner_yml_search=$(find ${inner_dir} -maxdepth 1 -type f -name '*.yml')
        #for f in "${inner_dir}/*.yml"; do
        for f in "${inner_yml_search}"; do
            file=$(basename "$f")
            echo "found file: $f "
            echo "    the file basename is $file "
            echo "    copying '$file' and renaming to '${sourceActionRepoName}__$file' "
            cp "${inner_dir}/$file" "${inner_dir}/${sourceActionRepoName}__$file"
        done
    else
        echo "did not copy any of the '.md' or '.yml' files in the inner directory"
    fi
else
    echo "No inner directory found within extraction path."
fi

# to-do:  move the temporary directory to the final directory

# Clean up the temporary download directory
rm -rf "$temp_dir"

echo "Process complete."
