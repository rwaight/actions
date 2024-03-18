## Formatting options for placeholders

### Original Comment

From https://github.com/chuhlomin/render-template/issues/8

<details><summary> original comment (click to expand) </summary>

> This may be a bit out of scope for this action, but I feel like it could be a neat addition to have additional formatting options available for the different vars added in a template file.
> 
> To give an example: I'm currently implementing this action in a workflow to post a comment which contains links to the build artifact to a PR. One of the vars I would include within this workflow is an expire date for when the artifacts will become unavailable (I use GitHub Action's artifact system).
> 
> My full template is like this:

```markdown
<!-- pr-build comment -->

![badge](<!-- url omitted. Too long -->)

The build of this PR has completed successfully!  
Below can you find a link for a direct download of the artifacts for this PR (GitHub Account required).

File expires: `{{ .expire-date }}`

| Name     | Link            |
|----------|-----------------|
| Commit   | {{ .commit }}   |
| Logs     | {{ .logs }}     |
| Download | {{ .download }} |
```

> This, if I setup the action properly, would result in a Date such as `2023-08-06T15:08:28Z` which while readable, isn't that pretty to look at.
> 
> So I would like to propose some options to render certain vars in a different way.
> 
> Right now can I think of the following options:
> 
> * `number`
>   
>   * Format: `{{ .<var> | number [format] }}`
>   * Renders the provided String as a number with proper separators (commas and dots)
>   * Default format would be `#,###,###.##` but could be overriden by providing your own `[format]`.
> * `link`
>   
>   * Format: `{{ .<var> | link }}`
>   * Renders the provided String as an embeded link, with the name being the var. I.e. `{{ .download | link }}` becomes `[download](https://example.com)`
> * `date`
>   
>   * Format: `{{ .<var> | date [format] }}`
>   * Renders the provided String as a Date.
>   * Default format would be `dd/mm/yyyy hh:MM:ss z` but could be overriden by providing your own `[format]`
> 
> I hope this is doable, but would also understand if this entire thing would be out of scope for this action itself.

</details>

### Reply 1

Then from https://github.com/chuhlomin/render-template/issues/8#issuecomment-1539369436

> Hey @Andre601, I like that idea and been thinking about something like this for some time.
> 
> Check out this PR: #9 I've added a few functions like `date`, `mdlink` and `numbers`. Usage example:

```
{{ "2023-08-06T15:08:28Z" | date "2006-01-02" }}
{{ "https://github.com" | mdlink "download" }}
{{ "1000" | number }}
```

> `date` accepts Go time layout, see examples here: https://pkg.go.dev/time#pkg-constants
> 
> Let me know what you think.

### Reply 2

Then from https://github.com/chuhlomin/render-template/issues/8#issuecomment-1540513660


> Okay.
> 
> As a (hopefully) final comment, this is the most recent output from the action:
> 
> > `failed to render template: template: ./.github/assets/pr-comments/success.md:7: function "date" not defined`
> 
> The latest version of the template: https://github.com/Andre601/AdvancedServerList/blob/608c617b17b8e517f662bef350f4c229bab0856d/.github/assets/pr-comments/success.md
> 
> The placeholders aren't incomplete. It's just the markdown renderer messing stuff up because of the table.
> 
> Where the action is used: https://github.com/Andre601/AdvancedServerList/blob/608c617b17b8e517f662bef350f4c229bab0856d/.github/workflows/pr-comment.yml#L77-L91
> 
> (Sorry for that much spam)

### Reply 3

From https://github.com/chuhlomin/render-template/issues/8#issuecomment-1541331106

> I figured out what's was the issue: `gopkg.in/yaml.v3` parses string like `2023-08-06T15:08:28Z` directly into `time.Time` structure. Now supporting both `time.Time` and `string` in `date` func. Also, added support for optional `timezone` input.
> 
> See example here: https://github.com/chuhlomin/ip/pull/3/files Action run: https://github.com/chuhlomin/ip/actions/runs/4933077445/jobs/8816709010

```yaml
      - name: Render template
        uses: chuhlomin/render-template@funcs
        with:
          template: ./.github/assets/pr-comments/success.md
          result_path: rendered_template.md
          timezone: America/New_York
          vars: |
            link: https://github.com
            expire: 2023-08-06T15:08:28Z
```

> + template
 
```
{{ .link | mdlink "Link" }}
{{ .expire | date "02 Jan 2006 15:04:05" }}
```
 
> = result

```markdown
[Link](https://github.com/)
06 Aug 2023 11:08:28
```

### End
