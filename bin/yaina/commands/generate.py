
import sys
import os
import logging
import shutil
import subprocess
import textwrap
import re
from utils import Command
from yaina.CfgFunctions import CfgFunctions

class List(Command):
    @classmethod
    def setup(cls, s):
        p = s.add_parser("generate", description="", help="Generate Game Outputs", add_help=False)
        p.set_defaults(cmd=cls)

        ag = p.add_argument_group('Action Group')
        g = ag.add_mutually_exclusive_group(required=True)
        g.add_argument("-s", "--server", action="store_true", help="Build Server Addon")
        g.add_argument("-c", "--client", action="store_true", help="Build Client PBO")
        g.add_argument("-a", "--all", action="store_true", help="Build both Client PBO and Server Addon (default)")

        og = p.add_argument_group('Optional Arguments')
        og.add_argument("-m", "--map", help="Package which Map (default: Altis)", default="Altis")
        og.add_argument("-b", "--base", help="Merge Base Path, Server Side Includes")
        og.add_argument("-h", "--help", action="help", help="show this help message and exit")
        og.add_argument("-r", "--release", action="store_true", help="releae, tag it in git")

    def run(self, yaina):

        self.logger = logging.getLogger(__name__)
        self.yaina  = yaina
        self.source = os.path.join(yaina.root, "client.%s" % yaina.args.map)

        if not os.path.isdir(self.source):
            print "Error: could not find client.%s in yaina rootdir" % yaina.args.map
            sys.exit(1)

        # The client is linked to server
        if yaina.args.client or yaina.args.all:
            self.build_client()

        if yaina.args.server or yaina.args.all:
            self.build_server()

    def get_path(self, base, fnc):
        if 'file' in fnc.params:
            return os.path.join(self.build_dir, fnc.params['file'].value[1:-1])
        return os.path.join(base, "fn_%s.sqf" % fnc.name)


    def build_server(self):
        # We do the server a little differently, by initially only copying in what's from
        # client that we need

        self.build_dir = os.path.join(self.yaina.tmpdir, "server")

        # Then we walk through and remove functions that are only intended to be in the server
        src_func_file =  os.path.join(self.source,    "Functions", "YAINA", "CfgFunctions.hpp")
        dst_func_file =  os.path.join(self.build_dir, "Functions", "YAINA", "CfgFunctions.hpp")

        server_cfg = CfgFunctions.getTags(src_func_file, True, delete=False)

        for tag in server_cfg.data:

            src_path  = os.path.join(self.source, "functions")
            base_path = os.path.join(self.build_dir, "functions")

            for cat in server_cfg[tag].cats.data:

                base_path = os.path.join(self.build_dir, 'Functions', cat)

                if ('file' in server_cfg[tag].cats.data[cat].params):

                    src_path  = os.path.join(self.source,    server_cfg[tag].cats.data[cat].params['file'].value[1:-1])
                    base_path = os.path.join(self.build_dir, server_cfg[tag].cats.data[cat].params['file'].value[1:-1])

                # Now we copy each file from from src_path to base_path
                for cmd in server_cfg[tag].cats.data[cat].cmds.data:
                    s = self.get_path(src_path, server_cfg[tag].cats.data[cat].cmds.data[cmd])
                    d = self.get_path(base_path, server_cfg[tag].cats.data[cat].cmds.data[cmd])

                    try:
                        os.makedirs(os.path.dirname(d))
                    except: pass

                    self.logger.debug("Importing %s" % s)

                    shutil.copyfile(s,d);


        # Bring in base requried extension types: .hpp
        required_extensions = [
            ".h"
        ]

        # Now we copy across teh relevent header files for each of the units included
        for root, dirs, files in os.walk(self.source):
            for file in files:
                if os.path.splitext(file)[1] in required_extensions:
                    relpath = os.path.relpath(root, self.source)
                    dest_dir = os.path.join(self.build_dir, relpath)
                    if (os.path.exists(dest_dir)):
                        self.logger.debug("Bringing in associated file: %s" % os.path.join(relpath, file))
                        shutil.copyfile(os.path.join(root,file), os.path.join(dest_dir, file))

        #####################################################################
        # MERGE BASE
        #####################################################################

        merge_base = self.yaina.args.base
        if merge_base is None:
            try:
                merge_base = os.path.join(self.yaina.root, self.yaina.config.get('server', 'merge_base'))
            except: pass


        if merge_base is not None:

            merge_dir = os.path.abspath(merge_base)
            self.logger.debug("Starting to merge: %s" % merge_dir)
            merge_cfg = CfgFunctions.getTags(os.path.join(merge_dir, 'CfgFunctions.hpp'), False, delete=False)

            for tag in merge_cfg.data:
                if tag not in server_cfg:
                    server_cfg.data[tag] = merge_cfg.data[tag]

                for cat in merge_cfg[tag].cats.data:

                    base_path = os.path.join(merge_dir, 'Functions', cat)

                    if cat not in server_cfg[tag].cats:
                        server_cfg[tag].cats[cat] = merge_cfg[tag].cats[cat]

                    if ('file' in server_cfg[tag].cats.data[cat].params):
                        src_path  = os.path.join(merge_dir,      merge_cfg[tag].cats.data[cat].params['file'].value[1:-1])
                        base_path = os.path.join(self.build_dir, server_cfg[tag].cats.data[cat].params['file'].value[1:-1])

                    for cmd in merge_cfg[tag].cats.data[cat].cmds.data:
                        if cmd not in server_cfg[tag].cats.data[cat].cmds:
                            server_cfg[tag].cats.data[cat].cmds[cmd] = merge_cfg[tag].cats.data[cat].cmds[cmd]

                        s = self.get_path(src_path, server_cfg[tag].cats.data[cat].cmds.data[cmd])
                        d = self.get_path(base_path, server_cfg[tag].cats.data[cat].cmds.data[cmd])

                        try:
                            os.makedirs(os.path.dirname(d))
                        except:
                            try:
                                os.unlink(d)
                            except: pass

                        self.logger.debug("Importing %s -> %s" % (s,d))
                        shutil.copyfile(s,d)

        # We need to rewrite the destination paths in the functions for the addon to find them
        for tag in server_cfg.data:
            for cat in server_cfg[tag].cats.data:
                if ('file' in server_cfg[tag].cats.data[cat].params):
                    # Now we're here, we have to update our file to be absolute
                    server_cfg[tag].cats.data[cat].params['file'].set("\"\yaina\%s\"" % server_cfg[tag].cats.data[cat].params['file'].value[1:-1])


        pbo_ver  = self.yaina.getNextVersion()
        pbo_name = "yaina"

        # re-write out the combined CfgFunctions.hpp
        with open(dst_func_file, 'w') as fh:
            fh.write(CfgFunctions.compose(server_cfg))

        # Now write out our config.cpp
        try:
            os.makedirs(os.path.join(self.build_dir, 'addon'))
        except: pass

        with open(os.path.join(self.build_dir, 'addon', "fn_preInit.sqf"), 'w') as fh:
            fh.write(textwrap.dedent('''
            if(isServer) then {
                SERVER_COMMAND_PASSWORD = "%s";
            };
            ''' % self.yaina.config.get('server', 'serverCommandPassword')))

        # Now write out our config.cpp
        with open(os.path.join(self.build_dir, "config.cpp"), 'w') as fh:
            fh.write(textwrap.dedent('''
                        class CfgPatches {
                            class yaina {
                                name = "YAINA Server Side Includes";
                                author = "YAINA";
                                url = "http://yaina.eu";

                                units[] = {};
                                weapons[] = {};
                                requiredVersion = 0.1;
                                requiredAddons[] = {};
                            };
                        };

                        class CfgFunctions {
                            #include "Functions\YAINA\CfgFunctions.hpp"

                            class YAINA_ADDON {
	                            class General {
		                            file = "\yaina\\addon";
		                            class preInit { preInit = 1; };
                                };
                            };
                        };
                        '''))

        # Now we bundle the output
        server_dir = os.path.dirname(self.yaina.config.get('apps', 'server'))
        addon_path = os.path.join("LocalMods", "yaina-%s" % pbo_ver, "@yaina")
        out_dir = os.path.join(server_dir, addon_path, "addons")

        # Just need to set the
        self.yaina.setRunConfig('next', 'serverMod', '%s;%s' %
            (self.yaina.config.get('server', 'serverMod'), addon_path))

        # If we have hc mods, append, else give it to us
        try:
            hc_mod = '%s;%s' % (self.yaina.config.get('hc', 'mod'), addon_path)
        except:
            hc_mod = addon_path

        self.yaina.setRunConfig('next', 'hcMod', hc_mod)
        self.yaina.setRunConfig('next', 'version', pbo_ver)

        try:
            os.makedirs(out_dir)
        except: pass

        cmd = [
            self.yaina.config.get('apps', 'makepbo'),
            "-@=yaina",
            "-P",
            "-X", "thumbs.db,*.cpp,*.bak,*.png,*.dep,*.log",
            self.build_dir,
            os.path.join(out_dir, "yaina")
        ]

        self.logger.info("Running: %s" % " ".join(cmd))
        subprocess.call(cmd)

    def build_client(self):

        self.logger.debug("Building Client from Source: %s" % self.source)

        # We start with a complete copy of the client tree
        self.build_dir = os.path.join(self.yaina.tmpdir, os.path.basename(self.source))
        shutil.copytree(self.source, self.build_dir)

        # Then we walk through and remove functions that are only intended to be in the server
        func_file =  os.path.join(self.build_dir, "Functions", "YAINA", "CfgFunctions.hpp");
        client_cfg = CfgFunctions.getTags(func_file, delete=False)
        server_cfg = CfgFunctions.getTags(func_file, True)

        # Now we go through the server config's commands, and delete matching ones in client
        # along with the the files on disk too prior to PBOing If it's empty after we're done
        # we remove the class entirely

        for tag in server_cfg.data:

            base_path = os.path.join(self.build_dir, "functions")

            for cat in server_cfg[tag].cats.data:

                base_path = os.path.join(self.build_dir, 'Functions', cat)

                if ('file' in server_cfg[tag].cats.data[cat].params):
                    base_path = os.path.join(self.build_dir, server_cfg[tag].cats.data[cat].params['file'].value[1:-1])

                for cmd in server_cfg[tag].cats.data[cat].cmds.data:
                    try:
                        p = self.get_path(base_path, server_cfg[tag].cats.data[cat].cmds.data[cmd])
                        self.logger.debug("Unlinking %s" % p)
                        os.unlink(p)
                    except: pass

                    try:
                        del(client_cfg[tag].cats.data[cat].cmds.data[cmd])
                    except KeyError: pass

                # Now we test the client data dir, and delete the tree
                try:
                    c = len(client_cfg[tag].cats.data[cat].cmds.data)
                    self.logger.debug("cmds count for %s: %s" % (tag, c))
                except KeyError:
                    c = 0

                if c == 0:
                    try:
                        self.logger.debug("rmtree %s" % base_path)
                        shutil.rmtree(base_path)
                    except: pass

                    try:
                        self.logger.debug("Removing cat: %s from %s" % (cat, tag))
                        del(client_cfg[tag].cats.data[cat])
                    except: pass

            # Clean up empty cats

            try:
                c = len(client_cfg[tag].cats.data)
                self.logger.debug("cat count for %s: %s" % (tag, c))
            except KeyError:
                c = 0
            if c == 0:
                try:
                    self.logger.debug("Removing tag: %s" % (tag))
                    del(client_cfg.data[tag])
                except: pass

        # re-write out the combined CfgFunctions.hpp
        with open(func_file, 'w') as fh:
            fh.write(CfgFunctions.compose(client_cfg))


        # Now just PBO it
        pbo_ver  = self.yaina.getNextVersion(self.yaina.args.map)
        pbo_name = "client.%s.%s" % (pbo_ver, self.yaina.args.map)

        server_dir = os.path.dirname(self.yaina.config.get('apps', 'server'))
        out_dir = os.path.join(server_dir, "mpmissions")

        # Fix briefing name in mission.sqm
        for x in ['mission.sqm', 'description.ext']:
            with open(os.path.join(self.build_dir, x), 'w') as new:
                with open(os.path.join(self.source, x)) as orig:
                    for line in orig:
                        new.write(line.replace("%VERSION%", pbo_ver))

        # Add in a commit ref so we always have a ref
        with open(os.path.join(self.build_dir, "build.txt"), 'w') as fh:
            fh.write(self.yaina.ref)

        try:
            os.makedirs(out_dir)
        except: pass

        cmd = [
            self.yaina.config.get('apps', 'makepbo'),
            "-P",
            "-X", "thumbs.db,*.cpp,*.bak,*.png,*.dep,*.log",
            self.build_dir,
            os.path.join(out_dir, pbo_name)
        ]

        self.logger.info("Running: %s" % " ".join(cmd))
        subprocess.call(cmd)

        # And now that's done, lets update next_*
        self.yaina.setRunConfig('next_%s' % self.yaina.args.map, 'mission', pbo_name)
        self.yaina.setRunConfig('next_%s' % self.yaina.args.map, 'version', pbo_ver)
