#!/bin/bash
set -ex

sudo yum -y install pandoc

git clone https://github.com/greggigon/docker-hack-night.git

cd docker-hack-night

find . -type f -name '*.md' -print0 | while IFS= read -r -d '' file; do
    pandoc "$file" -o "${file}.html"
done

