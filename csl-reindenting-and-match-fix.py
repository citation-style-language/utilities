# -*- coding: utf-8 -*-
# Python script to find "type" conditionals that test for multiple item types
# with "match" set (explicitly or implicitly) to "all"
# Author: Rintze M. Zelle
# Version: 2013-02-25
# * Requires lxml library (http://lxml.de/)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))

# Determine which terms should be defined in a locale element
def findNamesInUse(styleElement):
    termsToDefine = []

    if (styleElement.find('.//{http://purl.org/net/xbiblio/csl}label[@form="verb-short"]') is not None):    
        changingNames = ["director", "editor", "editorial-director", "illustrator", "translator"]
        for csNames in styleElement.findall(".//{http://purl.org/net/xbiblio/csl}names"):
            for changingName in changingNames:
                if ((changingName in csNames.get("variable")) and (changingName not in termsToDefine)):
                    termsToDefine.append(changingName)
    return(termsToDefine)

# cs:if or cs:else-if
# with "type", with multiple values (contains a space)
# without "match", or with 'match="all"'
# for now, just print style names
for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    fixedStyle = False

    typeTests = styleElement.findall('.//{http://purl.org/net/xbiblio/csl}if[@type]')
    for typeTest in typeTests:
        itemTypesTested = typeTest.get("type")
        # if the value of "type" includes a space, it tests for multiple item types 
        if " " in itemTypesTested:
            # there is a problem if "match" is set to "all"
            if "match" in typeTest.attrib:
                if typeTest.get("match") == "all":
                    print("Warning: 'match' set to 'all' while testing for multiple item types with 'type'")
                    print(os.path.basename(style))
            # there is a problem if "match" is not set
            else:
                # if there is only a "type" attribute, add 'match="any"'
                if(len(typeTest.attrib) == 1):
                    typeTest.attrib["match"]="any"
                    fixedStyle = True

    typeTests = styleElement.findall('.//{http://purl.org/net/xbiblio/csl}else-if[@type]')
    for typeTest in typeTests:
        itemTypesTested = typeTest.get("type")
        # if the value of "type" includes a space, it tests for multiple item types 
        if " " in itemTypesTested:
            # there is a problem if "match" is set to "all"
            if "match" in typeTest.attrib:
                if typeTest.get("match") == "all":
                    print("Warning: 'match' set to 'all' while testing for multiple item types with 'type'")
                    print(os.path.basename(style))
            # there is a problem if "match" is not set
            else:
                # if there is only a "type" attribute, add 'match="any"'
                if(len(typeTest.attrib) == 1):
                    typeTest.attrib["match"]="any"
                    fixedStyle = True

    if (fixedStyle == False):
        continue

    try:
        parsedStyle = etree.tostring(parsedStyle, pretty_print=True, xml_declaration=True, encoding="utf-8")
        parsedStyle = parsedStyle.replace("'", '"', 4)
        parsedStyle = parsedStyle.replace(" ", "&#160;")#no-break space
        parsedStyle = parsedStyle.replace("ᵉ", "&#7497;")
        parsedStyle = parsedStyle.replace("‑", "&#8209;")#non-breaking hyphen
        parsedStyle = parsedStyle.replace("–", "&#8211;")#en dash
        parsedStyle = parsedStyle.replace("—", "&#8212;")#em dash
        f = open(style, 'w')
        f.write ( parsedStyle )
        f.close()
    except:
        pass
