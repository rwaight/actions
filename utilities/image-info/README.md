# Get Cloud Image Information Action

A composite GitHub Action to query cloud providers (GCP and AWS) for source image information before running Packer builds.

Reference GitHub's [creating a composite action guide](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) for more information.

## Overview

This action provides a way to query cloud providers for image information **before** running Packer. Packer doesn't have a good way to get image info before it runs, so this action fills that gap by querying the cloud provider's API and returning the image details that can be used in subsequent workflow steps.

### Key Features

- ✅ **GCP Support**: Query Google Cloud Platform for images by name or family
- ✅ **Multiple Project Search**: Search across multiple GCP projects for source images
- ✅ **Family Resolution**: Automatically get the latest non-deprecated image from a family
- ✅ **Prefix/Suffix Patterns**: Apply prefix or suffix patterns to image names in outputs
- ✅ **Consolidated Inputs**: Simplified input structure for cross-cloud compatibility
- ✅ **AWS Placeholder**: Structure ready for AWS AMI queries (not yet implemented)
- ✅ **Comprehensive Outputs**: Returns image ID, name, self-link, family, creation date, and more
- ✅ **Verbose Mode**: Detailed logging for debugging

**Note:** Cloud provider authentication (GCP or AWS) must be configured **before** calling this action.

## Prerequisites

- **GCP**: GCP authentication must be configured using [`google-github-actions/auth`](https://github.com/google-github-actions/auth) before calling this action.
- **AWS**: AWS credentials must be configured using [`aws-actions/configure-aws-credentials`](https://github.com/aws-actions/configure-aws-credentials) (placeholder - not fully implemented).
- **Linux runner**: This action only supports Linux runners.
- **gcloud CLI**: Must be available on the runner (pre-installed on GitHub-hosted Ubuntu runners).

## Use Case

### The Problem

When using Packer with `source_image_family`, you might want to know **which specific image** will be used before Packer starts. Packer resolves this internally during the build, but there's no easy way to get this information beforehand for:

- Logging and auditing
- Conditional workflow logic
- Image verification
- Build metadata
- Troubleshooting

### The Solution

This action queries the cloud provider's API using the same logic Packer would use:

1. Search for images by exact name OR by family
2. When using family, get the latest non-deprecated image
3. Return all relevant image information
4. Use this info in your workflow (pass to Packer vars, log it, make decisions, etc.)

## Deploying this action

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `cloud-provider` | The cloud provider to query (`gcp` or `aws`) | Yes | - |
| `query-location` | GCP project ID or AWS region to query | Yes | - |
| `source-image` | Specific source image name. Takes precedence over `source-image-family` | No | `''` |
| `source-image-family` | Source image family name. Returns latest non-deprecated image | No | `''` |
| `image-location` | Location where source image resides. **GCP**: project ID(s) (comma-separated). **AWS**: AMI owner ID. Falls back to `query-location` if not specified | No | `''` |
| `image-name-prefix` | Prefix pattern to prepend to image name output | No | `''` |
| `image-name-suffix` | Suffix pattern to append to image name output | No | `''` |
| `verbose` | Enable verbose logging | No | `false` |

**Input Consolidation Notes**:

- `query-location`: For GCP, this is your project ID. For AWS, this is the region (e.g., `us-east-1`)
- `image-location`: For GCP, this is the project ID(s) where images are stored (can search multiple). For AWS, this is the AMI owner ID

### Outputs

| Output | Description |
|--------|-------------|
| `image-found` | Whether a matching image was found (`true`/`false`) |
| `image-id` | The image ID (GCP: full image name, AWS: AMI ID) |
| `image-name` | The image name |
| `image-self-link` | The self-link URL to the image (GCP only) |
| `image-project` | The project ID where the image was found (GCP only) |
| `image-family` | The image family |
| `image-creation-timestamp` | When the image was created |
| `image-description` | The image description |

## Example Usage

### Basic GCP Image Query by Family

Query GCP for the latest image in a family:

```yaml
name: Get GCP Image Info

on: [push]

jobs:
  get-image-info:
    runs-on: ubuntu-latest
    steps:
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v3
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Query for Rocky Linux 8 image
        id: query-image
        uses: rwaight/actions/utilities/image-info@main
        with:
          cloud-provider: 'gcp'
          query-location: 'my-gcp-project'
          source-image-family: 'rocky-linux-8'

      - name: Display image information
        run: |
          echo "Image found: ${{ steps.query-image.outputs.image-found }}"
          echo "Image name: ${{ steps.query-image.outputs.image-name }}"
          echo "Image family: ${{ steps.query-image.outputs.image-family }}"
          echo "Created: ${{ steps.query-image.outputs.image-creation-timestamp }}"
```

### Query Specific Image by Name

Search for a specific image by exact name:

```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v3
  with:
    credentials_json: ${{ secrets.GCP_CREDENTIALS }}

- name: Query for specific image
  id: query-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-gcp-project'
    source-image: 'rocky-linux-8-v20240110'

- name: Verify image was found
  if: steps.query-image.outputs.image-found == 'false'
  run: |
    echo "::error title=Image not found::Could not find the specified image"
    exit 1
```

### Search Across Multiple Projects

Search for images across multiple GCP projects (useful for shared image repositories):

```yaml
- name: Query across multiple projects
  id: query-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'ubuntu-2204-lts'
    image-location: 'ubuntu-os-cloud,my-shared-images,my-project'
    verbose: 'true'
```

The action will search projects in order and return the first match.

### Use Prefix/Suffix Patterns

Apply prefix or suffix patterns to the image name output:

```yaml
- name: Query with prefix for full path
  id: query-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'
    image-name-prefix: 'projects/rocky-linux-cloud/global/images/'

- name: Display full image path
  run: |
    echo "Full image path: ${{ steps.query-image.outputs.image-name }}"
    # Output: projects/rocky-linux-cloud/global/images/rocky-linux-8-optimized-gcp-v20240110
```

Or add a suffix for versioning:

```yaml
- name: Query with suffix
  id: query-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image: 'my-base-image'
    image-name-suffix: '-verified'
```

### Use with Packer Build

Get image info before running Packer, then pass it to Packer as variables:

```yaml
jobs:
  build-image:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v3
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Get source image information
        id: source-image
        uses: rwaight/actions/utilities/image-info@main
        with:
          cloud-provider: 'gcp'
          query-location: 'my-gcp-project'
          source-image-family: 'rocky-linux-8'
          image-location: 'rocky-linux-cloud'

      - name: Verify source image exists
        if: steps.source-image.outputs.image-found == 'false'
        run: |
          echo "::error title=Source image not found::Cannot proceed with build"
          exit 1

      - name: Log source image details
        run: |
          echo "Building from source image:"
          echo "  Name: ${{ steps.source-image.outputs.image-name }}"
          echo "  Project: ${{ steps.source-image.outputs.image-project }}"
          echo "  Family: ${{ steps.source-image.outputs.image-family }}"
          echo "  Created: ${{ steps.source-image.outputs.image-creation-timestamp }}"

      - name: Setup Packer
        uses: hashicorp/setup-packer@v3

      - name: Run Packer build
        env:
          PKR_VAR_source_image: ${{ steps.source-image.outputs.image-name }}
          PKR_VAR_source_image_project_id: ${{ steps.source-image.outputs.image-project }}
        run: |
          packer init ./packer/
          packer build ./packer/gcp-build.pkr.hcl
```


### Conditional Logic Based on Image

Use image information to make workflow decisions:

```yaml
- name: Get image info
  id: image-info
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'my-base-image'

- name: Check image age
  id: check-age
  run: |
    CREATION_DATE="${{ steps.image-info.outputs.image-creation-timestamp }}"
    CURRENT_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Convert to epoch for comparison
    CREATION_EPOCH=$(date -d "$CREATION_DATE" +%s)
    CURRENT_EPOCH=$(date -d "$CURRENT_DATE" +%s)
    
    # Calculate age in days
    AGE_DAYS=$(( ($CURRENT_EPOCH - $CREATION_EPOCH) / 86400 ))
    
    echo "Image is $AGE_DAYS days old"
    echo "age-days=$AGE_DAYS" >> $GITHUB_OUTPUT

- name: Skip build if image is recent
  if: steps.check-age.outputs.age-days < 7
  run: |
    echo "Image is less than 7 days old, skipping rebuild"
    exit 0
```

### Verbose Mode for Debugging

Enable verbose output to see detailed information:

```yaml
- name: Query with verbose logging
  id: query-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'
    verbose: 'true'
```

### Complete Packer Integration Example

Full example showing image query → Packer build → image verification:

```yaml
name: Build Custom GCP Image

on:
  workflow_dispatch:
    inputs:
      source_image_family:
        description: 'Source image family'
        required: true
        default: 'rocky-linux-8'

jobs:
  build-image:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v3
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      # Query for source image before Packer runs
      - name: Get source image info
        id: source-image
        uses: rwaight/actions/utilities/image-info@main
        with:
          cloud-provider: 'gcp'
          query-location: ${{ secrets.GCP_PROJECT_ID }}
          source-image-family: ${{ inputs.source_image_family }}
          source-image-query-location: 'rocky-linux-cloud,centos-cloud'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Create build metadata
        run: |
          cat > build-metadata.json <<EOF
          {
            "source_image": {
              "name": "${{ steps.source-image.outputs.image-name }}",
              "project": "${{ steps.source-image.outputs.image-project }}",
              "family": "${{ steps.source-image.outputs.image-family }}",
              "created": "${{ steps.source-image.outputs.image-creation-timestamp }}"
            },
            "build": {
              "workflow_run_id": "${{ github.run_id }}",
              "workflow_run_number": "${{ github.run_number }}",
              "triggered_by": "${{ github.actor }}"
            }
          }
          EOF
          cat build-metadata.json

      - name: Setup Packer
        uses: hashicorp/setup-packer@v3

      - name: Packer Init
        run: packer init ./packer/

      - name: Packer Build
        env:
          PKR_VAR_project_id: ${{ secrets.GCP_PROJECT_ID }}
          PKR_VAR_source_image: ${{ steps.source-image.outputs.image-name }}
          PKR_VAR_source_image_project_id: ${{ steps.source-image.outputs.image-project }}
        run: packer build ./packer/gcp-custom-image.pkr.hcl

      - name: Upload build metadata
        uses: actions/upload-artifact@v4
        with:
          name: build-metadata
          path: build-metadata.json
```

## GCP Image Search Behavior

### Search Priority

1. **Specific Image**: If `source-image` is provided, it takes precedence
2. **Image Family**: If only `source-image-family` is provided, returns latest non-deprecated

### Project Search Order

When `image-location` contains multiple projects (comma-separated):

- Projects are searched in the order specified
- Returns the first matching image found
- Useful for fallback scenarios

Example:
```yaml
image-location: 'my-custom-images,rocky-linux-cloud,centos-cloud'
```

Searches: `my-custom-images` → `rocky-linux-cloud` → `centos-cloud`

### Prefix/Suffix Patterns

Use `image-name-prefix` and `image-name-suffix` to modify the image name output:

**Prefix Example** - Add full GCP image path:
```yaml
image-name-prefix: 'projects/rocky-linux-cloud/global/images/'
# Output: projects/rocky-linux-cloud/global/images/rocky-linux-8-optimized-gcp-v20240110
```

**Suffix Example** - Add version tag:
```yaml
image-name-suffix: '-verified'
# Output: rocky-linux-8-optimized-gcp-v20240110-verified
```

**Combined** - Both prefix and suffix:
```yaml
image-name-prefix: 'gcr.io/my-project/'
image-name-suffix: ':latest'
# Output: gcr.io/my-project/rocky-linux-8-optimized-gcp-v20240110:latest
```

The prefix/suffix is applied to both `image-name` and `image-id` outputs.

### Common GCP Image Families

| Family | Provider Project | Description |
|--------|------------------|-------------|
| `rocky-linux-8` | `rocky-linux-cloud` | Rocky Linux 8 |
| `rocky-linux-9` | `rocky-linux-cloud` | Rocky Linux 9 |
| `ubuntu-2204-lts` | `ubuntu-os-cloud` | Ubuntu 22.04 LTS |
| `ubuntu-2004-lts` | `ubuntu-os-cloud` | Ubuntu 20.04 LTS |
| `debian-11` | `debian-cloud` | Debian 11 |
| `centos-stream-9` | `centos-cloud` | CentOS Stream 9 |

## AWS Support

AWS image query support is currently a **placeholder**. The action validates AWS as a provider but does not implement the query functionality.

To implement AWS support in the future, the action would use:
```bash
aws ec2 describe-images --region REGION --image-ids AMI_ID --output json
# or
aws ec2 describe-images --region REGION --filters "Name=name,Values=PATTERN" --output json
```

## Error Handling

The action includes comprehensive error handling:

- ✅ Validates cloud provider input (must be `gcp` or `aws`)
- ✅ Validates runner OS (Linux only)
- ✅ Validates required inputs based on provider
- ✅ Returns `image-found: false` if no match (doesn't fail the workflow)
- ✅ Provides clear error messages with `::error` annotations
- ✅ Supports `::warning` for non-fatal issues

## Troubleshooting

### Error: "This action supports Linux only"

- **Cause**: You're running on a Windows or macOS runner
- **Solution**: Use `runs-on: ubuntu-latest` in your workflow

### Error: "Cloud provider must be 'gcp' or 'aws'"

- **Cause**: Invalid value for `cloud-provider` input
- **Solution**: Set `cloud-provider` to either `gcp` or `aws`

### Error: "query-location is required for GCP/AWS"

- **Cause**: Missing `query-location` input
- **Solution**: For GCP, provide the project ID. For AWS, provide the region (e.g., `us-east-1`)

### Warning: "Image not found"

- **Cause**: No image matches the search criteria
- **Solution**: 
  1. Verify the image name or family is correct
  2. Check the project ID(s) in `image-location` being searched
  3. Ensure GCP authentication has access to the projects
  4. Enable verbose mode to see search details

### Image found but wrong version

- **Cause**: Multiple images in family, got a different one than expected
- **Solution**: Use `source-image` with the exact image name instead of `source-image-family`

## Integration with GitHub build workflows

This action can be added to GitHub build workflows before running Packer:

```yaml
- name: Get source image information
  id: source-image-info
  if: matrix.provider == 'gcp'
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{fromJson(needs.set-vars.outputs.JSON_VARS).build.provider.gcp.project}}
    source-image-family: ${{ matrix.source_image_family || 'rocky-linux-8' }}
    source-image-query-location: 'rocky-linux-cloud,centos-cloud'
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

- name: Log source image being used
  if: matrix.provider == 'gcp' && steps.source-image-info.outputs.image-found == 'true'
  run: |
    echo "::notice title=Source Image::Using ${{ steps.source-image-info.outputs.image-name }} from ${{ steps.source-image-info.outputs.image-project }}"
```

## Best Practices

1. **Always check `image-found` output** before proceeding with builds
2. **Use `source-image-project-id`** to search common image repositories
3. **Enable verbose mode** during development and debugging
4. **Log image information** for build auditing and troubleshooting
5. **Pass image info to Packer** via environment variables for consistency
6. **Search multiple projects** with fallback options

## Contributing

This action is part of the `rwaight/actions` repository. To contribute or report issues, please visit the repository.

## License

This action follows the license of the parent repository.

## Related Actions

- [google-github-actions/auth](https://github.com/google-github-actions/auth) - Authenticate to Google Cloud
- [hashicorp/setup-packer](https://github.com/hashicorp/setup-packer) - Setup Packer
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) - Configure AWS credentials
- [rwaight/actions](https://github.com/rwaight/actions) - Monorepo of GitHub Actions

## References

- [Packer GCP Builder Documentation](https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute/latest/components/builder/googlecompute)
- [GCP Compute Images Documentation](https://cloud.google.com/compute/docs/images)
- [gcloud compute images commands](https://cloud.google.com/sdk/gcloud/reference/compute/images)
