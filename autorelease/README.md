# Actions used for Autorelease

**Note**: The original [process notes document](autorelease-process-notes.md) is now sourced in **this directory** with a symlink to the [`docs/` directory](../docs/).  The symlink was created with:
```bash
$ cd path/to/repo
$ git config --get core.symlinks
false
$ git config core.symlinks true
$ git config --get core.symlinks
true
$ cd ./docs/
$ ln -s ../autorelease/autorelease-process-notes.md ./autorelease-process-notes.md
$ cd ..
$ git add ./docs/autorelease-process-notes.md
$ git commit -m 'docs: symlink for autorelease process notes'
```

<!--- for windows users... from the docs directory

use either:
path/to/repo/docs> cmd /c mklink .\autorelease-process-notes.md ..\autorelease\autorelease-process-notes.md

or

path/to/repo/docs> New-Item -ItemType SymbolicLink -Target ..\autorelease\autorelease-process-notes.md -Path .\autorelease-process-notes.md

--->

# Autorelease Process Notes

Autorelease Reusable Workflows

## Autorelease Step 1

### Autorelease Step 1a

**Get the next version for the release**

- _Objective_: Check inputs, validate vars file, get next version, determine next steps
- _Status_: **INCOMPLETE**

<!---  # Jobs in Step 1

#   a. Get the next version for the release                        (get-next-version)

 --->

Get the next version for the release (Step 1a)

1. Check the user inputs
    - _Status_: **INCOMPLETE**, this feature is missing
    - _Job Name_: (job is `TBD`)
2. Validate repo variables file
    - _Status_: **INCOMPLETE**, this feature is missing
    - _Job Name_: (job is `TBD`)
3. Get the next version
    - _Status_: 
    - _Job Name_: (job is `get-next-version`)
4. Make sure the proper labels exist
    - _Status_: **INCOMPLETE**, this feature is missing
    - _Job Name_: (job is `TBD`)
5. Determine the next step for inputs and outputs...
    - _Status_: **INCOMPLETE**, this feature is missing
    - _Job Name_: (job is `TBD`)


<!---  #### Jobs in Step 1a Get the next version for the release

#### Jobs in Step 1a Get the next version for the release
#   a. Get the next version for the release
#       1. Check the user inputs                              INCOMPLETE, this feature is missing  (job is TBD)
#       2. Get the next version                               (get-next-version)
#       3. Make sure the proper labels exist                  INCOMPLETE, this feature is missing  (job is TBD)
#       4. Determine the next step for inputs and outputs...  INCOMPLETE, this feature is missing  (job is TBD)
#### 
# notes about this job as part of step 1
#   Check inputs, get next version, determine next steps

 --->
