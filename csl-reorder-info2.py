# -*- coding: utf-8 -*-
# Python script for to reorder cs:info section of styles
# Author: Rintze M. Zelle
# Version: 2012-09-27
# * Requires lxml library (http://lxml.de/)

import os, glob, re
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'
styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    styles.append(os.path.join(stylepath))
for stylepath in glob.glob( os.path.join(path, 'dependent', '*.csl') ):
    styles.append(os.path.join(stylepath))

# for comments in the middle, keep them with preceding element

##0 preceding-comment
##1 title
##2 title-short
##3 id
##4 link self
##5 link independent-parent
##6 link template
##7 link doc
##8 author
##9 contributor
##10 category citation-format
##11 category field
##12 issn
##13 eissn
##14 issnl
##15 summary
##16 published
##17 updated
##18 rights
##19 end-comment

desiredOrder = ["preceding-comment", "title", "title-short", "id", "link[@self]",
                "link[@independent-parent]", "link[@template]",
                "link[@documentation]", "author", "contributor",
                "category[@citation-format]", "category[@field]", "issn",
                "eissn", "issnl", "summary", "published", "updated", "rights",
                "end-comment"]

for style in styles:
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    csInfo = styleElement.find(".//{http://purl.org/net/xbiblio/csl}info")

    counter = []
    for infoNodeIndex, infoNode in enumerate(csInfo):
        # check if node is an element
        if isinstance(infoNode.tag, basestring):
            # get rid of namespace
            infoElement = infoNode.tag.replace("{http://purl.org/net/xbiblio/csl}","")
            if(infoElement == "link"):
                infoElement += "[@" + infoNode.get("rel") + "]"
            if((infoElement == "category") & (infoNode.get("citation-format") is not None)):
                infoElement += "[@citation-format]"
            if((infoElement == "category") & (infoNode.get("field") is not None)):
                infoElement += "[@field]"
            try:
                counter.append(desiredOrder.index(infoElement))
            except:
                print("Unknown element: " + infoElement)
        # check if node is a comment
        elif (str(infoNode) == ("<!--" + infoNode.text + "-->")):
            # keep comments that precede any element at the top
            if(sum(counter) == 0):
                counter.append(desiredOrder.index("preceding-comment"))
            # keep a comment at the end at the end
            elif(len(counter) == (len(csInfo) - 1)):
                counter.append(desiredOrder.index("end-comment"))
            # keep other comments with preceding element
            else:
                counter.append(counter[-1] + 0.5)

            # Possible improvements:
            # * exceptions for recognizable comments (issn, category)
        else:
            print(infoNode)

    # make sure if length counter is identical to length csInfo
    # http://scienceoss.com/sort-one-list-by-another-list/
    if(len(counter) == len(csInfo)):
        for index in range(len(counter)):
            # use float() to avoid integer division
            counter[index] += (index / (float(len(counter))))
        csInfoWithKeys = zip(counter, csInfo)
        csInfoWithKeys.sort()
        sortedCounter, sortedCsInfo = zip(*csInfoWithKeys)

        # overwrite list contents
        # http://stackoverflow.com/questions/5438362/overwrite-entire-object-in-place
        csInfo[:] = sortedCsInfo

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
