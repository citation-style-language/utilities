#!/bin/bash

# Converts CSL 0.8 locale files to the CSL 1.0 format

# Location of CSL 1.0 en-US locale file
CSL10LocalesDirectory='../csl-locales/trunk/'

# Location of CSL 0.8 locale files
CSL08LocalesDirectory='../csl-locales/branches/0.8/'

# Location of saxon.jar
saxon='../jing-20081028/bin/saxon.jar'

localeTemplate=${CSL10LocalesDirectory}locales-en-US.xml
FILELIST="`find $CSL08LocalesDirectory -name locales-*.xml -not -name locales-en-US.xml`"
#echo $FILELIST
 for FILE in ${FILELIST}
   do
     languageCode=`echo ${FILE#*locales-}`
     languageCode=`echo ${languageCode%.xml}`
     # echo locales-${languageCode}.xml
     sed 's#<term name="no date">#<term name="no date" form="short">#g' $FILE > locales-xx-XX-temp.xml
     CORRECTEDFILE='locales-xx-XX-temp.xml'
     # Create a custom XLST stylesheet for each locale, run each sheet on the en-US template locale file
     findstring='locales\\locales-nl-NL.xml'
     sed "s#$findstring#$CORRECTEDFILE#g" update-locales.xsl > update-locales-temp.xsl
     java -jar $saxon -o ${CSL10LocalesDirectory}locales-${languageCode}.xml $localeTemplate update-locales-temp.xsl
   done

# Various tips and tricks:
# http://www.cs.wright.edu/~pmateti/Courses/333/Notes/bash-vars.html
# http://forums.oracle.com/forums/thread.jspa?threadID=982951&tstart=0
# http://episteme.arstechnica.com/eve/forums/a/tpc/f/96509133/m/466009161041
# http://www.linuxforums.org/forum/linux-programming-scripting/68862-sed-error-unknown-option-s.html
# http://www.linuxquestions.org/questions/programming-9/sed-doesnt-accept-variable-in-bash-script-325935/