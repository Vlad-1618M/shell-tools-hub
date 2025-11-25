
# Bash/Shell One-Liner Cheat Sheet:

### Basic Execution Loops:

>- These are for running a command a specific number of times:
>- `seq` - method based for loop:
```bash
for i in $(seq 1 10); do ./some_binary_file; done
```
>- `C` method for loops:
```bash
for ((i=0; i<10; i++)); do ./some_binary_file; done
```
>- `xargs` - method for loops:
```bash
seq 10 | xargs -I {} ./some_binary_file
```
>- while loop with a counter:
```bash
i=0; while [ $i -lt 10 ]; do ./some_binary_file; i=$((i+1)); done
```
___
### Time Delays Loops:
>- `C` method for loops + time delay::
```bash
for ((i=0; i<10; i++)); do ./some_binary_file; sleep 2; done
```

### Processing `.json` artifacts with `jq` lib:
```bash
for ((i=0; i<5; i++)); do ./some_binary_file | jq '.status'; sleep 1; done
```
>- write objects into `.json` artifacts:
```bash
{ for ((i=0; i<5; i++)); do ./some_binary_file; sleep 1; done; } | jq --slurp '.' > all_runs.json
{ for ((x=0; x<10; x++)); do ./some_binary_file; 2>/dev/null; sleep 2; done; } | jq --slurp '.' > all.json
```

```bash
{ for ((x=0; x<10; x++)); do ./some_binary_file; | awk '{print "{\"output\": \""$0"\"}"}'; sleep 2; done; } | jq --slurp '.' > all.json
```

```bash
{ for ((x=0; x<10; x++)); do ./some_binary_file | tr -dc '[:print:]' | awk '{printf "{\"output\": \"%s\"}", $0}'; sleep 2; done; } | jq --slurp '.' > all.json
```
___
