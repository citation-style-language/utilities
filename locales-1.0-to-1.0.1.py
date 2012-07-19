# Python script to update locale files from CSL 1.0 to 1.0.1
# Author: Rintze M. Zelle
# Version: 2012-07-15
# * Requires lxml library (http://lxml.de/)
#
# Extremely hacky (I need a linux box!)

import os, glob, re
from lxml import etree

localesPath = 'C:\Documents and Settings\zelle\My Documents\CSL\locales\\'
localeXSLTPath = 'C:\Documents and Settings\zelle\My Documents\CSL\utilities\update-locales-1.0-to-1.0.1.xsl'

class FileResolver(etree.Resolver):
    def resolve(self, url, pubid, context):
        return self.resolve_filename(url, context)

locales = []

for localePath in glob.glob( os.path.join(localesPath, 'locales-*.xml') ):
    locales.append(os.path.basename(localePath))

if not os.path.exists(os.path.join(localesPath, '1.0.1')):
    os.makedirs(os.path.join(localesPath, '1.0.1'))

for locale in locales:
    with open(localeXSLTPath, 'r') as localeXSLT:
        localeXSLTContent = localeXSLT.read()
        
    localeXSLTContent = localeXSLTContent.replace('locales-nl-NL.xml', locale)
    ## print(localeXSLTContent)
    localizedXSLT = open(os.path.join('C:\Documents and Settings\zelle\My Documents\CSL\utilities\\', 'localizedXSLT.xsl'), 'w')
    localizedXSLT.write(localeXSLTContent)
    localizedXSLT.close()
## need to read modified copy!!!
    localeXSLT = etree.parse(os.path.join('C:\Documents and Settings\zelle\My Documents\CSL\utilities\\', 'localizedXSLT.xsl'))
    localeTransform = etree.XSLT(localeXSLT)

    parsedLocale = etree.parse('C:\Documents and Settings\zelle\My Documents\CSL\utilities\locales-en-US.xml')
    ## print(etree.tostring(parsedLocale, pretty_print=True, xml_declaration=True, encoding="utf-8"))
    localeElement = parsedLocale.getroot()

    updatedLocale = localeTransform(localeElement)
    updatedLocale = etree.tostring(updatedLocale, pretty_print=True, xml_declaration=True, encoding="utf-8")

    updatedLocale = updatedLocale.replace("    <!--", "\n    <!--")
    updatedLocale = updatedLocale.replace("'", '"', 4)

    updatedLocaleFile = open(os.path.join(localesPath, '1.0.1', locale), 'w')
    updatedLocaleFile.write ( updatedLocale )
    updatedLocaleFile.close()
