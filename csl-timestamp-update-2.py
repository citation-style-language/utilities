# -*- coding: utf-8 -*-
# Python script to update cs:updated timestamp to time of last commit
# (when timestamps are on different days)
# Author: Rintze M. Zelle
# Version: 2012-10-29
# * Requires lxml library (http://lxml.de/)

## https://groups.google.com/forum/?fromgroups=#!topic/git-python/IWE7EkVX9SQ

import os, glob, re, time, datetime, git
from lxml import etree

path = 'C:\Documents and Settings\zelle\My Documents\CSL\styles\\'

repo = git.Repo(path)
assert repo.bare == False

##limit = 0
commitTime = {}

for blob in repo.tree().blobs:
    last_commit = [c for c in repo.iter_commits(rev=None, paths=blob.path)][0]
    commitTime[os.path.join(path, blob.path)] = last_commit.authored_date
##    limit += 1
##    if limit == 10:
##        break

styles = []

for stylepath in glob.glob( os.path.join(path, '*.csl') ):
    if stylepath in commitTime:
        styles.append(os.path.join(stylepath))

for style in styles:
    modTime = datetime.datetime.fromtimestamp(commitTime[style]//1)
    modDate = datetime.datetime.date(modTime)
    
    parser = etree.XMLParser(remove_blank_text=True)
    parsedStyle = etree.parse(style, parser)
    styleElement = parsedStyle.getroot()

    updatedTimeStamp = styleElement.find(".//{http://purl.org/net/xbiblio/csl}updated")
    updatedDate = updatedTimeStamp.text[0:10]
    updatedDate = datetime.datetime.strptime(updatedDate, "%Y-%m-%d")
    updatedDate = updatedDate.date()

    if (updatedDate != modDate):
        #print(updatedTimeStamp)
        #print(str(datetime.datetime.isoformat(modTime))+"+00:00")
        updatedTimeStamp.text = str(datetime.datetime.isoformat(modTime))+"+00:00"
        #print(updatedTimeStamp)
        #print(styleElement.find(".//{http://purl.org/net/xbiblio/csl}updated").text)

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
