import os, glob, re
from lxml import etree

def parseStyle(independentStyle):
    style = etree.parse (independentStyle)
    styleElement = style.getroot()
    metadata = {}
    try:
        metadata["id"] = styleElement.find(".//{http://purl.org/net/xbiblio/csl}id").text
        metadata["selfLink"] = styleElement.find(".//{http://purl.org/net/xbiblio/csl}link[@rel='self']").attrib.get("href")
        metadata["template"] = styleElement.find(".//{http://purl.org/net/xbiblio/csl}link[@rel='template']").attrib.get("href")
    except:
        pass
    return(metadata)

path = 'C:\Users\Rintze Zelle\Documents\git\styles\\'
metadataList = []
metadata = {}
for independentStyle in glob.glob( os.path.join(path, '*.csl') ):
    fileName = os.path.basename(independentStyle)

    if not(re.match("[a-z0-9](-?[a-z0-9]+)*(.csl)", fileName)):
        print("Non-conforming filename: " + fileName)
    
    metadata = parseStyle(independentStyle)
    metadata["fileName"] = fileName

    try:
        if not(("http://www.zotero.org/styles/"+fileName) == (metadata["selfLink"]+".csl")):
            print("ID - cs:link[@rel=self] mismatch: " + fileName)
    except:
        print("Missing cs:link[@rel=self] value: " + fileName)
    try:
        if not(("http://www.zotero.org/styles/"+fileName) == (metadata["id"]+".csl")):
            print("ID - filename mismatch: " + fileName)
    except:
        print("Missing cs:id content: " + fileName)
    
    metadataList.append(metadata)

#for set in metadataList:
#    print(set)
#    print(set["fileName"])

#print(idList)

# Use dict instead? Can use filename as key
# What do I really want? Easy way to compare id, self-link and filename, and compare values to other sets

# Start with independent styles
# Store filename, ID, self and template links
# Report error for missing ID and self link
# Check whether filename conforms to requirements ( ^[a-z0-9][
# Split ID and self link in "http://www.zotero.org/styles/" and filename part
