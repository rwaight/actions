## list of strings as a variable

### Original Comment

From https://github.com/chuhlomin/render-template/issues/12

> Hello! I have the following template:
> 
> ```yml
> {
>   "labels": {{ .labels }}
> }
> ```
> 
> I want to get the following result:
> 
> ```json
> {
>   "labels": ["label1", "label2"]
> }
> ```
> 
> Note, it should be valid JSON. Does this action support it? How can I do that? Thanks in advance


### Reply 1

From https://github.com/chuhlomin/render-template/issues/12#issuecomment-1637197787

> Hi @emilt27,
> 
> > Does this action support it? How can I do that?
> 
> It depends on how you want to pass list of labels to the action.
> 
> **Option 1. Pass array of strings**
> 
> If list of labels is static, you can pass it as an array of strings:
> 
> Workflow file:
> 
> ```yaml
>       - name: Render template
>         uses: chuhlomin/render-template@v1.7
>         id: render
>         with:
>           template: json.txt
>           vars: |
>             lables:
>                 - label1
>                 - label2
>             labels_the_other_way: ["label1", "label2"]
> ```
> 
> Template:
> 
> ```
> {
>   "labels": [
>     {{- $first := true }}
>     {{- range .labels }}
>     {{- if $first }}{{ $first = false }}{{ else }},{{ end }}
>     "{{ . }}"
>     {{- end }}
>   ]
> }
> ```
> 
> **Option 2. Pass JSON-encoded string**
> 
> If list of labels is dynamic, the easiest way is to pass it as a JSON string:
> 
> Workflow file:
> 
> ```yaml
>       - name: JSON encode labels
>         shell: bash
>         id: json
>         run: |
>           labels=("label1" "label2")
>           labels_json=$(printf '%s\n' "${labels[@]}" | jq -R . | jq -s .)
>           echo "::set-output name=json::$labels_json"
> 
>       - name: Render template
>         uses: chuhlomin/render-template@v1.7
>         id: render
>         with:
>           template: json.txt
>           vars: |
>             lables: ${{ steps.json.outputs.json }}
> ```
> 
> Template:
> 
> ```
> {
>   "labels": {{ .labels }}
> }
> ```
> 
> **Option 3. New template functions**
> 
> I can add two template functions to split string into array and convert it to JSON array. This is how it may look like:
> 
> Workflow file:
> 
> ```yaml
>       - name: Render template
>         uses: chuhlomin/render-template@v1.7
>         id: render
>         with:
>           template: json.txt
>           vars: |
>             lables: label1,label2
> ```
> 
> Template:
> 
> ```
> {
>   "labels": {{ .labels | split "," | json }}
> }
> ```
> 
> Which option do you prefer?



### End
