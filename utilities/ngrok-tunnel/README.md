# Ngrok Tunnel Github Action

The current version in this repo is based off of [**ngrok-tunneling-action** v0.1.4](https://github.com/apogiatzis/ngrok-tunneling-action/releases/tag/v0.1.4)
- Specifically [this commit](https://github.com/apogiatzis/ngrok-tunneling-action/commit/a88c9e0ef5b0f1932a5715f210f2fde239fc2630)
- This action is from https://github.com/apogiatzis/ngrok-tunneling-action/.

The [`apogiatzis/ngrok-tunneling-action`](https://github.com/apogiatzis/ngrok-tunneling-action/) **does not** have a License.


## About the Ngrok Tunneling Github Action

This is a Github Action that can be used in your Github Workflow to tunnel incoming/outgoing TCP traffic in your workflow environment.

The original use case for this was to achieve temporary deployment for CTF challenges under development but it can be as well used in many more other cases. 


## How to use this Action

This action accepts the following parameters

| Name| Description | Required  | Default |
| ------------- |-------------|-----|-----|
| timeout | After this timeout the deployment will automatically shutdown the tunelling and therefore stop the action. (max is 6 hours) | No | 1h |
| port | The port in localhost to forward traffic from/to  | Yes | - |
| ngrok_authtoken | Your ngrok authtoken| Yes | - |

Here is an example of using this action:

```yaml
name: CI
on: push

jobs:

  deploy:
    name: Deploy challenge
    runs-on: ubuntu-latest
    needs: cancel

    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Run container
      run: docker-compose up -d 
    
    - uses: rwaight/actions/utilities/ngrok-tunnel@main
      with:
        timeout: 1h
        port: 4000
        ngrok_authtoken: ${{ secrets.NGROK_AUTHTOKEN }}
```
