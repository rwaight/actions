## Multiline strings

From https://github.com/chuhlomin/render-template/issues/16, titled **Multiline strings are being stripped of newlines**

### Original Comment

From https://github.com/chuhlomin/render-template/issues/16#issue-2002072132

> I am supplying a multiline string of features and notes to a template using the syntax as stated in the actions documentation
> 
> ```
> {name}<<{delimiter}
> {value}
> {delimiter}
> ```
> 
> [https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings](url)
> 
> It appears to go into the action just fine
> 
> ![image](https://private-user-images.githubusercontent.com/57716459/284257855-d0e947a5-a76c-4454-8ada-751294edf716.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDY4MDQ5MTksIm5iZiI6MTcwNjgwNDYxOSwicGF0aCI6Ii81NzcxNjQ1OS8yODQyNTc4NTUtZDBlOTQ3YTUtYTc2Yy00NDU0LThhZGEtNzUxMjk0ZWRmNzE2LnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAyMDElMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMjAxVDE2MjMzOVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPThhMjdlNzBkNDA0NDY1ODE5YTExNGUxMWRiNGQzNmEyNjViMGIwYTU3Y2E2ZWYzZjAzNDNkMWIyMDE1YzY5MTYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.lFkAwqf5N3wXZkoVhJkO25GwByAR_i7zyANXjCt8KLs)
> 
> But once it renders the new lines have been removed (note that the notes have an extra line between each which is stripped)
> 
> ![image](https://private-user-images.githubusercontent.com/57716459/284258059-438a899a-61f7-4b5f-873d-9a544bd1462c.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDY4MDQ5MTksIm5iZiI6MTcwNjgwNDYxOSwicGF0aCI6Ii81NzcxNjQ1OS8yODQyNTgwNTktNDM4YTg5OWEtNjFmNy00YjVmLTg3M2QtOWE1NDRiZDE0NjJjLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAyMDElMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMjAxVDE2MjMzOVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTg2ODQ4NGZlMWRkOTliNTFiNzA3ODk2MGU3NWVlMGE4MzlmOTUxMzkyNTlmNTU1MGM2ODdlZjZlYmUzZjNiYmImWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.Eysq4hXzN-YmV3lNSMoZ4TfGnIUplRSNavFE_Wbr9_Q)
> 
> Code from the action just in case I'm not supplying the vars in the intended way
> 
> ```
>           {
>             echo 'pr_features<<EOF'
>             echo "${FEATURE_COMMITS}"
>             echo EOF
>           } >> $GITHUB_OUTPUT
> ```
> 
> ```
> name: Render Template
>         id: template
>         uses: chuhlomin/render-template@v1
>         with:
>           template: .github/pull_request_template.md
>           vars: |
>             pr_date: ${{ steps.get_current_date.outputs.current_date }}
>             pr_feature: "${{ steps.pr_features.outputs.pr_features }}"
>             pr_notes: "${{ steps.pr_notes.outputs.pr_notes }}"
> ```



### Reply 1

From https://github.com/chuhlomin/render-template/issues/16#issuecomment-1823711376

> Hi @andyatterton,
> 
> I think this is happening because of how YAML handles strings with multilines. See https://yaml-multiline.info/
> 
> In your "pr_notes" step, try piping the output to `| awk '{printf "%s\\n", $0}` to convert newlines into literal "\n".



### End
