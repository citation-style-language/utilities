# Python script for additional style validation
# Author: Rintze M. Zelle
# Version: 2011-12-17
# * Requires lxml library (http://lxml.de/)
#
# Add CC by-sa license

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
uniqueStrings = {}
styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

for style in styles:
    parsedStyle = etree.parse(style)
    styleElement = parsedStyle.getroot()
    
    rightsStrings = []
    try:
        rightsStrings = styleElement.findall(".//{http://purl.org/net/xbiblio/csl}rights")
        for rightsString in rightsStrings:
            rightsString = rightsString.text
            if rightsString in uniqueStrings:
                uniqueStrings[rightsString] += 1
            else:
                uniqueStrings[rightsString] = 1
    except:
        pass

sortedStrings = sorted(uniqueStrings, key=uniqueStrings.get, reverse=True)

print("Rights:")
for string in sortedStrings:
    print('"' + string + '"' + ": %d" % (uniqueStrings[string]))
