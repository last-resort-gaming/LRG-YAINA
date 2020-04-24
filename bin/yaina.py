#!python -W ignore
import atexit
import os
import argparse
import tempfile
import shutil
import ConfigParser
import logging
import json
from utils import *
from git import Repo
from yaina.commands import *

class yaina(object):

    def __init__ (self, args):

        self.args   = args;
        self.root   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.conf   = os.path.join(self.root, 'conf', 'yaina.ini')
        self.conf_l = os.path.join(self.root, 'conf', 'yaina_local.ini')
        self.tmpdir = tempfile.mkdtemp(prefix="yaina_")
        self.logger = logging.getLogger("yaina")

        if args.debug:
            self.logger.setLevel(logging.DEBUG)
        else:
            self.logger.setLevel(logging.INFO)

        # And populate config
        self.config = ConfigParser.ConfigParser()
        self.config.optionxform=str
        self.config.read([self.conf, self.conf_l])

        atexit.register(self.exit)

    def exit(self):
        if self.args.keep:
            print "Tempdir: %s" % self.tmpdir
        else:
            shutil.rmtree(self.tmpdir)

if __name__ == "__main__":

    logging.basicConfig(format="%(asctime)s | %(levelname)s | %(name)s.%(funcName)s | %(msg)s")

    p = argparse.ArgumentParser(description='Manage YAINA Lifecycle', add_help=False)

    s = p.add_subparsers(title="Commands", metavar="")
    for cmd in inheritors(Command):
        cmd.setup(s)

    og = p.add_argument_group('Optional Arguments')
    og.add_argument("-d", "--debug", action="store_true", help="debug logging")
    og.add_argument("-k", "--keep", action="store_true", help="keep tempdir")
    og.add_argument("-h", "--help", action="help", help="show this help message and exit")

    args = p.parse_args()

    yaina = yaina(args)

    if "cmd" in args:
        args.cmd().run(yaina)
