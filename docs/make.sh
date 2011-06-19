#! /bin/bash
PAGES=(ethernet features wireless)

make_page() {
    echo '<html><body>'
    grep -v '^%' $1 | markdown -x def_list -x headerid /dev/stdin
    echo '</body></html>'
}

for page in ${PAGES[@]}; do
    rm -f ${page}.html
    if [ -f /usr/bin/pandoc ]; then
        pandoc -s --toc -w html --email-obfuscation=javascript -c header.css -o ${page}.html $page
    else
        make_page $page > ${page}.html
    fi
done
