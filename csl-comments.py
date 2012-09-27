# Python script to count comment strings in cs:info section of styles
# Author: Rintze M. Zelle
# Version: 2012-09-26
# * Requires lxml library (http://lxml.de/)
#
# Prints the comments within the cs:info section

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
uniqueStrings = {}
styles = []
stylesTested = 0

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

for style in styles:
    parsedStyle = etree.parse(style)
    styleElement = parsedStyle.getroot()
    
    rightsStrings = []
    try:
        rightsStrings = styleElement.xpath("//cs:info/comment()", namespaces={"cs": "http://purl.org/net/xbiblio/csl"})
        for rightsString in rightsStrings:
            rightsString = rightsString.text
            if rightsString in uniqueStrings:
                uniqueStrings[rightsString] += 1
            else:
                uniqueStrings[rightsString] = 1
        stylesTested += 1
    except:
        print(style)
        pass

sortedStrings = sorted(uniqueStrings, key=uniqueStrings.get, reverse=True)

print("Styles tested: " + "%d" % (stylesTested))
print("Rights:")
for string in sortedStrings:
    print('"' + string + '"' + ": %d" % (uniqueStrings[string]))
