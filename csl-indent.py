# -*- coding: utf-8 -*-
# Python script for additional style validation
# Author: Rintze M. Zelle
# Version: 2011-12-17
# * Requires lxml library (http://lxml.de/)
#
# Add CC by-sa license

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'

for independentStyle in glob.glob( os.path.join(path, '*.csl') ):
    #print(os.path.basename(independentStyle))
    parser = etree.XMLParser(remove_blank_text=True)
    style = etree.parse(independentStyle, parser)
    styleElement = style.getroot()
    
    try:
        verbatimsStyle = styleElement.find(".//{http://purl.org/net/xbiblio/csl}rights").text
        style = etree.tostring(style, pretty_print=True, xml_declaration=True, encoding="utf-8")
        style = style.replace("'", '"', 4)
        style = style.replace(" ", "&#160;")
        f = open(independentStyle, 'w')
        f.write ( style )
        f.close()
    except:
        pass
