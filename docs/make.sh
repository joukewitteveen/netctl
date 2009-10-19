#! /bin/bash
PAGES=(index ethernet features wireless)

for page in ${PAGES[@]}; do
    rm ${page}.html
    pandoc -s --toc -w html --email-obfuscation=javascript -c header.css -o ${page}.html $page
done
