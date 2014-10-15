#!/bin/sh

if [ "$1" == "update" ]; then
    git submodule foreach "git pull origin master"
    sh genDocset.sh
    exit 0
fi

RES="sweetjs.docset/Contents/Resources/"
DOC="${RES}Documents/"
IDX="${RES}docSet.dsidx"

### clean all up
rm -rf sweetjs.docset
rm -f sweetjs.tgz

### create directory structure
mkdir -p sweetjs.docset/Contents/Resources/Documents/

### copy files
cp files/icon.png sweetjs.docset/icon.png
cp files/Info.plist sweetjs.docset/Contents/Info.plist

# ### build documentation
cp sweet.js/doc/main/sweet.html "${DOC}index.html"

### create sql file
sqlite3 $IDX "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
sqlite3 $IDX "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"

### fill index
grep "h1 id" "${DOC}index.html" | while read -r line; do
    NAME=$(echo $line | sed 's/<h1 id.*<span.*>\(.*\)<\/span>\(.*\)<\/h1>/\1 -\2/') 
    LINK="index.html#$(echo $line | sed 's/<h1 id=\"\(.*\)\"><span.*/\1/')"
    sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Section', '$LINK');"
done

grep "h2 id" "${DOC}index.html" | while read -r line; do
    NAME=$(echo $line | sed 's/<h2 id.*<span.*>\(.*\)<\/span>\(.*\)<\/h2>/\1 -\2/') 
    LINK="index.html#$(echo $line | sed 's/<h2 id=\"\(.*\)\"><span.*/\1/')"
    sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Section', '$LINK');"
done

grep "h3 id" "${DOC}index.html" | while read -r line; do
    NAME=$(echo $line | sed 's/<h3 id.*<span.*>\(.*\)<\/span>\(.*\)<\/h3>/\1 -\2/') 
    LINK="index.html#$(echo $line | sed 's/<h3 id=\"\(.*\)\"><span.*/\1/')"
    sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Section', '$LINK');"
done

# # macros
# sed -n '/id=.basics-1/,/id=.literals/p' "${DOC}api.html" | grep "h4 id" | while read -r line; do
#     NAME=$(echo $line | sed 's/<h4 id.*><code>\(.*\)<\/code><\/h4>/\1/')
#     LINK="api.html#$(echo $line | sed 's/<h4 id=\"\(.*\)\">.*/\1/')"
#     sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Macro', '$LINK');"
# done

# # literals
# sed -n '/id=.literals/,/id=.arithmetics/p' "${DOC}api.html" | grep "h4 id" | while read -r line; do
#     NAME=$(echo $line | sed 's/<h4 id.*><code>\(.*\)<\/code><\/h4>/\1/')
#     LINK="api.html#$(echo $line | sed 's/<h4 id=\"\(.*\)\">.*/\1/')"
#     sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Literal', '$LINK');"
# done

# # functions
# sed -n '/id=.functions/,/id=.atoms/p' "${DOC}api.html" | grep "h4 id" | while read -r line; do
#     NAME=$(echo $line | sed 's/<h4 id.*><code>\(.*\)<\/code><\/h4>/\1/')
#     LINK="api.html#$(echo $line | sed 's/<h4 id=\"\(.*\)\">.*/\1/')"
#     sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Function', '$LINK');"
# done

# # methods
# sed -n '/id=.arithmetics/,/id=.functions/p' "${DOC}api.html" | grep "h4 id" | while read -r line; do
#     NAME=$(echo $line | sed 's/<h4 id.*><code>\(.*\)<\/code><\/h4>/\1/')
#     LINK="api.html#$(echo $line | sed 's/<h4 id=\"\(.*\)\">.*/\1/')"
#     sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Method', '$LINK');"
# done

# sed -n '/id=.atoms/,$ p' "${DOC}api.html" | grep "h4 id" | while read -r line; do
#     NAME=$(echo $line | sed 's/<h4 id.*><code>\(.*\)<\/code><\/h4>/\1/')
#     LINK="api.html#$(echo $line | sed 's/<h4 id=\"\(.*\)\">.*/\1/')"
#     sqlite3 $IDX "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$NAME', 'Method', '$LINK');"
# done


### pack things up
# tar --exclude='.DS_Store' -cvzf sweetjs.tgz sweetjs.docset

echo done.
