#! /bin/bash
PAGES=(index features netcfg netcfg-profiles)

for page in ${PAGES[@]}; do
    rm ${page}.html
    pandoc --toc  -w html --email-obfuscation=javascript -B website/header.html -A website/footer.html -o ${page}.html $page
done
