# Get Cloud Image Info Action - Complete Package

This directory contains a comprehensive GitHub composite action for querying cloud providers (GCP and AWS) for source image information before running Packer builds.

## 📦 Package Contents

| File | Description |
|------|-------------|
| **action.yml** | Core composite action implementation (~400 lines) |
| **README.md** | Complete documentation with examples and integration guides |
| **QUICK-REFERENCE.md** | Quick copy-paste patterns for common use cases |
| **example-workflow.yml** | Full working examples with 5 test scenarios |
| **import-config.yml** | Action metadata and configuration reference |
| **INDEX.md** | This navigation guide |

## 🎯 Purpose

Packer doesn't have a good way to get source image information **before** it runs. This action fills that gap by querying cloud provider APIs to:

- ✅ Validate source images exist before starting expensive Packer builds
- ✅ Get the latest non-deprecated image from a family
- ✅ Search across multiple GCP projects for shared images
- ✅ Capture image metadata for build logs and auditing
- ✅ Enable conditional workflow logic based on image properties

## 🚀 Quick Start

```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v3
  with:
    credentials_json: ${{ secrets.GCP_CREDENTIALS }}

- name: Get source image info
  id: source-image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-gcp-project'
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'

- name: Use with Packer
  env:
    PKR_VAR_source_image: ${{ steps.source-image.outputs.image-name }}
    PKR_VAR_source_image_project_id: ${{ steps.source-image.outputs.image-project }}
  run: packer build ./build.pkr.hcl
```

## 📖 Documentation Guide

### For First-Time Users

1. **Start with README.md** - Complete overview with examples
2. **Check QUICK-REFERENCE.md** - Copy-paste common patterns
3. **Review example-workflow.yml** - See it in action

### For Integration

1. **Use QUICK-REFERENCE.md** - Find your use case pattern
2. **Check "Packer Integration" section in README.md** - See full integration examples
3. **Refer to example-workflow.yml** - Study the packer-integration job

### For Configuration

1. **See import-config.md** - All inputs and outputs documented
2. **Check README.md "Inputs" section** - Detailed parameter descriptions

## 🔑 Key Features

### GCP Support (Fully Implemented)

- Query by specific image name OR image family
- Search across multiple projects (comma-separated list)
- Returns latest non-deprecated image from family
- Extracts 8 metadata fields from gcloud JSON
- Apply prefix/suffix patterns to image names
- Verbose mode shows full image details

### Consolidated Inputs

- `query-location`: GCP project ID or AWS region (single input for both)
- `image-location`: GCP project ID(s) or AWS owner ID (single input for both)
- Simplified cross-cloud configuration

### Prefix/Suffix Patterns

- **Prefix**: Add full paths (e.g., `projects/my-project/global/images/`)
- **Suffix**: Add tags or versions (e.g., `-verified`, `:latest`)
- **Both**: Create custom formats (e.g., `gcr.io/project/image:tag`)

### AWS Support (Placeholder)

- Input validation complete
- Example commands documented
- Ready for implementation (returns "not implemented" error)

### Error Handling

- Graceful failure (returns `image-found: false` instead of failing workflow)
- Comprehensive input validation
- Clear error messages with GitHub annotations
- Support for fallback scenarios

## 📊 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `image-found` | Whether image was found | `true` / `false` |
| `image-name` | Image name | `rocky-linux-8-optimized-gcp-v20240110` |
| `image-project` | Project containing image | `rocky-linux-cloud` |
| `image-family` | Image family | `rocky-linux-8` |
| `image-creation-timestamp` | When created | `2024-01-10T08:30:00.000-08:00` |
| `image-self-link` | GCP self-link URL | `https://www.googleapis.com/compute/v1/projects/...` |
| `image-id` | Full image identifier | Same as `image-name` for GCP |
| `image-description` | Image description | `Rocky Linux 8 optimized for GCP` |

## 💡 Common Use Cases

### 1. Pre-Build Validation

Verify source image exists before starting Packer:
```yaml
- name: Get source image
  id: source
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    project-id: ${{ secrets.GCP_PROJECT_ID }}
    source-image-family: 'rocky-linux-8'

- name: Verify image exists
  if: steps.source.outputs.image-found == 'false'
  run: |
    echo "::error::Source image not found!"
    exit 1
```

### 2. Multi-Project Search

Search across multiple GCP projects:
```yaml
- uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'ubuntu-2204-lts'
    image-location: 'my-custom-images,ubuntu-os-cloud'
```

### 3. Prefix/Suffix Patterns

Add full paths or tags to image names:
```yaml
- uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'
    image-location: 'rocky-linux-cloud'
    image-name-prefix: 'projects/rocky-linux-cloud/global/images/'
    # Output: projects/rocky-linux-cloud/global/images/rocky-linux-8-v20240110
```

### 4. Build Metadata Collection

Capture source image details:
```yaml
### 4. Build Metadata Collection
Capture source image details:
```yaml
- name: Get image info
  id: image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'rocky-linux-8'

- name: Create metadata
  run: |
    cat > build-metadata.json <<EOF
    {
      "source_image": "${{ steps.image.outputs.image-name }}",
      "created": "${{ steps.image.outputs.image-creation-timestamp }}",
      "family": "${{ steps.image.outputs.image-family }}"
    }
    EOF
```

### 5. Conditional Logic

Make workflow decisions based on image info:
```yaml
- name: Get image info
  id: image
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: 'my-project'
    source-image-family: 'my-base-image'

- name: Check if recent
  run: |
    # Calculate age and decide whether to rebuild
    # See example-workflow.yml for full example
```

## 🔧 Implementation Details

### How It Works (GCP)

1. **Input Validation**: Validates cloud provider and required parameters
2. **Project List**: Parses comma-separated `source-image-project-id`
3. **Search Logic**:
   - If `source-image` provided → use `gcloud compute images describe`
   - If `source-image-family` provided → use `gcloud compute images describe-from-family`
4. **Project Iteration**: Searches each project in order until image found
5. **Metadata Extraction**: Uses `jq` to parse gcloud JSON output
6. **Output Setting**: Sets all 8 output variables

### Requirements

- **Authentication**: GCP auth must be configured BEFORE calling this action
- **CLI Tools**: gcloud CLI (pre-installed on GitHub-hosted Ubuntu runners)
- **Runner**: Linux only
- **Permissions**: GCP service account needs `compute.images.get` permission

## 📚 Related Actions

- [google-github-actions/auth](https://github.com/google-github-actions/auth) - Authenticate to GCP (required prerequisite)
- [hashicorp/setup-packer](https://github.com/hashicorp/setup-packer) - Setup Packer for builds


## 🔗 Integration with GitHub build workflows

This action can be added to GitHub build workflows:

```yaml
# After GCP authentication, before Packer steps
- name: Get source image information
  id: source-image-info
  if: matrix.provider == 'gcp'
  uses: rwaight/actions/utilities/image-info@main
  with:
    cloud-provider: 'gcp'
    query-location: ${{fromJson(needs.set-vars.outputs.JSON_VARS).build.provider.gcp.project}}
    source-image-family: ${{ matrix.source_image_family }}
    image-location: 'rocky-linux-cloud,centos-cloud'
    verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

- name: Verify source image found
  if: matrix.provider == 'gcp' && steps.source-image-info.outputs.image-found == 'false'
  run: |
    echo "::error::Source image not found"
    exit 1

- name: Log source image
  if: matrix.provider == 'gcp'
  run: |
    echo "::notice::Using ${{ steps.source-image-info.outputs.image-name }}"
```

## 🐛 Troubleshooting

### Image Not Found

- Enable `verbose: 'true'` to see search details
- Verify project IDs are correct
- Check GCP authentication has access to the projects
- Try querying manually: `gcloud compute images describe-from-family FAMILY --project=PROJECT`

### Authentication Errors

- Ensure `google-github-actions/auth` runs BEFORE this action
- Verify service account has `compute.images.get` permission
- Check project ID is correct

### Wrong Image Returned

- If using `source-image-family`, you get the latest non-deprecated image
- Use `source-image` with exact name if you need a specific version
- Enable verbose mode to see which image was selected

## 📝 Version Information

- **Created**: 2025
- **Status**: Production Ready (GCP), Placeholder (AWS)
- **Template**: Based on rwaight/actions/test/template-composite
- **Line Count**: ~440 lines in action.yml

## 🎓 Learn More

- **Packer GCP Builder**: https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute
- **GCP Compute Images**: https://cloud.google.com/compute/docs/images
- **gcloud CLI Reference**: https://cloud.google.com/sdk/gcloud/reference/compute/images

## 📦 Package Structure

```
utilities/image-info/
├── action.yml              # Core action implementation
├── README.md               # Complete documentation
├── QUICK-REFERENCE.md      # Quick patterns
├── example-workflow.yml    # Working examples
├── import-config.yml       # Metadata reference
└── INDEX.md                # This file
```

---

**Ready to use?** Start with [README.md](./README.md) for complete documentation!
