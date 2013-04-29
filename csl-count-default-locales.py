# Python script to count default-locale values
# Author: Rintze M. Zelle
# Version: 2013-04-07
# * Requires lxml library (http://lxml.de/)
#
# Prints the default-locale values

import os, glob, re, inspect
from lxml import etree

# http://stackoverflow.com/questions/50499
folderPath =  os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))

parentFolderPath = os.path.dirname (folderPath)
path =  os.path.join(parentFolderPath, 'styles')

styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

uniqueStrings = {}
stylesTested = 0

for style in styles:
    parsedStyle = etree.parse(style)
    styleElement = parsedStyle.getroot()

    stylesTested += 1

    if "default-locale" in styleElement.attrib:
        defaultLocale = styleElement.get("default-locale")
    else:
        defaultLocale = "no default-locale"
        print("No default-locale:" + style)
        
    if defaultLocale in uniqueStrings:
        uniqueStrings[defaultLocale] += 1
    else:
        uniqueStrings[defaultLocale] = 1

sortedStrings = sorted(uniqueStrings, key=uniqueStrings.get, reverse=True)

print("Styles tested: " + "%d" % (stylesTested))
print("default-locale values:")
for string in sortedStrings:
    print('"' + string + '"' + ": %d" % (uniqueStrings[string]))
