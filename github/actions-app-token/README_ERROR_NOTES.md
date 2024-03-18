# App Token Errors

## Errors related to the token_getter.py

From https://github.com/rwaight/actions/actions/runs/8675309/job/8675309
- Step: "Get token using my custom github app"
```
Run rwaight/actions/github/actions-app-token@v1
  with:
    APP_PEM: ***
    APP_ID: ***
  env:
    my_identifier: custom-cool-code-repo
/usr/bin/docker run --name ef7d85fef0f24031784dd191d7a9d65ce571a6_31011b --label ef7d85 --workdir /github/workspace --rm -e "my_identifier" -e "INPUT_APP_PEM" -e "INPUT_APP_ID" -e "HOME" -e "GITHUB_JOB" -e "GITHUB_REF" -e "GITHUB_SHA" -e "GITHUB_REPOSITORY" -e "GITHUB_REPOSITORY_OWNER" -e "GITHUB_REPOSITORY_OWNER_ID" -e "GITHUB_RUN_ID" -e "GITHUB_RUN_NUMBER" -e "GITHUB_RETENTION_DAYS" -e "GITHUB_RUN_ATTEMPT" -e "GITHUB_REPOSITORY_ID" -e "GITHUB_ACTOR_ID" -e "GITHUB_ACTOR" -e "GITHUB_TRIGGERING_ACTOR" -e "GITHUB_WORKFLOW" -e "GITHUB_HEAD_REF" -e "GITHUB_BASE_REF" -e "GITHUB_EVENT_NAME" -e "GITHUB_SERVER_URL" -e "GITHUB_API_URL" -e "GITHUB_GRAPHQL_URL" -e "GITHUB_REF_NAME" -e "GITHUB_REF_PROTECTED" -e "GITHUB_REF_TYPE" -e "GITHUB_WORKFLOW_REF" -e "GITHUB_WORKFLOW_SHA" -e "GITHUB_WORKSPACE" -e "GITHUB_ACTION" -e "GITHUB_EVENT_PATH" -e "GITHUB_ACTION_REPOSITORY" -e "GITHUB_ACTION_REF" -e "GITHUB_PATH" -e "GITHUB_ENV" -e "GITHUB_STEP_SUMMARY" -e "GITHUB_STATE" -e "GITHUB_OUTPUT" -e "RUNNER_OS" -e "RUNNER_ARCH" -e "RUNNER_NAME" -e "RUNNER_ENVIRONMENT" -e "RUNNER_TOOL_CACHE" -e "RUNNER_TEMP" -e "RUNNER_WORKSPACE" -e "ACTIONS_RUNTIME_URL" -e "ACTIONS_RUNTIME_TOKEN" -e "ACTIONS_CACHE_URL" -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" -v "/home/runner/work/actions/actions":"/github/workspace" ef7d85:fef0f24031784dd191d7a9d65ce571a6
```

Error:
```
Traceback (most recent call last):
  File "/app/token_getter.py", line 149, in <module>
    id = app.get_installation_id()
         ^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/app/token_getter.py", line 89, in get_installation_id
    headers = {'Authorization': f'***',
                                          ^^^^^^^^^^^^^^
  File "/app/token_getter.py", line 78, in get_jwt
    private_key = default_backend().load_pem_private_key(key_file.read(), *** backend=default_backend())
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TypeError: Backend.load_pem_private_key() got an unexpected keyword argument 'backend'
```

#### Info from the load_pem_private_key message

- Google search: https://www.google.com/search?q=TypeError%3A+Backend.load_pem_private_key()+got+an+unexpected+keyword+argument+%27backend%27&rlz=1C5GCEM_enUS968US968&oq=TypeError%3A+Backend.load_pem_private_key()+got+an+unexpected+keyword+argument+%27backend%27
- https://github.com/pyca/cryptography/issues/8563
- https://devpress.csdn.net/python/62fe26c8c677032930804778.html
- https://www.google.com/search?q=%22Backend.load_pem_private_key%28%29%22+got+an+unexpected+keyword+argument+%27backend%27
- https://stackoverflow.com/questions/65987293/typeerror-load-pem-private-key-missing-1-required-positional-argument-backe
- https://stackoverflow.com/questions/69564817/typeerror-load-missing-1-required-positional-argument-loader-in-google-col
- https://github.com/ly4k/Certipy/issues/31

### Docker build logs from the run above

#### rwaight/actions/github/actions-app-token@v1
```
Build container for action use: '/home/runner/work/_actions/rwaight/actions/v1/actions-app-token/prebuild.Dockerfile'.
  /usr/bin/docker build -t ef7d85:fef0f24031784dd191d7a9d65ce571a6 -f "/home/runner/work/_actions/rwaight/actions/v1/actions-app-token/prebuild.Dockerfile" "/home/runner/work/_actions/rwaight/actions/v1/actions-app-token"
  #0 building with "default" instance using docker driver
  
  #1 [internal] load .dockerignore
  #1 transferring context: 2B done
  #1 DONE 0.0s
  
  #2 [internal] load build definition from prebuild.Dockerfile
  #2 transferring dockerfile: 613B done
  #2 DONE 0.0s
  
  #3 [auth] library/python:pull token for registry-1.docker.io
  #3 DONE 0.0s
  
  #4 [internal] load metadata for docker.io/library/python:slim-bullseye
  #4 DONE 0.4s
  
  #5 [internal] load build context
  #5 transferring context: 6.42kB done
  #5 DONE 0.0s
  
  #6 [1/6] FROM docker.io/library/python:slim-bullseye@sha256:0bc6588e043ceff0278c3936467fce6dad52c5889bf4eb257ad5147a17522064
  #6 resolve docker.io/library/python:slim-bullseye@sha256:0bc6588e043ceff0278c3936467fce6dad52c5889bf4eb257ad5147a17522064 done
  #6 sha256:e237eda636e9af691f797afc6c3174edddfeb5449103841910755d394ada35e0 1.37kB / 1.37kB done
  #6 sha256:14bfc0fc6c2123a19b4625b4b9c5ac7e506feed8eba0f0a4e42648c084945562 6.93kB / 6.93kB done
  #6 sha256:14726c8f78342865030f97a8d3492e2d1a68fbd22778f9a31dc6be4b4f12a9bc 7.34MB / 31.42MB 0.1s
  #6 sha256:7d676dc8a994c0e4184cd6cfbc4b1540eea31846375a23864db3bb9effab24c0 1.08MB / 1.08MB 0.1s done
  #6 sha256:10338e535bb5dbe3fd675a94f550447cfe14ce908769de44a9379e8c6ac0e916 2.10MB / 11.99MB 0.1s
  #6 sha256:a990af3f4993b2c1f4cd5e0f2becbf4e2123cb429e616b9835f6193fe683e53f 0B / 247B 0.1s
  #6 sha256:0bc6588e043ceff0278c3936467fce6dad52c5889bf4eb257ad5147a17522064 1.65kB / 1.65kB done
  #6 sha256:14726c8f78342865030f97a8d3492e2d1a68fbd22778f9a31dc6be4b4f12a9bc 22.02MB / 31.42MB 0.2s
  #6 sha256:10338e535bb5dbe3fd675a94f550447cfe14ce908769de44a9379e8c6ac0e916 11.99MB / 11.99MB 0.2s
  #6 sha256:a990af3f4993b2c1f4cd5e0f2becbf4e2123cb429e616b9835f6193fe683e53f 247B / 247B 0.1s done
  #6 sha256:9afa5f75727c35e4d07431f2d00e7a217cbedec747bfbfd767f29aea55346b7c 1.05MB / 3.40MB 0.2s
  #6 sha256:14726c8f78342865030f97a8d3492e2d1a68fbd22778f9a31dc6be4b4f12a9bc 31.42MB / 31.42MB 0.3s done
  #6 sha256:10338e535bb5dbe3fd675a94f550447cfe14ce908769de44a9379e8c6ac0e916 11.99MB / 11.99MB 0.2s done
  #6 sha256:9afa5f75727c35e4d07431f2d00e7a217cbedec747bfbfd767f29aea55346b7c 3.40MB / 3.40MB 0.2s done
  #6 extracting sha256:14726c8f78342865030f97a8d3492e2d1a68fbd22778f9a31dc6be4b4f12a9bc
  #6 extracting sha256:14726c8f78342865030f97a8d3492e2d1a68fbd22778f9a31dc6be4b4f12a9bc 1.7s done
  #6 extracting sha256:7d676dc8a994c0e4184cd6cfbc4b1540eea31846375a23864db3bb9effab24c0 0.1s done
  #6 extracting sha256:10338e535bb5dbe3fd675a94f550447cfe14ce908769de44a9379e8c6ac0e916
  #6 extracting sha256:10338e535bb5dbe3fd675a94f550447cfe14ce908769de44a9379e8c6ac0e916 0.6s done
  #6 extracting sha256:a990af3f4993b2c1f4cd5e0f2becbf4e2123cb429e616b9835f6193fe683e53f done
  #6 extracting sha256:9afa5f75727c35e4d07431f2d00e7a217cbedec747bfbfd767f29aea55346b7c
  #6 extracting sha256:9afa5f75727c35e4d07431f2d00e7a217cbedec747bfbfd767f29aea55346b7c 0.3s done
  #6 DONE 3.5s
  
  #7 [2/6] RUN pip install     cryptography     github3.py     jwcrypto     pyjwt
  #7 2.132 Collecting cryptography
  #7 2.133   Obtaining dependency information for cryptography from https://files.pythonhosted.org/packages/46/74/f9eba8c947f57991b5dd5e45797fdc68cc70e444c32e6b952b512d42aba5/cryptography-41.0.3-cp37-abi3-manylinux_2_28_x86_64.whl.metadata
  #7 2.153   Downloading cryptography-41.0.3-cp37-abi3-manylinux_2_28_x86_64.whl.metadata (5.2 kB)
  #7 2.180 Collecting github3.py
  #7 2.186   Downloading github3.py-4.0.1-py3-none-any.whl (151 kB)
  #7 2.195      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 151.8/151.8 kB 23.2 MB/s eta 0:00:00
  #7 2.215 Collecting jwcrypto
  #7 2.220   Downloading jwcrypto-1.5.0.tar.gz (86 kB)
  #7 2.225      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 86.4/86.4 kB 31.5 MB/s eta 0:00:00
  #7 2.236   Preparing metadata (setup.py): started
  #7 2.777   Preparing metadata (setup.py): finished with status 'done'
  #7 2.805 Collecting pyjwt
  #7 2.805   Obtaining dependency information for pyjwt from https://files.pythonhosted.org/packages/2b/4f/e04a8067c7c96c364cef7ef73906504e2f40d690811c021e1a1901473a19/PyJWT-2.8.0-py3-none-any.whl.metadata
  #7 2.810   Downloading PyJWT-2.8.0-py3-none-any.whl.metadata (4.2 kB)
  #7 3.010 Collecting cffi>=1.12 (from cryptography)
  #7 3.014   Downloading cffi-1.15.1-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (462 kB)
  #7 3.022      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 462.6/462.6 kB 81.0 MB/s eta 0:00:00
  #7 3.061 Collecting python-dateutil>=2.6.0 (from github3.py)
  #7 3.066   Downloading python_dateutil-2.8.2-py2.py3-none-any.whl (247 kB)
  #7 3.076      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 247.7/247.7 kB 63.4 MB/s eta 0:00:00
  #7 3.117 Collecting requests>=2.18 (from github3.py)
  #7 3.118   Obtaining dependency information for requests>=2.18 from https://files.pythonhosted.org/packages/70/8e/0e2d847013cb52cd35b38c009bb167a1a26b2ce6cd6965bf26b47bc0bf44/requests-2.31.0-py3-none-any.whl.metadata
  #7 3.121   Downloading requests-2.31.0-py3-none-any.whl.metadata (4.6 kB)
  #7 3.139 Collecting uritemplate>=3.0.0 (from github3.py)
  #7 3.143   Downloading uritemplate-4.1.1-py2.py3-none-any.whl (10 kB)
  #7 3.181 Collecting deprecated (from jwcrypto)
  #7 3.181   Obtaining dependency information for deprecated from https://files.pythonhosted.org/packages/20/8d/778b7d51b981a96554f29136cd59ca7880bf58094338085bcf2a979a0e6a/Deprecated-1.2.14-py2.py3-none-any.whl.metadata
  #7 3.186   Downloading Deprecated-1.2.14-py2.py3-none-any.whl.metadata (5.4 kB)
  #7 3.218 Collecting pycparser (from cffi>=1.12->cryptography)
  #7 3.223   Downloading pycparser-2.21-py2.py3-none-any.whl (118 kB)
  #7 3.227      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 118.7/118.7 kB 43.8 MB/s eta 0:00:00
  #7 3.264 Collecting six>=1.5 (from python-dateutil>=2.6.0->github3.py)
  #7 3.267   Downloading six-1.16.0-py2.py3-none-any.whl (11 kB)
  #7 3.372 Collecting charset-normalizer<4,>=2 (from requests>=2.18->github3.py)
  #7 3.372   Obtaining dependency information for charset-normalizer<4,>=2 from https://files.pythonhosted.org/packages/bc/85/ef25d4ba14c7653c3020a1c6e1a7413e6791ef36a0ac177efa605fc2c737/charset_normalizer-3.2.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  #7 3.377   Downloading charset_normalizer-3.2.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (31 kB)
  #7 3.401 Collecting idna<4,>=2.5 (from requests>=2.18->github3.py)
  #7 3.405   Downloading idna-3.4-py3-none-any.whl (61 kB)
  #7 3.410      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 61.5/61.5 kB 21.9 MB/s eta 0:00:00
  #7 3.459 Collecting urllib3<3,>=1.21.1 (from requests>=2.18->github3.py)
  #7 3.460   Obtaining dependency information for urllib3<3,>=1.21.1 from https://files.pythonhosted.org/packages/9b/81/62fd61001fa4b9d0df6e31d47ff49cfa9de4af03adecf339c7bc30656b37/urllib3-2.0.4-py3-none-any.whl.metadata
  #7 3.465   Downloading urllib3-2.0.4-py3-none-any.whl.metadata (6.6 kB)
  #7 3.522 Collecting certifi>=2017.4.17 (from requests>=2.18->github3.py)
  #7 3.522   Obtaining dependency information for certifi>=2017.4.17 from https://files.pythonhosted.org/packages/4c/dd/2234eab22353ffc7d94e8d13177aaa050113286e93e7b40eae01fbf7c3d9/certifi-2023.7.22-py3-none-any.whl.metadata
  #7 3.529   Downloading certifi-2023.7.22-py3-none-any.whl.metadata (2.2 kB)
  #7 3.658 Collecting wrapt<2,>=1.10 (from deprecated->jwcrypto)
  #7 3.663   Downloading wrapt-1.15.0-cp311-cp311-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl (78 kB)
  #7 3.668      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 78.9/78.9 kB 30.1 MB/s eta 0:00:00
  #7 3.705 Downloading cryptography-41.0.3-cp37-abi3-manylinux_2_28_x86_64.whl (4.3 MB)
  #7 3.750    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 4.3/4.3 MB 101.4 MB/s eta 0:00:00
  #7 3.756 Downloading PyJWT-2.8.0-py3-none-any.whl (22 kB)
  #7 3.762 Downloading requests-2.31.0-py3-none-any.whl (62 kB)
  #7 3.766    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 62.6/62.6 kB 24.1 MB/s eta 0:00:00
  #7 3.770 Downloading Deprecated-1.2.14-py2.py3-none-any.whl (9.6 kB)
  #7 3.775 Downloading certifi-2023.7.22-py3-none-any.whl (158 kB)
  #7 3.780    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 158.3/158.3 kB 57.9 MB/s eta 0:00:00
  #7 3.784 Downloading charset_normalizer-3.2.0-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (199 kB)
  #7 3.790    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 199.6/199.6 kB 69.5 MB/s eta 0:00:00
  #7 3.802 Downloading urllib3-2.0.4-py3-none-any.whl (123 kB)
  #7 3.806    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 123.9/123.9 kB 47.8 MB/s eta 0:00:00
  #7 3.829 Building wheels for collected packages: jwcrypto
  #7 3.829   Building wheel for jwcrypto (setup.py): started
  #7 4.246   Building wheel for jwcrypto (setup.py): finished with status 'done'
  #7 4.247   Created wheel for jwcrypto: filename=jwcrypto-1.5.0-py3-none-any.whl size=91726 sha256=eac96a2112e43a3c3574668be4fc073398be617aa16e77814210e5af6487d889
  #7 4.247   Stored in directory: /root/.cache/pip/wheels/d3/f4/84/715f1fcb055cdbab451efc55b91baf7893a65f669d38a9a003
  #7 4.250 Successfully built jwcrypto
  #7 4.367 Installing collected packages: wrapt, urllib3, uritemplate, six, pyjwt, pycparser, idna, charset-normalizer, certifi, requests, python-dateutil, deprecated, cffi, cryptography, jwcrypto, github3.py
  #7 5.361 Successfully installed certifi-2023.7.22 cffi-1.15.1 charset-normalizer-3.2.0 cryptography-41.0.3 deprecated-1.2.14 github3.py-4.0.1 idna-3.4 jwcrypto-1.5.0 pycparser-2.21 pyjwt-2.8.0 python-dateutil-2.8.2 requests-2.31.0 six-1.16.0 uritemplate-4.1.1 urllib3-2.0.4 wrapt-1.15.0
  #7 5.362 WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
  #7 DONE 5.7s
  
  #8 [3/6] COPY token_getter.py /app/
  #8 DONE 0.0s
  
  #9 [4/6] COPY entrypoint.sh /app/
  #9 DONE 0.0s
  
  #10 [5/6] RUN chmod u+x /app/entrypoint.sh
  #10 DONE 0.3s
  
  #11 [6/6] WORKDIR /app
  #11 DONE 0.0s
  
  #12 exporting to image
  #12 exporting layers
  #12 exporting layers 1.2s done
  #12 writing image sha256:f8499ea5bd9d70f566e18c11e4defcf8093f219a50eb1a91532a2e8665edf4e5 done
  #12 naming to docker.io/library/ef7d85:fef0f24031784dd191d7a9d65ce571a6 done
  #12 DONE 1.2s
```

#### rwaight/actions/utilities/copycat@v1

```
Build container for action use: '/home/runner/work/_actions/rwaight/actions/v1/utilities/copycat/Dockerfile'.
  /usr/bin/docker build -t ef7d85:09de37e84e6746809063068a87cf0bc1 -f "/home/runner/work/_actions/rwaight/actions/v1/utilities/copycat/Dockerfile" "/home/runner/work/_actions/rwaight/actions/v1/utilities/copycat"
  #0 building with "default" instance using docker driver
  
  #1 [internal] load build definition from Dockerfile
  #1 transferring dockerfile: 196B done
  #1 DONE 0.0s
  
  #2 [internal] load .dockerignore
  #2 transferring context: 2B done
  #2 DONE 0.0s
  
  #3 [auth] library/alpine:pull token for registry-1.docker.io
  #3 DONE 0.0s
  
  #4 [internal] load metadata for docker.io/library/alpine:3.10
  #4 DONE 0.5s
  
  #5 [internal] load build context
  #5 transferring context: 4.83kB done
  #5 DONE 0.0s
  
  #6 [1/4] FROM docker.io/library/alpine:3.10@sha256:451eee8bedcb2f029756dc3e9d73bab0e7943c1ac55cff3a4861c52a0fdd3e98
  #6 resolve docker.io/library/alpine:3.10@sha256:451eee8bedcb2f029756dc3e9d73bab0e7943c1ac55cff3a4861c52a0fdd3e98 done
  #6 extracting sha256:396c31837116ac290458afcb928f68b6cc1c7bdd6963fc72f52f365a2a89c1b5 0.1s
  #6 sha256:451eee8bedcb2f029756dc3e9d73bab0e7943c1ac55cff3a4861c52a0fdd3e98 1.64kB / 1.64kB done
  #6 sha256:e515aad2ed234a5072c4d2ef86a1cb77d5bfe4b11aa865d9214875734c4eeb3c 528B / 528B done
  #6 sha256:e7b300aee9f9bf3433d32bc9305bfdd22183beb59d933b48d77ab56ba53a197a 1.47kB / 1.47kB done
  #6 sha256:396c31837116ac290458afcb928f68b6cc1c7bdd6963fc72f52f365a2a89c1b5 2.80MB / 2.80MB 0.1s done
  #6 extracting sha256:396c31837116ac290458afcb928f68b6cc1c7bdd6963fc72f52f365a2a89c1b5 0.1s done
  #6 DONE 0.2s
  
  #7 [2/4] RUN apk add --no-cache bash
  #7 0.166 fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
  #7 0.219 fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
  #7 0.294 (1/4) Installing ncurses-terminfo-base (6.1_p20190518-r2)
  #7 0.302 (2/4) Installing ncurses-libs (6.1_p20190518-r2)
  #7 0.312 (3/4) Installing readline (8.0.0-r0)
  #7 0.317 (4/4) Installing bash (5.0.0-r0)
  #7 0.331 Executing bash-5.0.0-r0.post-install
  #7 0.334 Executing busybox-1.30.1-r5.trigger
  #7 0.338 OK: 8 MiB in 18 packages
  #7 DONE 0.4s
  
  #8 [3/4] RUN apk add --no-cache git
  #8 0.281 fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
  #8 0.332 fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
  #8 0.429 (1/6) Installing ca-certificates (20191127-r2)
  #8 0.450 (2/6) Installing nghttp2-libs (1.39.2-r1)
  #8 0.453 (3/6) Installing libcurl (7.66.0-r4)
  #8 0.462 (4/6) Installing expat (2.2.8-r0)
  #8 0.468 (5/6) Installing pcre2 (10.33-r0)
  #8 0.477 (6/6) Installing git (2.22.5-r0)
  #8 0.653 Executing busybox-1.30.1-r5.trigger
  #8 0.657 Executing ca-certificates-20191127-r2.trigger
  #8 0.692 OK: 23 MiB in 24 packages
  #8 DONE 0.8s
  
  #9 [4/4] COPY entrypoint.sh /entrypoint.sh
  #9 DONE 0.0s
  
  #10 exporting to image
  #10 exporting layers
  #10 exporting layers 0.6s done
  #10 writing image sha256:0156cd1bf04ffa77b586cf0dc85a0ad1887751785a2838657887894e38c8ba59 done
  #10 naming to docker.io/library/ef7d85:09de37e84e6746809063068a87cf0bc1 done
  #10 DONE 0.6s
```