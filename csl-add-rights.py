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
    style = etree.parse(independentStyle)
    styleElement = style.getroot()
    
    verbatimsStyle = []
    try:
        verbatimsStyle = styleElement.find(".//{http://purl.org/net/xbiblio/csl}rights")
        for verbatim in verbatimsStyle:
            verbatim = verbatim.text
            if verbatim in verbatims:
                verbatims[verbatim] += 1
            else:
                verbatims[verbatim] = 1
    except:
        info = styleElement.find(".//{http://purl.org/net/xbiblio/csl}info")
        rights = etree.SubElement(info, "rights")
        rights.text = "This work is licensed under a Creative Commons Attribution-Share Alike 3.0 License: http://creativecommons.org/licenses/by-sa/3.0/"
        style = etree.tostring(style, pretty_print=True, xml_declaration=True, encoding="utf-8")
        style = style.replace("'", '"', 4)
        f = open(independentStyle, 'w')
        f.write ( style )
        f.close()
