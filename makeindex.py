#! /usr/bin/env python
"""
This iterates through a directory of 
CSL files and creates an array of that (which
can be dumped to JSON), which it passes off 
to a template for HTML rendering.
"""

import json
import glob
from mako.template import Template
from lxml import etree

NS = {'cs': 'http://purl.org/net/xbiblio/csl'}

"""
this should probably use git, to get accurate info; e.g.:

$ git log --pretty=format:"%ad" --date=relative -1 apa.csl
7 weeks ago

should also take the repo dir as input
"""
index = []
styles = glob.glob('/home/bdarcus/Code/styles/*.csl')

for style in styles:
    xml = etree.ElementTree().parse(style)
    st = {}
    fields = []
    title = xml.xpath('cs:info/cs:title', namespaces=NS)[0].text
    updated = xml.xpath('cs:info/cs:updated', namespaces=NS)[0].text
    category = xml.xpath('cs:info/cs:category[@citation-format]/@citation-format', namespaces=NS)
    st['title'] = title 
    st['updated'] = updated
    if category:
        st['category'] = category[0]
    else:
        st['category'] = None

    index.append(st)


mytemplate = Template(filename='list.tmpl',
			input_encoding='utf-8',
                        output_encoding='utf-8')

print mytemplate.render(styles=index)
