# Actions used with version releases

This directory contains actions that are used with version releases.

#### Using bash to increment versions

Thanks to [the kind person who posted this solution](https://stackoverflow.com/questions/59435639/fix-shell-script-to-increment-semversion), here is a way to increment versions in bash.

```bash
version=0.2.1
echo $version
## output
0.2.1
```

Increment a PATCH version:
```bash
echo "$version" | awk 'BEGIN{FS=OFS="."} {$3+=1} 1'
## output
0.2.2
```

Increment a MINOR version:
```bash
echo "$version" | awk 'BEGIN{FS=OFS="."} {$2+=1;$3=0} 1'
## output
0.3.0
```

Increment a MAJOR version:
```bash
echo "$version" | awk 'BEGIN{FS=OFS="."} {$1+=1;$2=0;$3=0} 1'
## output
1.0.0
```

