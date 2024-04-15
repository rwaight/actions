# Git revert examples

Examples to revert changes in a repo, primarily using `git revert`.  These examples come from the following sources:
- https://stackoverflow.com/questions/3293531/how-to-permanently-remove-few-commits-from-remote-branch
- https://christoph.ruegg.name/blog/git-howto-revert-a-commit-already-pushed-to-a-remote-reposit

## Revert an already pushed commit

**Important**: Make sure you specify which branches on `git push -f` or you might inadvertently modify other branches![*]

### Delete the last `n` commits

Example: Delete the last 4 commits:
```bash
git reset --hard HEAD~4
```

Then run the following command (on your local machine) to force the remote branch to rewrite its history:
```bash
git push --force
```


### Delete to a specific commit ID

Retrieve the desired commit ID by running
```bash
git log
```

In the example, the desired commit is `8675309`.

Then you can replace `HEAD~N` with the desired commit ID like this:
```bash
git reset --hard 8675309
```

If you want to keep changes on file system and just modify index (commit history), use `--soft` flag like `git reset --soft HEAD~4`. Then you have chance to check your latest changes and keep or drop all or parts of them. In the latter case running `git status` shows the files changed since `<desired-commit-id>`. If you use `--hard` option, `git status` will tell you that your local branch is exactly the same as the remote one. If you don't use `--hard` nor `--soft`, the default mode is used that is `--mixed`. In this mode, `git help reset` says:
> Resets the index but not the working tree (i.e., the changed files are preserved but not marked for commit) and reports what has not been updated.


### Revert the full commit

```bash
git revert 8675309
```


### Delete the last commit

On a remote branch:
```bash
git push <<remote>> +8675309^:<<BRANCH_NAME_HERE>>
```

On a local branch:
```bash
git reset HEAD^ --hard
git push <<remote>> -f
```

Where `+8675309` is your commit hash and git interprets `x^` as the parent of `x`, and `+` as a forced non-fastforwared push.


### Delete the commit from a list

```bash
git rebase -i 8675309^
```

This will open and editor showing a list of all commits. Delete the one you want to get rid off. Finish the rebase and push force to repo.

```bash
git rebase --continue
git push <remote_repo> <remote_branch> -f
```


### Remove commits from remote without removing from local

clean way of removing your commits from the remote repository without losing your work

```bash
git reset --soft HEAD~1 # 1 represents only last 1 commit 
git stash # hold your work temporary storage temporarily.
git pull # bring your local in sync with remote
git reset --hard HEAD~1 # hard reset 1 commit behind (deletes local commit)
git push -f # force push to sync local with remote
git stash pop # get back your unpushed work from stash
```

