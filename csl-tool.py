#!/usr/bin/python

"""
Copyright (c) 2011, Carles Pina Estany. <carles.pina@mendeley.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# ISC License
"""

"""
This small utility was done in a hackday (so done a bit in a rush). Needs some improving:
 * Use Python OptionParser instead of just sys.argv
 * Add some documentation
 * Write some unit test
"""

from lxml import etree
import datetime
import glob
import os

import sys

class Style():
    def __init__(self,filePath = None):
        if filePath != None:
            self.doc = etree.parse(filePath)
	    self.root = self.doc.getroot()
	    self.filePath = filePath

    def _getInfoFieldText(self,infoField):
        infoFieldElement = self._getInfoElement(infoField)
	
	fieldElement = ""
        if infoFieldElement != None:
	    fieldElement = infoFieldElement.text

        if fieldElement == None:
	    fieldElement = ""

        return fieldElement

    def _getInfoElement(self,infoField):
        infoFieldElement = self.root.find("{http://purl.org/net/xbiblio/csl}info/{http://purl.org/net/xbiblio/csl}%s" % (infoField))

	return infoFieldElement

    def _getInfoRootElement(self):
        infoFieldRoot = self.root.find("{http://purl.org/net/xbiblio/csl}info")

	return infoFieldRoot

    def name(self):
        """ Returns the name of the style. """
        return self._getInfoFieldText("title")

    def id(self):
        """ Returns the ID of the style. """
        return self._getInfoFieldText("id")

    def updated(self):
        """ Returns the updated time of the style. """
        return self._getInfoFieldText("updated")

    def summary(self):
        """ Returns the summary of the style. """
        return self._getInfoFieldText("summary")

    def author(self):
        """ Returns the author of the stlye. """
        author = self._getInfoElement("author")

	if author == None:
	    return ""

	authorName = author.find("{http://purl.org/net/xbiblio/csl}name")

	author = ""
	if authorName != None:
	    author = authorName.text

        if author == None:
	    author = ""

	return author

    def setInfoUpdated(self,date):
        """ Changes/adds the node info/updated to @param date. """
        updated = self._getInfoElement("updated")
	if updated != None:
	    updated.text = date
	else:
	    info = self._getInfoRootElement()
	    newElement = etree.SubElement(info,"updated")
	    newElement.text = date

    def setInfoUpdatedToNow(self):
        """ Changes/adds the element text info/updated to the current time. """
        now = datetime.datetime.now()
	now = now.replace(microsecond = 0)
        self.setInfoUpdated(now.isoformat())

    def saveStlye(self,filePath):
        """ Saves the changed style into @param filePath. """
        outFile = open(filePath,"w")
        self.doc.write(outFile)

    def setupValidate(self):
        """ Expensive operation - will clone a git repo- that downloads
	the validation schema and transofrms to .rng from .rnc.
	"""
	print "Downloading schemas"
        os.system("rm -rf schema/")
	os.system("git clone https://github.com/citation-style-language/schema.git")

	os.system("trang schema/csl.rnc schema/csl.rng")

    def validate(self):
        """ Returns True if the style validates against the schema.
	If return False, in self.error_log, will be the error_log of the
	RNGValidator.
	"""
        rng = etree.ElementTree(file="schema/csl.rng")
	validator = etree.RelaxNG(rng)

        self.error_log = ""
	validated = validator.validate(self.doc)
	if validated == False:
	    self.error_log = validator.error_log
	
	return validated

    def printStyleInformation(self):
        """ Prints different information of the style. """
        print "Style Information for: %s" % (self.filePath)
        print "Name:",self.name()
        print "Updated:",self.updated()
        print "Summary:",self.summary()
        print "Author:",self.author()

if __name__ == "__main__":
    if len(sys.argv) != 3 and len(sys.argv) != 4:
        print """Use with options:
	--validate fileName
	--updateUpdated fileName.csl newFileName.csl
	--informatoin fileName.csl"""
	print
	print "For more functionality, use it as a Python module"
	sys.exit(1)

    else:
        fileName = sys.argv[2]
        s = Style(fileName)
	if sys.argv[1] == "--validate":
	    if s.validate():
                print "OK"
		sys.exit(0)
	    else:
		print "No valid"
		print s.error_log
		sys.exit(1)

	elif sys.argv[1] == "--updateUpdated":
	    s.setInfoUpdatedToNow()
	    s.saveStlye(sys.argv[3])

	elif sys.argv[1] == "--information":
	    print "Author:",s.author()
	    print "Name:",s.name()
	    print "Summary:",s.summary()
	    print "Updated:",s.updated()
	    
    # At the moment this is doing some tests.
    # It can be expanded to hook to sys.argv to validate/update the updated
    # time of a given file
    #s = Style("testStyle.csl")
    #s.printStyleInformation()
    #s.setInfoUpdatedToNow()
    #s.saveStlye("testStyle.csl")
    #print "Validated:",s.validate(),s.error_log
