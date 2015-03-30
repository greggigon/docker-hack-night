#!/bin/bash
#set -ex

sudo yum -y install pandoc

git clone https://github.com/greggigon/docker-hack-night.git

cd docker-hack-night

find . -type f -name '*.md' -print0 | while IFS= read -r -d '' file; do
    pandoc "$file" -o "${file}.html"
done

# set docs as browser home page
echo 'user_pref("browser.startup.homepage", "file:///home/vagrant/docker-hack-night/docs/index.html");' >> /home/vagrant/.mozilla/firefox/cw4qa3h5.default/prefs.js