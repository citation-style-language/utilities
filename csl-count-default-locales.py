# Python script to count default-locale values
# Author: Rintze M. Zelle
# Version: 2012-11-01
# * Requires lxml library (http://lxml.de/)
#
# Prints the default-locale values

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
uniqueStrings = {}
styles = []
stylesTested = 0

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
##for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
##    styles.append(os.path.join(stylepath))

for style in styles:
    parsedStyle = etree.parse(style)
    styleElement = parsedStyle.getroot()

    stylesTested += 1

    if "default-locale" in styleElement.attrib:
        defaultLocale = styleElement.get("default-locale")
    else:
        defaultLocale = "no default-locale"

    if defaultLocale in uniqueStrings:
        uniqueStrings[defaultLocale] += 1
    else:
        uniqueStrings[defaultLocale] = 1

sortedStrings = sorted(uniqueStrings, key=uniqueStrings.get, reverse=True)

print("Styles tested: " + "%d" % (stylesTested))
print("default-locale values:")
for string in sortedStrings:
    print('"' + string + '"' + ": %d" % (uniqueStrings[string]))
