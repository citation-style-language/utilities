# Python script to add timestamp to style with empty updated field
# Author: Rintze M. Zelle
# Version: 2011-12-17
# * Requires lxml library (http://lxml.de/)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\dependent\\'

verbatims = {}
for independentStyle in glob.glob( os.path.join(path, '*.csl') ):
    style = etree.parse(independentStyle)
    styleElement = style.getroot()

    updatedContent = None
    updated = styleElement.find(".//{http://purl.org/net/xbiblio/csl}updated")
    updatedContent = updated.text
    
    if updatedContent == None:
        updated.text = "2012-01-01T00:00:00+00:00"
        style = etree.tostring(style, pretty_print=True, xml_declaration=True, encoding="utf-8")
        style = style.replace("'", '"', 4)
        f = open(independentStyle, 'w')
        f.write ( style )
        f.close()
