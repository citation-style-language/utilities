# -*- coding: utf-8 -*-
# Python script to define verb-short terms that will change in locale files
# Author: Rintze M. Zelle
# Version: 2012-10-21
# * Requires lxml library (http://lxml.de/)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
styles = []

for stylepath in glob.glob( os.path.join(path, 'a*.csl') ):
    styles.append(os.path.join(stylepath))

def findNamesInUse(styleElement):
    termsToDefine = []

    if (styleElement.find('.//{http://purl.org/net/xbiblio/csl}label[@form="verb-short"]') is not None):    
        changingNames = ["director", "editor", "editorial-director", "illustrator", "translator"]
        for csNames in styleElement.findall(".//{http://purl.org/net/xbiblio/csl}names"):
            for changingName in changingNames:
                if ((changingName in csNames.get("variable")) and (changingName not in termsToDefine)):
                    termsToDefine.append(changingName)
    return(termsToDefine)

for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    termsToDefine = []

    if "default-locale" in styleElement.attrib:
        defaultLocale = styleElement.get("default-locale")
        if (re.match("^en((-US)|(-GB))?$",defaultLocale)):
            termsToDefine = findNamesInUse(styleElement)
            #print(termsToDefine)
    else:
        termsToDefine = findNamesInUse(styleElement)

    if (len(termsToDefine) != 0):
        print(os.path.basename(style))
        localeElements = len(styleElement.findall('.//{http://purl.org/net/xbiblio/csl}locale'))
        if (localeElements == 0):
            print("create new locale element")
        elif (localeElements == 1):
            print("use existing locale element")
        else:
            print("Eek! More than one locale element!")

#print(termsToDefine)

# todo:
# locale elements: it's possible to have en-GB, en-US, en and no xml:lang
# just pick one if it exists (shout out if there are more than one locale elements), otherwise create one with the same value as default-locale
# add verb-short terms in termsToDefine if missing

##
##    csInfo = styleElement.find(".//{http://purl.org/net/xbiblio/csl}info")
##
##    counter = []
##    for infoNodeIndex, infoNode in enumerate(csInfo):
##        # check if node is an element
##        if isinstance(infoNode.tag, basestring):
##            # get rid of namespace
##            infoElement = infoNode.tag.replace("{http://purl.org/net/xbiblio/csl}","")
##            if(infoElement == "link"):
##                infoElement += "[@" + infoNode.get("rel") + "]"
##            if((infoElement == "category") & (infoNode.get("citation-format") is not None)):
##                infoElement += "[@citation-format]"
##            if((infoElement == "category") & (infoNode.get("field") is not None)):
##                infoElement += "[@field]"
##            try:
##                counter.append(desiredOrder.index(infoElement))
##            except:
##                print("Unknown element: " + infoElement)
##        # check if node is a comment
##        elif (etree.tostring(infoNode, encoding='UTF-8', xml_declaration=False) == ("<!--" + infoNode.text.encode("utf-8") + "-->")):
##            # keep comments that precede any element at the top
##            if(sum(counter) == 0):
##                counter.append(desiredOrder.index("preceding-comment"))
##            # keep a comment at the end at the end
##            elif(len(counter) == (len(csInfo) - 1)):
##                counter.append(desiredOrder.index("end-comment"))
##            # keep other comments with preceding element
##            else:
##                counter.append(counter[-1])
##
##            # Possible improvements:
##            # * exceptions for recognizable comments (issn, category)
##        else:
##            print(infoNode)
##
##    try:
##        parsedStyle = etree.tostring(parsedStyle, pretty_print=True, xml_declaration=True, encoding="utf-8")
##        parsedStyle = parsedStyle.replace("'", '"', 4)
##        parsedStyle = parsedStyle.replace(" ", "&#160;")#no-break space
##        parsedStyle = parsedStyle.replace("ᵉ", "&#7497;")
##        parsedStyle = parsedStyle.replace("‑", "&#8209;")#non-breaking hyphen
##        parsedStyle = parsedStyle.replace("–", "&#8211;")#en dash
##        parsedStyle = parsedStyle.replace("—", "&#8212;")#em dash
##        f = open(style, 'w')
##        f.write ( parsedStyle )
##        f.close()
##    except:
##        pass
