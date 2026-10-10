#!/usr/bin/env zsh
# Get modified, staged, and untracked files that physically exist on disk
files=(${(f)"$( { git diff --name-only; git diff --staged --name-only; git ls-files --others --exclude-standard; } | sort -u | while read f; do [ -f "$f" ] && echo "$f"; done )"})

if (( ${#files} )); then
    hx "${files[@]}"
else
    hx .
fi
