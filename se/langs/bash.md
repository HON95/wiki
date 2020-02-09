---
title: BASH
breadcrumbs:
- title: Software Engineering
- title: Languages
---
{% include header.md %}

- Options:
    - Example fo scripts: `set -euf -o pipefail`
    - `-e` (errexit): Exit script on command error, except in ultil loops, while loops, if-tests, list constructs, etc.
    - `-u` (nounset): Treat references to unset variables as an error and exit.
    - `-f` (noglob): Disable globbing (filename expansion).
    - `-o pipefail`: Cause pipelines to return the exit status of the last command in the pipe that returned a non-zero return value.
    - Most options have `+` and `-` variants which do the opposite thing.

{% include footer.md %}
