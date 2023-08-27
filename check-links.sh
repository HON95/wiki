#!/bin/bash

# Find all internal, cross-page markdown links and checks if the page exists.
# Must be run at the root of the site.

set -eu -o pipefail

ignored_web_urls="
/
"

function print_error {
    src_file="$1"
    web_url="$2"
    target_file="$3"
    msg="$4"

    echo
    echo "Error: $msg"
    echo "Source file: $src_file"
    echo "Web URL: $web_url"
    echo "Target file: $target_file"
}

# Checks if real file for MD-link input exists.
function check_link {
    src_file="$1"
    md_link="$2"
    name=$(grep -Po '(?<=^\[)[^\[\]]*(?=\])' <<<$md_link || true)
    web_url=$(grep -Po '(?<=\()[^\(\)]*(?=\)$)' <<<$md_link || true)
    target_file=$(sed 's|/$|.md|' <<<$web_url)

    # Ignore external (fully-qualified) URLs.
    if grep -P '^https?://' <<<$web_url >/dev/null; then
        return
    fi

    # Ignore if not ending with "/".
    if ! grep -P '/$' <<<$web_url >/dev/null; then
        return
    fi

    # Ignore special targets.
    if grep -Fx "$web_url" <<<$ignored_web_urls >/dev/null; then
        return
    fi

    # Show error if using relative path.
    if grep -P '/$' <<<$target_file >/dev/null; then
        print_error "$src_file" "$web_url" "$target_file" "Relative paths not allowed."
        return
    fi

    # Show error if file does not exist.
    if [[ ! -f $target_file ]]; then
        print_error "$src_file" "$web_url" "$target_file" "Target file does not exist."
        return
    fi
}

# Find all markdown pages and check.
for file in $(find "." -type f -name '*.md' | sed 's|^\./||' | LC_ALL=C sort -t. -k1,1); do
    # Extract MD-links and check them.
    md_link_regex='\[[^\[\]]*\]\([^\(\)]*\)'
    { grep -Po "$md_link_regex" "$file" || true; } | while read -r md_link; do
        check_link "$file" "$md_link"
    done
done
