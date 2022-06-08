#!/bin/bash

# Script to generate the index page.
# Must be run at the root of the site.

set -eu -o pipefail

index_file="index.md"

# Create/clean the current index file
> "$index_file"

# Add header
cat >> "$index_file" <<EOF
---
no_breadcrumbs: true
no_toc: true
---
{% include header.md %}

Random collection of config notes and miscellaneous stuff. _Technically not a wiki._

_(Alphabetically sorted, so the ordering might seem a bit strange.)_
EOF

# Add categories and pages
for dir in $(find . -mindepth 1 -type d | sort | sed 's|^\./||'); do
    # Check if the dir contains a name file
    if [[ ! -f $dir/_name ]]; then
        continue
    fi
    dir_name="$(head -n1 "$dir/_name")"

    echo >> "$index_file"
    echo "## $dir_name" >> "$index_file"
    echo >> "$index_file"

    for file in $(find "$dir" -type f -name '*.md' | sort -t. -k1,1); do
        link="$(echo $file | sed 's|^|/|' | sed 's|\.md$|/|')"
        name="$(grep -Po -m1 '(?<=^title: ).+$' $file | sed -e 's|^\"||' -e "s|^'||" -e 's|\"$||' -e "s|'$||" || true)"
        if [[ $name == "" ]]; then
            echo "Missing name for page: $file" >&2
            exit 1
        fi
        echo "- [$name]($link)" >> "$index_file"
    done
done

# Add footer
cat >> "$index_file" <<EOF

{% include footer.md %}
EOF
