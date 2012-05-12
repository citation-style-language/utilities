# -*- coding: utf-8 -*-
# Python script for style (re)indentation
# Author: Rintze M. Zelle
# Version: 2012-05-12
# * Requires lxml library (http://lxml.de/)
#
# - Indents xml with 2 spaces per level
# - Escapes non-breaking spaces (&#160;)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()
    
    try:
        verbatimsStyle = styleElement.find(".//{http://purl.org/net/xbiblio/csl}rights").text
        parsedStyle = etree.tostring(parsedStyle, pretty_print=True, xml_declaration=True, encoding="utf-8")
        parsedStyle = parsedStyle.replace("'", '"', 4)
        parsedStyle = parsedStyle.replace(" ", "&#160;")
        f = open(style, 'w')
        f.write ( parsedStyle )
        f.close()
    except:
        pass
