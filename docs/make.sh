#! /bin/bash
PAGES=(ethernet features wireless)

make_page() {
    echo '<html><body>'
    grep -v '^%' $1 | markdown -x def_list -x headerid /dev/stdin
    echo '</body></html>'
}

for page in ${PAGES[@]}; do
    rm -f ${page}.html
    if which pandoc &>/dev/null; then
        pandoc -s --toc -w html --email-obfuscation=javascript -c header.css -o ${page}.html $page
    else
        make_page $page > ${page}.html
    fi
done

# Generate manpages
if which pandoc &>/dev/null; then
    pandoc -s -w man -o netcfg.8 netcfg.txt
fi
