# GitHub render-template action

The current version in this repo was based off of [**render-template** v1.10](https://github.com/chuhlomin/render-template/releases/tag/v1.10)
- Specifically [this commit](https://github.com/chuhlomin/render-template/commit/807354a04d9300c9c2ac177c0aa41556c92b3f75)
- This action is from https://github.com/chuhlomin/render-template

The [`chuhlomin/render-template`](https://github.com/chuhlomin/render-template) code is licensed under the Apache License 2.0:
> A permissive license whose main conditions require preservation of copyright and license notices. Contributors provide an express grant of patent rights. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

## Updates to the action

Yes, the `runs.using` has been changed to:
```yml
runs:
  using: 'docker'
  image: 'Dockerfile'
```

It previously was:
```yml
runs:
  using: docker
  image: "docker://chuhlomin/render-template:v1.10"
```

# render-template

See the [imported actions README file](render-template__README.md) for specific information.
