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

for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    termsToDefine = []
    termValues = {"director":"dir.","editor":"ed.",
                  "editorial-director":"ed.","illustrator":"illus.",
                  "translator":"trans."}

    # Limit ourselves to styles with either an English default-locale ("en", "en-GB", or "en-US"),
    # or without a default-locale.
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
            #Add new cs:locale element
            newLocaleElement = etree.Element("{http://purl.org/net/xbiblio/csl}locale")
            newTermsElement = etree.Element("{http://purl.org/net/xbiblio/csl}terms")
            newLocaleElement.append(newTermsElement)

            for term in termsToDefine:
                newTermElement = etree.Element("{http://purl.org/net/xbiblio/csl}term", name=term, form="verb-short")
                newTermElement.text = termValues[term]
                newLocaleElement.find("{http://purl.org/net/xbiblio/csl}terms").append(newTermElement)
            
            infoIndex = styleElement.index(styleElement.find('.//{http://purl.org/net/xbiblio/csl}info'))
            styleElement.insert(infoIndex+1,newLocaleElement)
        elif (localeElements == 1):
            #Add terms to existing locale element unless they're already defined
            LocaleElement = styleElement.find('.//{http://purl.org/net/xbiblio/csl}locale')

            #Check if there is already a cs:terms element
            if (len(LocaleElement.findall('.//{http://purl.org/net/xbiblio/csl}terms')) == 0):
                newTermsElement = etree.Element("{http://purl.org/net/xbiblio/csl}terms")
                LocaleElement.append(newTermsElement)
            
            for term in termsToDefine:
                #print(LocaleElement)
                if (len(LocaleElement.findall('.//{http://purl.org/net/xbiblio/csl}term[@form="verb-short"][@name="' + term + '"]')) == 0):
                    termElement = etree.Element("{http://purl.org/net/xbiblio/csl}term", name=term, form="verb-short")
                    termElement.text = termValues[term]
                    LocaleElement.find("{http://purl.org/net/xbiblio/csl}terms").append(termElement)
            
            #print(etree.tostring(styleElement, pretty_print=True))
            #print("use existing locale element")
        else:
            print("Ignored '" + os.path.basename(style) + ": more than one locale element!")

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
