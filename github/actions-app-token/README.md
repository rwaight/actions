# GitHub Actions App Token

The current version in this repo is based off of the [**elastic/actions-app-token**](https://github.com/elastic/actions-app-token)
- This action is from [elastic/actions-app-token](https://github.com/elastic/actions-app-token) (which is originally from [machine-learning-apps/actions-app-token](https://github.com/machine-learning-apps/actions-app-token)).

The [`machine-learning-apps/actions-app-token`](https://github.com/machine-learning-apps/actions-app-token) has a MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

# Updates that need to be made

Updates need to be made due to the `set-output` deprecation:
> Warning: The `set-output` command is deprecated and will be disabled soon. Please upgrade to using Environment Files. For more information see: https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/

**Note**: Need to check this comparison to see if it helps... https://github.com/machine-learning-apps/actions-app-token/compare/master...Ezzahhh:actions-app-token:main

## Update the `token_getter.py` script

### Option 1
Reference: https://github.com/machine-learning-apps/actions-app-token/compare/master...cilium:actions-app-token:master

The `token_getter.py`, on line 152 has:
```python
    print(f"::set-output name=app_token::{token}")
```

Replace the code block on line 152 with:
```python
    gh_output = os.getenv('GITHUB_OUTPUT')
    with open(gh_output, "a") as f:
        f.write(f"app_token={token}")
```

### Option 2
Reference: https://github.com/machine-learning-apps/actions-app-token/compare/master...Ezzahhh:actions-app-token:main

The `token_getter.py`, on line 152 has:
```python
    print(f"::set-output name=app_token::{token}")
```

Replace the code block on line 152 with:
```python
    print(f"app_token={token} >> $GITHUB_OUTPUT")
```


# Deploying this action

## Impersonate Your GitHub App In A GitHub Action

This action helps you retrieve an authenticated app token with a GitHub app id and a app private key.  You can use this key inside an actions workflow instead of `GITHUB_TOKEN`, in cases where the `GITHUB_TOKEN` has restricted rights.

### Why Would You Do This?

Actions have certain limitations.  Many of these limitations are for security and stability reasons, however not all of them are.  Some examples where you might want to impersonate a GitHub App temporarily in your workflow:

- You want an [event to trigger a workflow](https://help.github.com/en/articles/events-that-trigger-workflows) on a specific ref or branch in a way that is not natively supported by Actions.  For example, a pull request comment fires the [issue_comment event](https://help.github.com/en/articles/events-that-trigger-workflows#issue-comment-event-issue_comment) which is sent to the default branch and not the PR's branch.  You can temporarily impersonate a GitHub App to make an event, such as a [label a pull_request](https://help.github.com/en/articles/events-that-trigger-workflows#pull-request-event-pull_request) to trigger a workflow on the right branch. This takes advantage of the fact that Actions cannot create events that trigger workflows, however other Apps can. 

## Usage

1. If you do not already own a GitHub App you want to impersonate, [create a new GitHub App](https://developer.github.com/apps/building-github-apps/creating-a-github-app/) with your desired permissions.  If only creating a new app for the purposes of impersonation by Actions, you **do not need to provide** a `Webhook URL or Webhook Secret`

2. Install the App on your repositories. 

3. See [action.yml](action.yml) for the api spec.

Example:

```yaml
steps:
- name: Get token
  id: get_token
  #uses: elastic/actions-app-token@master # do not use the elastic/actions-app-token action
  uses: rwaight/actions/github/actions-app-token@main
  with:
    APP_PEM: ${{ secrets.APP_PEM }}
    APP_ID: ${{ secrets.APP_ID }}

- name: Get App Installation Token
  run: |
    echo "This token is masked: ${TOKEN}"
  env: 
    TOKEN: ${{ steps.get_token.outputs.app_token }}
```

**Note: The input `APP_PEM` needs to be base64 encoded.**  You can encode your private key file like this from the terminal:

```shell
cat your_app_key.pem | base64 -w 0 && echo
```
*The base64 encoded string must be on a single line, so be sure to remove any linebreaks when creating `APP_PEM` in your project's GitHub secrets.*

### Mandatory Inputs

- `APP_PEM`: description: string version of your PEM file used to authenticate as a GitHub App. 

- `APP_ID`: your GitHub App ID.

### Outputs

 - `app_token`: The [installation access token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-an-installation) for the GitHub App corresponding to the current repository.


## License

The scripts and documentation in this project are released under the MIT License.
