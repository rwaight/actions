## Updates and releases to this actions monorepo

In order to push changes to the actions, so that any downstream workflows can use the changes **or** when any of the actions or workflows need to be updated.  The current process for this `actions` repo is:
1. Set up your workstation with this repo and to sign commits and tags
   1. Ensure you have a local copy of this `actions` repo cloned to your workstation
   2. Follow GitHub's [signing tags](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-tags) docs to ensure you can sign tags from your workstation
2. Create a development branch and make the proper code changes
    -  You should use the `dev-*` naming convention (example: `dev-unique_branch_name_here`)
    -  Update the specific action or workflow, as needed
3. Determine the next version for this `actions` repo
    - Check with [`@rwaight`](https://github.com/rwaight) to determine the **version level change**
    - The changes should be either `patch`, `minor`, or `major`
    - Make note of the **next version**, as it will be used later in the release process
4. Open a pull request from your development branch into `base: main`
    - Be sure to include the proper `version:` label
5. Have your pull request reviewed, then merge the changes into `main`
   1. Make a note of the **commit** that was merged into main (example: "merged commit `8675309` into `main`")
   2. The value listed for **commit** is the first seven (7) characters of the commit hash
6. Update your local clone of this `actions` repo with the changes from `main`
   1. If you have your development branch open, issue `git stash` to save the local changes
   2. Fetch the remote branches with `git fetch --all`
   3. Switch to the `main` branch with `git checkout main`
   4. Use `git pull origin main` to ensure your local clone is updated from origin
7. Verify your local clone has the latest commit to `main`
   1. Use one of the following commands to get the list of recent commits:
      - `git log --pretty=format:"%h - %an, %ar : %s" --since=3.days`
      - `git log --pretty=oneline`
      - `git log --pretty=format:"%h - %an, %ar : %s" --since=2.weeks`
      - `git log --pretty=format:"%h - %an, %ar : %s" --since=1.week`
   2. Look for the **commit** that was merged into main
   3. Alternatively, pipe the output from the `git log` command into `grep` and add the **commit**
      - Example: `git log --pretty=oneline | grep 8675309`
   4. Use `echo` to remind yourself of the commit that will be used for the new `git tag`, example:
      1. `echo "the commit linked to v1.1.1 is 8675309"`
8. Create a **signed** `git tag` and verify the signed tag
   1. Follow GitHub's [signing tags](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-tags) docs to ensure you can sign tags from your workstation
   2. You will use the `-a`, `-m`, and `-s` options when creating and signing the tag
   3. Use `git tag` and the `-s` option to create the tag for the **next version**, example:
      - `git tag -a v1.1.1 -m "Code updated to v1.1.1" -s 8675309`
   4. You will use the `-v` option to verify the signed tag
   5. Sign the tag with `git tag -v v1.1.1`
   6. Confirm you see a `gpg: Good signature` response from issuing the `git tag -v` command
9. Push the **signed and verified** tag to this repo (origin)
   1.  Be cerain that you have signed and verified the tag before proceeding
   2.  Push the **signed and verified** tag with `git push -f origin v1.1.1`
10. Ask `@rwaight` why this is not part of a GitHub workflow (or a composite action) in this repo... because it should be
