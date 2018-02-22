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

        # Pull in our version
        self.getVersionInfo()

        # Log our ref
        self.ref = self.getGitRef()

        # And populate config
        self.config = ConfigParser.ConfigParser()
        self.config.optionxform=str
        self.config.read([self.conf, self.conf_l])

        # And from this, we get our runtime config
        self.runconf_file = os.path.join(self.config.get('common', 'root'),
                                        self.config.get('common', 'instance'), 'runtime.ini')

        self.runconf = ConfigParser.ConfigParser()
        self.runconf.optionxform=str
        self.runconf.read(self.runconf_file)

        # Lets create required dirs
        try:
            os.makedirs(os.path.dirname(self.runconf_file))
        except: pass

        atexit.register(self.exit)

    def saveRunConfig(self):
        with open(self.runconf_file, 'w') as fh:
            self.runconf.write(fh)

    def setRunConfig(self, section, key, value):

        if not self.runconf.has_section(section):
            self.runconf.add_section(section)

        self.runconf.set(section, key, value)
        self.saveRunConfig()

    def saveVersionInfo(self):
        with open(os.path.join(self.root, "versioninfo"), 'w') as fh:
            fh.write(json.dumps(self.releasemap, sort_keys=True, indent=4, separators=(',', ': ')))

    def getGitRef(self):
        return Repo(self.root).commit().hexsha

    # versions are master: <shortref>
    # releases are branch names + (per-map/release counter)
    def getVersionInfo(self):

        self.logger.debug("called")

        try:
            with open(os.path.join(self.root, "versioninfo")) as fh:
                self.releasemap = json.load(fh)
        except Exception, e:
            self.releasemap = dict()

        gitRepo = Repo(self.root)
        if gitRepo.active_branch.name == 'master':
            self.base_version = "master.%s" % gitRepo.commit().hexsha[0:7]
            self.reuse_version = True
        else:
            self.base_version = gitRepo.active_branch.name
            self.reuse_version = False


    def getNextVersion(self, map = None):

        self.logger.debug("called")

        if self.reuse_version:
            return self.base_version

        vk = self.base_version
        if map is not None:
            vk += "-%s" % map

        if vk in self.releasemap:
            release = self.releasemap[vk] + 1
        else:
            release = 0

        self.releasemap[vk] = release
        return "%s.%s" % (self.base_version, release)

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
