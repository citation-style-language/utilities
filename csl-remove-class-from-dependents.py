# -*- coding: utf-8 -*-
# Python script to remove class from cs:style in dependents
# Author: Rintze M. Zelle
# Version: 2013-03-29
# * Requires lxml library (http://lxml.de/)

import os, glob, re, inspect
from lxml import etree

# http://stackoverflow.com/questions/50499
folderPath =  os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))

parentFolderPath = os.path.dirname (folderPath)
path =  os.path.join(parentFolderPath, 'styles')

styles = []

for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    fixedStyle = False

    if "class" in styleElement.attrib:
       del styleElement.attrib["class"]
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
