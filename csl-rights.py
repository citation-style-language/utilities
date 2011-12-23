# Python script for additional style validation
# Author: Rintze M. Zelle
# Version: 2011-12-17
# * Requires lxml library (http://lxml.de/)
#
# Add CC by-sa license

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
        verbatimsStyle = styleElement.findall(".//{http://purl.org/net/xbiblio/csl}rights")
        for verbatim in verbatimsStyle:
            verbatim = verbatim.text
            if verbatim in verbatims:
                verbatims[verbatim] += 1
            else:
                verbatims[verbatim] = 1
    except:
        pass

verbatimsSorted = sorted(verbatims, key=verbatims.get, reverse=True)

print("Rights:")
for verbatimSorted in verbatimsSorted:
    print('"' + verbatimSorted + '"' + ": %d" % (verbatims[verbatimSorted]))
