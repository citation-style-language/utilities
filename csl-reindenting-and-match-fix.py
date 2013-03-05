# -*- coding: utf-8 -*-
# Python script to add 'match="any"' to ambiguous conditionals (citeproc-js
# default was incorrectly set to "any", should be "all")
# Author: Rintze M. Zelle
# Version: 2013-03-04
# * Requires lxml library (http://lxml.de/)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))

# cs:if or cs:else-if
# * conditional with 2 or more test values (attribute value contains a space)
# * two or more conditionals
# * no "match"
for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    fixedStyle = False

    ifElements = styleElement.findall('.//{http://purl.org/net/xbiblio/csl}if')
    for element in ifElements:
        elementAttributes = element.attrib
        
        if "match" in elementAttributes:
            continue
        
        if(len(elementAttributes) > 1):
            element.attrib["match"]="any"
            fixedStyle = True
            continue
        
        for attribute in elementAttributes:
          if " " in elementAttributes[attribute]:
            element.attrib["match"]="any"
            fixedStyle = True
            continue

    elseifElements = styleElement.findall('.//{http://purl.org/net/xbiblio/csl}else-if')
    for element in elseifElements:
        elementAttributes = element.attrib
        
        if "match" in elementAttributes:
            continue
        
        if(len(elementAttributes) > 1):
            element.attrib["match"]="any"
            fixedStyle = True
            continue
        
        for attribute in elementAttributes:
          if " " in elementAttributes[attribute]:
            element.attrib["match"]="any"
            fixedStyle = True
            continue

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
