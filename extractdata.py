#!/usr/bin/python -u

import sys,os,re
from datetime import datetime
from stat import *
import tempfile
from cStringIO import StringIO
from cPickle import Pickler, Unpickler
import subprocess as sub 
import string

reload(sys)
sys.setdefaultencoding("utf-8") # Needs Python Unicode build !


class NoDirectory(Exception):
    pass

class NoFiles(Exception):
    pass

class CslTests:
    def __init__(self,opt):
        self.opt = opt
        RE_FILENAME = '^[a-z]+_[a-zA-Z0-9]+\.txt$'
        if not os.path.exists(opt.input):
            raise NoDirectory(opt.input)
        if not os.path.exists(opt.output):
            raise NoDirectory(opt.output)
        filenames = os.listdir(opt.input)
        for pos in range(len(filenames) - 1, -1, -1):
            if not re.match(RE_FILENAME, filenames[pos]):
                filenames.pop(pos)
        if not len(filenames):
            raise NoFiles(opt.input)
        self.inpaths = [os.path.join(opt.input, x) for x in filenames]
        self.outpaths = [os.path.join(opt.output, "%s.json" % x[:-4]) for x in filenames]

    def process(self):
        if self.opt.delete:
            for filename in os.listdir(self.opt.output):
                if self.opt.verbose:
                    print "-- Deleting %s" % os.path.join(self.opt.output, filename)
                os.unlink(os.path.join(self.opt.output, filename))
        for pos in range(0, len(self.inpaths), 1):
            inpath = self.inpaths[pos]
            outpath = self.outpaths[pos]
            test = CslTest(self.opt, inpath, outpath)
            test.parse()
            test.dump()

class CslTest:
    def __init__(self, opt, inpath, outpath):
        self.opt = opt
        self.outpath = outpath
        self.RE_ELEMENT = '(?sm)^(.*>>=.*%s[^\n]+)(.*)(\n<<=.*%s.*)'
        self.data = {}
        self.raw = open(inpath).read()

    def parse(self):
        self.extract("INPUT",required=True,is_json=True)

    def extract(self,tag,required=False,is_json=False,rstrip=False):
        m = re.match(self.RE_ELEMENT %(tag,tag),self.raw)
        data = False
        if m:
            if rstrip:
                data = m.group(2).rstrip()
            else:
                data = m.group(2).strip()
        elif required:
            raise ElementMissing(self.script,tag,self.testname)
        self.data["input"] = data

    def dump(self):
        if self.opt.verbose:
            print "++ Writing: %s" % self.outpath
        open(self.outpath, "w+").write(self.data["input"])

if __name__ == "__main__":

    from ConfigParser import ConfigParser
    from optparse import OptionParser

    os.environ['LANG'] = "en_US.UTF-8"

    usage = '\n%prog -i <input_dir_path> -o <output_dir_path>'

    description="Extract JSON input objects from human-readable CSL test fixtures"

    parser = OptionParser(usage=usage,description=description)
    parser.add_option("-i", "--input", dest="input",
                      help='Path to directory containing input files (required).')
    parser.add_option("-o", "--output", dest="output",
                      help='Path to directory for output files (required, must exist).')
    parser.add_option("-d", "--delete", dest="delete",
                      default=False,
                      action="store_true", 
                      help='Force deletion of preexisting output files.')
    parser.add_option("-v", "--verbose", dest="verbose",
                      default=False,
                      action="store_true", 
                      help='Chatter about actions during operation.')
    (opt, args) = parser.parse_args()

    if not opt.input or not opt.output:
        parser.print_help()
        print "\nError: both the -i and -o options are required."
        sys.exit()

    try:
        CslTests(opt)
    except NoDirectory as error:
        print "\nDirectory %s not found." % error[0]
        sys.exit()
    except NoFiles as error:
        print "\nNo test fixtures found in directory %s." % error[0]
        sys.exit()

    tests = CslTests(opt)
    tests.process()
