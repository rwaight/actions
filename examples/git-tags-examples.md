# Git tag examples

## Getting tags on a git repository

Use `git describe --tags` to get the tags.

#### Examples using git describe

<details><summary>Examples using git describe (click to expand)</summary>

### Examples using git describe

Using `git describe --tags`:
```bash
git describe --tags
## output
v0.2.1-15-g7a82bbe
```

Using `git describe`
```bash
git describe
## output
v0.1.2-39-g7a82bbe
```

Using `git describe --abbrev=0 --tags` to get the tag from the current branch
```bash
git describe --abbrev=0 --tags
## output
v0.2.1
```

Using `git describe` with `git rev-list` to get tags across all branches, not just the current branch
```bash
git describe --tags `git rev-list --tags --max-count=1`
## output
v0.2.1
```

</details>


#### Other examples

<details><summary>Other git describe examples (click to expand)</summary>

### Other examples using git describe

Get the latest tagged version and remove the `v` prefix:
```bash
git tag --sort=committerdate | grep -E '[0-9]' | tail -1 | cut -b 2-7
## output
0.2.1
```

Using `git describe` with `--abbrev` set to `0`
```bash
git describe --abbrev=0
## output
v0.1.2
```

</details>


### Sorting tags


#### Using the --sort option

From https://stackoverflow.com/questions/14273531/how-to-sort-git-tags-by-version-string-order-of-form-rc-x-y-z-w?#answer-22634649
> With Git 2.0 (June 2014), you will be able to specify a sorting order!

Using `--sort=<type>`

> **Sort in a specific order.**
> Supported type is:
> * "`refname`" (lexicographic order),
> * "`version:refname`" or "`v:refname`" (tag names are treated as versions).
> 
> Prepend "`-`" to reverse sort order.

So, if you have:
```bash
git tag foo1.3 &&
git tag foo1.6 &&
git tag foo1.10
```

Here is what you would get:
```bash
# lexical sort
git tag -l --sort=refname "foo*"
foo1.10
foo1.3
foo1.6

# version sort
git tag -l --sort=version:refname "foo*"
foo1.3
foo1.6
foo1.10

# reverse version sort
git tag -l --sort=-version:refname "foo*"
foo1.10
foo1.6
foo1.3

# reverse lexical sort
git tag -l --sort=-refname "foo*"
foo1.6
foo1.3
foo1.10
```


#### Examples using git tag to sort tags

Sort by `-taggerdate`
```bash
git tag --sort=-taggerdate
## output
v0.1.2
v0.1.1
v0
v0.1.0
v0.2
v0.2.0
v0.2.1
```

Sort by `taggerdate`
```bash
git tag --sort=taggerdate
## output
v0
v0.1.0
v0.2
v0.2.0
v0.2.1
v0.1.1
v0.1.2
```

Sort by `-committerdate`
```bash
git tag --sort=-committerdate
## output
v0.2.1
v0
v0.2
v0.2.0
v0.1.0
v0.1.1
v0.1.2
```

Sort by `committerdate`
```bash
git tag --sort=committerdate
## output
v0.1.1
v0.1.2
v0.1.0
v0
v0.2
v0.2.0
v0.2.1
```

### Getting the latest tag

You can use any of the following commands to get the latest tag

#### Using `git ls-remote`

Using `git ls-remote --tags --sort=committerdate`:
```bash
git ls-remote --tags --sort=committerdate | grep -o 'v.*' | sort -r
## output
From https://github.com/rwaight/actions.git
v0.2.1
v0.2.0
v0.2
v0.1.2^{}
v0.1.2
v0.1.1^{}
v0.1.1
v0.1.0
v0
```

Using `git ls-remote --tags --sort=committerdate | grep -o 'v.*'`:
```bash
git ls-remote --tags --sort=committerdate | grep -o 'v.*'
## output
v0.1.1
v0.1.2
v0.1.0
v0.1.1^{}
v0.1.2^{}
v0.2.0
v0
v0.2
v0.2.1
```

Using `git ls-remote --tags --sort=taggerdate | grep -o 'v.*' | sort -r`:
```bash
git ls-remote --tags --sort=taggerdate | grep -o 'v.*' | sort -r
## output
From https://github.com/rwaight/actions.git
v0.2.1
v0.2.0
v0.2
v0.1.2^{}
v0.1.2
v0.1.1^{}
v0.1.1
v0.1.0
v0
```

#### Using `git tag`

Using `git tag --sort=-taggerdate | tail -1`:
```bash
git tag --sort=-taggerdate | tail -1
## output
v0.2.1
```

Using `git tag --sort=committerdate | grep -o 'v.*' | sort -r`:
```bash
git tag --sort=committerdate | grep -o 'v.*' | sort -r
## output
v0.2.1
v0.2.0
v0.2
v0.1.2
v0.1.1
v0.1.0
v0
```

Using `git tag --sort=committerdate | grep -o 'v.*' | sort -r | head -1`:
```bash
git tag --sort=committerdate | grep -o 'v.*' | sort -r | head -1
## output
v0.2.1
```

#### Using `git for-each-ref`

Using `git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags`:
```bash
git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags
## output
refs/tags/v0.1.0 Mon Mar 11 12:10:23 2024 -0500
refs/tags/v0.1.1 Mon Mar 11 13:37:32 2024 -0500
refs/tags/v0.1.2 Mon Mar 11 13:50:12 2024 -0500
refs/tags/v0 Mon Mar 11 20:00:06 2024 -0500
refs/tags/v0.2 Mon Mar 11 20:00:06 2024 -0500
refs/tags/v0.2.0 Mon Mar 11 20:00:06 2024 -0500
refs/tags/v0.2.1 Thu Mar 14 11:39:55 2024 -0500
```


#### Examples using git tag

<details><summary>Examples using git tag (click to expand)</summary>

### Examples using git tag

Using `git tag -l`:
```bash
git tag -l
## output
v0
v0.1.0
v0.1.1
v0.1.2
v0.2
v0.2.0
v0.2.1
```

Using `git tag -l | tail -1`:
```bash
git tag -l | tail -1
## output
v0.2.1
```

Using `git tag | sort -V`:
```bash
git tag | sort -V
## output
v0
v0.1.0
v0.1.1
v0.1.2
v0.2
v0.2.0
v0.2.1
```

</details>


#### Examples using git rev-list

<details><summary>Examples using git rev-list (click to expand)</summary>

### Examples using git rev-list

Using `git rev-list --tags --max-count=1`:
```bash
git rev-list --tags --max-count=1
## output
d702f1832400f86753094a219e8383ae817ade34
```

</details>



## templates below

````markdown
### command template

Using `command_here`:
```bash
command_here
## output
output_here
```

````
