# GitHub Label Sync Action

The current version in this repo is based off of [**label-sync** v2.3.2](https://github.com/EndBug/label-sync/releases/tag/v2.3.2)
- **Note**: You must use the (classic) personal access tokens when configuring the `token` and the `request-token`
- This action is from https://github.com/EndBug/label-sync.

The [`EndBug/label-sync`](https://github.com/EndBug/label-sync) code has a MIT license:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.


## Deploying this action

Example workflow:
```
name: Sync labels
on:
  # You can run this with every type of event, but it's better to run it only when you actually need it.
  workflow_dispatch:

#Setting issues: write breaks the action, need to define
#  the permissions at the job level
#permissions:
#  issues: write

jobs:
  sync-labels:
    name: Run My custom label-sync action
    # may need to tune the scope of ther job permissions, see:
    #   https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idpermissions
    permissions: write-all
    runs-on: ubuntu-22.04
    
    steps:
      - name: Checkout files from commit tree
        uses: actions/checkout@v4

      - name: Branch
        run: echo running on branch ${GITHUB_REF##*/}

      - name: Run label sync
        #uses: rwaight/actions/github/label-sync@main # can use version specific or main
        uses: rwaight/actions/github/label-sync@v1
        with:
          # If you want to use a config file, you can put its path or URL here, multiple files are also allowed (more info in the paragraphs below)
          config-file: .github/labels.yml
          # as URL:
          config-file: https://raw.githubusercontent.com/rwaight/actions/main/automations/my-labels-core.yml
          # as multiple:
          config-file: |
            https://raw.githubusercontent.com/rwaight/actions/main/automations/my-labels-core.yml
            https://raw.githubusercontent.com/rwaight/actions/main/automations/my-labels-versioning.yml
            .github/labels.yml

          # If you want to use a source repo, you can put is name here (only the owner/repo format is accepted)
          # NOTE the source-repo parameter can NOT be used with the config-file parameter
          #source-repo: owner/repo

          # If you're using a private source repo or a URL that needs an 'Authorization' header,  
          # you will need to add a custom token for the action to read it
          request-token: ${{ secrets.MY_ACTIONS_TOKEN }}

          # If you want to delete any additional label, set this to true
          delete-other-labels: false

          # If you want the action just to show you the preview of the changes, without actually editing the labels, set this to true
          dry-run: true

          # You can change the token used to change the labels, this is the default one
          token: ${{ secrets.MY_ACTIONS_TOKEN }}
```
