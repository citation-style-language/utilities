# Python script for additional style validation
# Author: Rintze M. Zelle
# Version: 2011-12-17
# * Requires lxml library (http://lxml.de/)
#
# Shows
# - verbatim text values used

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'

verbatims = {}
for independentStyle in glob.glob( os.path.join(path, '*.csl') ):
    #print(os.path.basename(independentStyle))
    style = etree.parse(independentStyle)
    styleElement = style.getroot()
    
    verbatimsStyle = []
    try:
        verbatimsStyle = styleElement.findall(".//{http://purl.org/net/xbiblio/csl}text[@value]")
        for verbatim in verbatimsStyle:
            verbatim = verbatim.attrib.get("value")
            if verbatim in verbatims:
                verbatims[verbatim] += 1
            else:
                verbatims[verbatim] = 1
    except:
        pass

verbatimsSorted = sorted(verbatims, key=verbatims.get, reverse=True)

print("Verbatim values used with cs:text and usage:")
for verbatimSorted in verbatimsSorted:
    print('"' + verbatimSorted + '"' + ": %d" % (verbatims[verbatimSorted]))
