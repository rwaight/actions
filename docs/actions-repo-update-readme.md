## Keeping the README updated in this actions monorepo


### Updating the README

Keep the README updated with the current list of actions.

<details><summary>commands to list directories (click to expand)</summary>

#### Get the categories from the root directory
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 1 -I '.git|.github|archive|assets|composite|docs|examples|test' --noreport
```

#### Get the actions by category
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|.github|archive|assets|composite|docs|examples|test' --noreport
```


#### Get the top two levels of directories from the root directory of the repo
```bash
# two levels of directories, using find
find . -type d -maxdepth 2

# two levels of directories, using tree
tree . -d -L 2

# two levels of directories, using tree, without the report
tree . -d -L 2 --noreport
```

#### Get the directories by category with `find`
```bash
# store the categories into an array to use in a for loop
categories=(builders chatops git github releases utilities)

# get the action names by category, using find
for item in ${categories[@]}; do find $item -type d -maxdepth 1; done

# not fancy way, using cut, to get the action names below their category
for item in ${categories[@]}; do find $item -type d -maxdepth 1 | cut -d'/' -f2-; done

# similar to above, but with sed
for item in ${categories[@]}; do find $item -type d -maxdepth 1 | sed 's,^[^/]*/,,'; done
```

#### Get the directories by category with `tree`
```bash
# store the categories into an array to use in a for loop
categories=(builders chatops git github releases utilities)

# get the action names by category, using tree
for item in ${categories[@]}; do tree $item -d -L 1; done
```

#### Filter out the non-category directories with `tree`
```bash
# use the '-I' option to exclude the non-category directories
tree . -d -L 2 -I '.git|.github|archive|assets|composite|docs|examples|test' --noreport
```

</details>

