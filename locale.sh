#!/bin/bash

# Locations:
# http://bitbucket.org/bdarcus/csl-utils/src/tip/update-locales.xsl in script root
# Babelzilla locale files in locales folder, e.g.: ./locales/xx-XX/zotero/locales.xml
# delete sr-YU locale folder (not longer used)
# saxon.jar should be present at jing-20081028/bin/saxon.jar
# output goes to ./locales/locales-xx-XX.xml

FILELIST="`find . -name locales.xml`"
for FILE in ${FILELIST}
do
languageCode=`echo ${FILE#./locales/}`
languageCode=`echo ${languageCode%/zotero/locales.xml}`
# echo $languageCode
# echo locales-${languageCode}.xml
# run on English converted locale file, replace location of input file in XSLT
findstring='locales\\locales-nl-NL.xml'
echo $findstring
sed "s#$findstring#$FILE#g" update-locales.xsl > update-locales-temp.xsl
java -jar jing-20081028/bin/saxon.jar -o locales/locales-${languageCode}.xml locales-en-US-1.0.xml update-locales-temp.xsl
done

# http://www.cs.wright.edu/~pmateti/Courses/333/Notes/bash-vars.html
# http://forums.oracle.com/forums/thread.jspa?threadID=982951&tstart=0
# http://episteme.arstechnica.com/eve/forums/a/tpc/f/96509133/m/466009161041
# http://www.linuxforums.org/forum/linux-programming-scripting/68862-sed-error-unknown-option-s.html
# http://www.linuxquestions.org/questions/programming-9/sed-doesnt-accept-variable-in-bash-script-325935/

