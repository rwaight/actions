# Quick Reference: Get Cloud Image Info Action

Quick copy-paste patterns for the most common use cases.

## Prerequisites

```yaml
# GCP Authentication (required before using this action)
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v3
  with:
    credentials_json: ${{ secrets.GCP_CREDENTIALS }}
```

## Basic Patterns

### Query by Image Family (Most Common)

```yaml
- name: Get latest image from family
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
```

### Query by Specific Image Name

```yaml
- name: Get specific image
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image: 'rocky-linux-8-v20240110'
```

### Search Multiple Projects

```yaml
- name: Search across projects
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'ubuntu-2204-lts'
    image-location: 'ubuntu-os-cloud,my-shared-images'
```

### With Verbose Output

```yaml
- name: Query with debugging
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    verbose: 'true'
```

### With Prefix for Full Path

```yaml
- name: Query with full image path
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'
    image-name-prefix: 'projects/rocky-linux-cloud/global/images/'
```

### With Suffix for Tagging

```yaml
- name: Query with version suffix
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'
    image-name-suffix: '-verified'
```

## Output Usage

### Basic Output Access

```yaml
- name: Display image info
  run: |
    echo "Found: ${{ steps.image-info.outputs.image-found }}"
    echo "Name: ${{ steps.image-info.outputs.image-name }}"
    echo "Family: ${{ steps.image-info.outputs.image-family }}"
    echo "Project: ${{ steps.image-info.outputs.image-project }}"
    echo "Created: ${{ steps.image-info.outputs.image-creation-timestamp }}"
```

### All Available Outputs

```yaml
- name: Show all outputs
  run: |
    echo "image-found: ${{ steps.image-info.outputs.image-found }}"
    echo "image-id: ${{ steps.image-info.outputs.image-id }}"
    echo "image-name: ${{ steps.image-info.outputs.image-name }}"
    echo "image-self-link: ${{ steps.image-info.outputs.image-self-link }}"
    echo "image-project: ${{ steps.image-info.outputs.image-project }}"
    echo "image-family: ${{ steps.image-info.outputs.image-family }}"
    echo "image-creation-timestamp: ${{ steps.image-info.outputs.image-creation-timestamp }}"
    echo "image-description: ${{ steps.image-info.outputs.image-description }}"
```

### Check if Image Found

```yaml
- name: Verify image exists
  if: steps.image-info.outputs.image-found == 'false'
  run: |
    echo "::error::Image not found!"
    exit 1
```

## Packer Integration

### Pass to Packer Environment Variables

```yaml
- name: Get source image
  id: source-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'

- name: Run Packer
  env:
    PKR_VAR_source_image: ${{ steps.source-image.outputs.image-name }}
    PKR_VAR_source_image_project_id: ${{ steps.source-image.outputs.image-project }}
  run: |
    packer init ./packer/
    packer build ./packer/build.pkr.hcl
```

### Complete Pre-Build Workflow

```yaml
# 1. Authenticate
- name: Authenticate to GCP
  uses: google-github-actions/auth@v3
  with:
    credentials_json: ${{ secrets.GCP_CREDENTIALS }}

# 2. Query source image
- name: Get source image info
  id: source-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'

# 3. Verify image exists
- name: Verify source image
  if: steps.source-image.outputs.image-found == 'false'
  run: |
    echo "::error title=Source Image Not Found::Cannot proceed with build"
    exit 1

# 4. Log image info
- name: Log source image
  run: |
    echo "::notice title=Source Image::Using ${{ steps.source-image.outputs.image-name }}"
    echo "Project: ${{ steps.source-image.outputs.image-project }}"
    echo "Family: ${{ steps.source-image.outputs.image-family }}"
    echo "Created: ${{ steps.source-image.outputs.image-creation-timestamp }}"

# 5. Run Packer
- name: Setup Packer
  uses: hashicorp/setup-packer@v3

- name: Build with Packer
  env:
    PKR_VAR_source_image: ${{ steps.source-image.outputs.image-name }}
    PKR_VAR_source_image_project_id: ${{ steps.source-image.outputs.image-project }}
  run: packer build ./packer/build.pkr.hcl
```

## Common GCP Image Families

### Rocky Linux

```yaml
# Rocky Linux 8
source-image-family: 'rocky-linux-8'
image-location: 'rocky-linux-cloud'

# Rocky Linux 9
source-image-family: 'rocky-linux-9'
image-location: 'rocky-linux-cloud'
```

### Ubuntu

```yaml
# Ubuntu 22.04 LTS
source-image-family: 'ubuntu-2204-lts'
image-location: 'ubuntu-os-cloud'

# Ubuntu 20.04 LTS
source-image-family: 'ubuntu-2004-lts'
image-location: 'ubuntu-os-cloud'
```

### Debian

```yaml
# Debian 11
source-image-family: 'debian-11'
image-location: 'debian-cloud'

# Debian 12
source-image-family: 'debian-12'
image-location: 'debian-cloud'
```

### CentOS

```yaml
# CentOS Stream 9
source-image-family: 'centos-stream-9'
image-location: 'centos-cloud'

# CentOS Stream 8
source-image-family: 'centos-stream-8'
image-location: 'centos-cloud'
```

### Windows

```yaml
# Windows Server 2022
source-image-family: 'windows-2022'
image-location: 'windows-cloud'

# Windows Server 2019
source-image-family: 'windows-2019'
image-location: 'windows-cloud'
```

## Conditional Logic Patterns

### Skip Build if Image is Recent

```yaml
- name: Get image info
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'

- name: Check image age
  id: check-age
  run: |
    CREATION_DATE="${{ steps.image-info.outputs.image-creation-timestamp }}"
    CURRENT_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    CREATION_EPOCH=$(date -d "$CREATION_DATE" +%s)
    CURRENT_EPOCH=$(date -d "$CURRENT_DATE" +%s)
    AGE_DAYS=$(( ($CURRENT_EPOCH - $CREATION_EPOCH) / 86400 ))
    echo "age-days=$AGE_DAYS" >> $GITHUB_OUTPUT

- name: Skip if recent
  if: steps.check-age.outputs.age-days < 7
  run: |
    echo "::notice::Image is less than 7 days old, skipping rebuild"
    exit 0
```

### Fallback to Different Family

```yaml
- name: Try primary image family
  id: primary-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'my-custom-rocky-8'
    image-location: 'my-project'

- name: Fallback to public image
  id: fallback-image
  if: steps.primary-image.outputs.image-found == 'false'
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'

- name: Set final image
  id: final-image
  run: |
    if [[ "${{ steps.primary-image.outputs.image-found }}" == "true" ]]; then
      echo "image-name=${{ steps.primary-image.outputs.image-name }}" >> $GITHUB_OUTPUT
      echo "image-project=${{ steps.primary-image.outputs.image-project }}" >> $GITHUB_OUTPUT
    else
      echo "image-name=${{ steps.fallback-image.outputs.image-name }}" >> $GITHUB_OUTPUT
      echo "image-project=${{ steps.fallback-image.outputs.image-project }}" >> $GITHUB_OUTPUT
    fi
```

## Debugging Patterns

### Enable Verbose Based on Runner Debug

```yaml
- name: Query image
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}
```

### Create Debug Output File

```yaml
- name: Get image info
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'
    verbose: 'true'

- name: Save debug info
  run: |
    cat > image-debug.json <<EOF
    {
      "image_found": "${{ steps.image-info.outputs.image-found }}",
      "image_name": "${{ steps.image-info.outputs.image-name }}",
      "image_project": "${{ steps.image-info.outputs.image-project }}",
      "image_family": "${{ steps.image-info.outputs.image-family }}",
      "image_created": "${{ steps.image-info.outputs.image-creation-timestamp }}",
      "image_self_link": "${{ steps.image-info.outputs.image-self-link }}"
    }
    EOF
  shell: bash

- name: Upload debug info
  uses: actions/upload-artifact@v4
  with:
    name: image-debug-info
    path: image-debug.json
```

## Workflow Input Integration

### Use Workflow Dispatch Input

```yaml
name: Build Custom Image

on:
  workflow_dispatch:
    inputs:
      source_image_family:
        description: 'Source image family'
        required: true
        default: 'rocky-linux-8'
        type: choice
        options:
          - rocky-linux-8
          - rocky-linux-9
          - ubuntu-2204-lts
          - debian-11

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v3
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Get source image
        id: source-image
        uses: rwaight/actions/utilities/image-info@main
        with:
          cloud-provider: 'gcp'
          query-location: ${{ secrets.GCP_PROJECT_ID }}
          source-image-family: ${{ inputs.source_image_family }}
```

### Use Matrix Strategy

```yaml
strategy:
  matrix:
    os_family:
      - rocky-linux-8
      - rocky-linux-9
      - ubuntu-2204-lts

steps:
  - name: Authenticate to GCP
    uses: google-github-actions/auth@v3
    with:
      credentials_json: ${{ secrets.GCP_CREDENTIALS }}

  - name: Get source image for ${{ matrix.os_family }}
    id: source-image
    uses: rwaight/actions/utilities/image-info@main
    with:
      cloud-provider: 'gcp'
      query-location: ${{ secrets.GCP_PROJECT_ID }}
      source-image-family: ${{ matrix.os_family }}
```

## Error Handling

### Graceful Failure

```yaml
- name: Try to get image
  id: image-info
  continue-on-error: true
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'might-not-exist'

- name: Handle missing image
  if: steps.image-info.outputs.image-found != 'true'
  run: |
    echo "::warning::Image not found, using default"
    echo "IMAGE_NAME=default-image" >> $GITHUB_ENV
```

### Required Image Check

```yaml
- name: Get required image
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'

- name: Fail if not found
  if: steps.image-info.outputs.image-found != 'true'
  run: |
    echo "::error title=Image Required::Source image is required for this build"
    exit 1
```

## Metadata and Logging

### Create Build Metadata File

```yaml
- name: Get source image
  id: source-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'

- name: Create metadata
  run: |
    cat > build-metadata.json <<EOF
    {
      "source_image": {
        "name": "${{ steps.source-image.outputs.image-name }}",
        "project": "${{ steps.source-image.outputs.image-project }}",
        "family": "${{ steps.source-image.outputs.image-family }}",
        "created": "${{ steps.source-image.outputs.image-creation-timestamp }}",
        "description": "${{ steps.source-image.outputs.image-description }}"
      },
      "build_info": {
        "run_id": "${{ github.run_id }}",
        "run_number": "${{ github.run_number }}",
        "actor": "${{ github.actor }}",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      }
    }
    EOF
  shell: bash

- name: Upload metadata
  uses: actions/upload-artifact@v4
  with:
    name: build-metadata
    path: build-metadata.json
```

### Add Job Summary

```yaml
- name: Get image info
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'

- name: Add to job summary
  run: |
    cat >> $GITHUB_STEP_SUMMARY <<EOF
    ## Source Image Information
    
    | Property | Value |
    |----------|-------|
    | Name | \`${{ steps.image-info.outputs.image-name }}\` |
    | Project | \`${{ steps.image-info.outputs.image-project }}\` |
    | Family | \`${{ steps.image-info.outputs.image-family }}\` |
    | Created | ${{ steps.image-info.outputs.image-creation-timestamp }} |
    | Self Link | ${{ steps.image-info.outputs.image-self-link }} |
    EOF
  shell: bash
```

## Troubleshooting

### Not Finding Image in Expected Project

```yaml
# Enable verbose to see which projects are searched
- name: Debug image search
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'my-image-family'
    image-location: 'project-1,project-2,project-3'
    verbose: 'true'
```

### Verify GCP Authentication

```yaml
- name: Check GCP auth
  run: gcloud auth list

- name: Try to list images manually
  run: |
    gcloud compute images list \
      --project=${{ secrets.GCP_PROJECT_ID }} \
      --filter="family:rocky-linux-8" \
      --limit=5
  shell: bash
```

### Compare with Manual gcloud Command

```bash
# Test locally what the action would run
gcloud compute images describe-from-family rocky-linux-8 \
  --project=rocky-linux-cloud \
  --format=json
```
