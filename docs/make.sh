#! /bin/bash
PAGES=(features netcfg netcfg-profiles)

make_page() {
    echo '<html><body>'
    grep -v '^%' $1 | markdown -x def_list -x headerid /dev/stdin
    echo '</body></html>'
}

# HTML page generation
for page in ${PAGES[@]}; do
    rm -f ${page}.html
    if which pandoc &>/dev/null; then
        pandoc -s --toc -w html --email-obfuscation=javascript -c header.css -o ${page}.html $page.txt
    else
        make_page $page.txt > ${page}.html
    fi
done

# Generate manpages
if which pandoc &>/dev/null; then
    pandoc -s -w man -o netcfg.8 netcfg.txt
    pandoc -s -w man -o netcfg-profiles.5 netcfg-profiles.txt
fi

# vim: set ts=4 sw=4 et tw=0:
