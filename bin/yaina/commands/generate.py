
import sys
import os
import logging
import shutil
import subprocess
import textwrap
import re
from utils import Command
from yaina.CfgFunctions import CfgFunctions
import zipfile
import tempfile
import ConfigParser
from shutil import copyfile, ignore_patterns
from distutils.dir_util import copy_tree


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
        g.add_argument("ZEUSDAY_ZIP", nargs="?", help="zeusday template, mission name as per zip file")

        og = p.add_argument_group('Optional Arguments')
        og.add_argument("-m", "--map", help="Package which Map (default: Altis)", default="Altis")
        og.add_argument("-v", "--variant", help="Which version to build (Modded or Vanilla)", default="Vanilla")
        og.add_argument("-b", "--base", help="Merge Base Path, Server Side Includes")
        og.add_argument("-h", "--help", action="help", help="show this help message and exit")
        og.add_argument("-r", "--release", action="store_true", help="release, tag it in git")

    def run(self, yaina):

        self.logger = logging.getLogger(__name__)
        self.yaina  = yaina
        self.source = os.path.join(yaina.root, "client%s.%s" % (yaina.args.variant, yaina.args.map))
        self.base_source = os.path.join(yaina.root, "client%s.%s" % (yaina.args.variant, self.yaina.config.get('server', 'base_map')))

        if not os.path.isdir(self.source):
            print "Error: could not find client%s.%s in yaina rootdir" % (yaina.args.variant, yaina.args.map)
            sys.exit(1)

        if yaina.args.ZEUSDAY_ZIP:
            yaina.args.client = True
            yaina.args.server = False

            if not os.path.exists(yaina.args.ZEUSDAY_ZIP):
                print "Error: zeusday zip must be a zip archive" % yaina.args.ZEUSDAY_ZIP
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

    def copydir(self, root_src_dir, root_dst_dir):
        for src_dir, dirs, files in os.walk(root_src_dir):
            dst_dir = src_dir.replace(root_src_dir, root_dst_dir, 1)
            if not os.path.exists(dst_dir):
                os.makedirs(dst_dir)
            for file_ in files:
                src_file = os.path.join(src_dir, file_)
                dst_file = os.path.join(dst_dir, file_)
                if os.path.exists(dst_file):
                    os.remove(dst_file)
                shutil.copy(src_file, dst_dir)

    def build_server(self):
        # We do the server a little differently, by initially only copying in what's from
        # client that we need

        self.build_dir = os.path.join(self.yaina.tmpdir, "server")

        # Then we walk through and remove functions that are only intended to be in the server
        src_func_file =  os.path.join(self.base_source,    "Functions", "YAINA", "CfgFunctions.hpp")
        dst_func_file =  os.path.join(self.build_dir, "Functions", "YAINA", "CfgFunctions.hpp")

        server_cfg = CfgFunctions.getTags(src_func_file, True, delete=False)

        for tag in server_cfg.data:

            src_path  = os.path.join(self.base_source, "functions")
            base_path = os.path.join(self.build_dir, "functions")

            for cat in server_cfg[tag].cats.data:

                base_path = os.path.join(self.build_dir, 'Functions', cat)

                if ('file' in server_cfg[tag].cats.data[cat].params):

                    src_path  = os.path.join(self.base_source,    server_cfg[tag].cats.data[cat].params['file'].value[1:-1])
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
        for root, dirs, files in os.walk(self.base_source):
            for file in files:
                if os.path.splitext(file)[1] in required_extensions:
                    relpath = os.path.relpath(root, self.base_source)
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

        pbo_name = "yaina_%s" % self.yaina.args.variant

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
            A3GRAPHITE_PREFIX = "%s";
            ''' % (
                self.yaina.config.get('server', 'serverCommandPassword'),
                self.yaina.config.get('server', 'a3graphitePrefix')
            )))

        # Now write out our config.cpp
        with open(os.path.join(self.build_dir, "config.cpp"), 'w') as fh:

            try:
                with open(os.path.join(merge_dir, "config.cpp"), 'r') as cfg:
                    for line in cfg:
                        fh.write(line)
            except:
                with open(os.path.join(self.yaina.root, "conf", "config.cpp"), 'r') as cfg:
                    for line in cfg:
                        fh.write(line)

            fh.write(textwrap.dedent('''
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
        mods_dir = self.yaina.config.get('apps', 'mods')
        addon_path = os.path.join(mods_dir, "@yaina_%s" % self.yaina.args.variant)
        out_dir = os.path.join(addon_path, "addons")

        try:
            os.makedirs(out_dir)
        except: pass

        cmd = [
            self.yaina.config.get('apps', 'makepbo'),
            "-@=yaina",
            "-P",
            "-X", "thumbs.db,*.cpp,*.bak,*.png,*.dep,*.log",
            self.build_dir,
            os.path.join(out_dir, "yaina_%s" % self.yaina.args.variant)
        ]

        self.logger.info("Running: %s" % " ".join(cmd))
        subprocess.check_call(cmd)

    def build_client(self):

        def find_mission_sqm_dir(root):
            path = None

            for root, dirs, files in os.walk(tmp_dir):
                if path is not None: break
                for file in files:
                    if file == 'mission.sqm':
                        path = os.path.dirname(os.path.join(root, file))
                        break

            if path is None:
                raise Exception('Couldn\'t find mission.sqm from provided template zip')

            return path

        self.logger.debug("Building Client from Source: %s" % self.source)

        # We start with a complete copy of the client tree
        self.build_dir = os.path.join(self.yaina.tmpdir, os.path.basename(self.source))

        # If we are building a variant other than base_map, we need to copy over the other files, too
        shutil.copytree(self.base_source, self.build_dir, ignore=ignore_patterns('*.sqm'))

        # Copy the tree, if it's a zeusday zip, we delete the data dir, and
        # merge blat it with the files from the zip
        self.copydir(self.source, self.build_dir)

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


        # Handle zeusday zip contents
        if self.yaina.args.ZEUSDAY_ZIP:

            # We always blat Data dir as this is included in full in the template
            shutil.rmtree(os.path.join(self.build_dir, 'Data'))

            # We extract to a temp dir, find our mission.sqm (to avoid issues with where
            # the zip decides to add an extra directory etc. etc.
            tmp_dir = tempfile.mkdtemp(prefix="yaina_")

            # Now we extract the zip and overwrite the existing files
            with zipfile.ZipFile(self.yaina.args.ZEUSDAY_ZIP,"r") as zip_ref:
                zip_ref.extractall(tmp_dir)

            zeus_sqm_root = find_mission_sqm_dir(tmp_dir)

            # Now just copy everything across from the root
            # Find our mission.sqm
            for root, dirs, files in os.walk(zeus_sqm_root):
                for file in files:

                    # Build destination path
                    src = os.path.join(root, file)
                    relpath = os.path.relpath(os.path.dirname(src), zeus_sqm_root)
                    dst = os.path.join(self.build_dir, relpath, file)

                    try:
                        os.makedirs(os.path.dirname(dst))
                    except: pass

                    shutil.copyfile(os.path.join(root, file), dst)

            # Cleanup extrat dir
            shutil.rmtree(tmp_dir)

            # Handle our append file
            ext_file   = os.path.join(self.build_dir, 'description.ext')
            append_ext = os.path.join(self.build_dir, 'description.append.ext')
            if os.path.exists(append_ext):
                with open(ext_file, 'a') as dh:
                    dh.write('\n\n// Template Extensions')
                    with open(append_ext) as sh:
                        for line in sh:
                            dh.write(line)
                os.unlink(append_ext)

            # Handle template.ini attributes
            ini_f = os.path.join(self.build_dir, 'template.ini')
            if not os.path.exists(ini_f):
                raise Exception('template.ini file missing')

            # And populate config
            info = ConfigParser.ConfigParser()
            info.read(ini_f)

            # Finally, rewrite description.ext
            dext = os.path.join(self.build_dir, 'description.ext')
            fh, abs_path = tempfile.mkstemp()
            with os.fdopen(fh,'w') as nf:
                with open(dext) as of:
                    for ln in of:
                        try:
                            sp, rest = ln.split("=", 1)
                            sp = sp.strip()
                            v  = info.get('general', sp)
                            nf.write("%s = %s;\n" % (sp, v))
                            continue
                        except:
                            pass
                        nf.write(ln)

            os.unlink(dext)
            os.rename(abs_path, dext)
            os.unlink(ini_f)

            # Our PBO name is always a filtered onLoadName, and we need the map...
            pbo_name = "%s.%s" % (re.sub('[^a-zA-Z0-9_]', '', info.get('general', 'onLoadName')),
                                  info.get('general', 'map').strip('"'))

        else:
            # Now just PBO it
            pbo_ver  = self.yaina.config.get('server', 'version')
            pbo_name = "YAINA_%s.%s" % (self.yaina.args.variant, self.yaina.args.map)

            # Fix briefing name in mission.sqm
            for x in ['mission.sqm']:
                with open(os.path.join(self.build_dir, x), 'w') as new:
                    with open(os.path.join(self.source, x)) as orig:
                        for line in orig:
                            new.write(line.replace("%VERSION%", pbo_ver))
        # Lastly, ensure there is a root CfgFunctions.hpp
        cfg_f = os.path.join(self.build_dir, 'CfgFunctions.hpp')
        if not os.path.exists(cfg_f):
            with open(cfg_f, 'w') as fh:
                pass

        # If we have a settings.sqf.zeus, remove
        try:
            os.unlink(os.path.join(self.build_dir, 'settings.sqf.zeus'))
        except: pass

        out_dir = os.path.join(self.yaina.config.get('server', 'output'), pbo_name)
        
        # copy stuff into out_dir
        shutil.rmtree(out_dir, ignore_errors=True)
        shutil.copytree(self.build_dir, out_dir)

        if self.yaina.args.ZEUSDAY_ZIP:
            print "You can now use: !mission %s to start" % pbo_name
        else:
            # And now that's done, lets update next_*
            #self.yaina.setRunConfig('next_%s' % self.yaina.args.map, 'mission', pbo_name)
            #self.yaina.setRunConfig('next_%s' % self.yaina.args.map, 'version', pbo_ver)

            # We also dump out the ZeusDay template
            tmp_dir  = tempfile.mkdtemp(prefix="yaina_")
            zip_name = 'ZeusTemplate_%s.%s' % (self.yaina.args.variant, self.yaina.args.map)
            tmp_tgt = os.path.join(tmp_dir, zip_name)

            # Copy base template files
            shutil.copytree(os.path.join(self.yaina.root, 'Templates', 'zeus'), tmp_tgt)

            # copy the default files from main mission
            for f in [["settings.sqf.zeus", "settings.sqf"]]:

                src = os.path.join(self.base_source, f[0])
                dst = os.path.join(tmp_tgt, f[1])
                try:
                    os.makedirs(os.path.dirname(dst))
                except: pass
                shutil.copyfile(src, dst)
            
            for f in [["mission.sqm", "mission.sqm"]]:

                src = os.path.join(self.source, f[0])
                dst = os.path.join(tmp_tgt, f[1])
                try:
                    os.makedirs(os.path.dirname(dst))
                except: pass
                shutil.copyfile(src, dst)

            # And zip it all up
            zip_fn = os.path.join(self.yaina.root, 'Output', 'ZeusTemplate_%s.%s.zip' % (self.yaina.args.variant, self.yaina.args.map))
            try:
                os.makedirs(os.path.dirname(zip_fn))
            except: pass

            # And zip it up into our outputs dir
            zip_out = zipfile.ZipFile(zip_fn, 'w', zipfile.ZIP_DEFLATED)
            for root, dirs, files in os.walk(tmp_dir):
                for file in files:
                    fqp = os.path.join(root, file)
                    zip_out.write(fqp, arcname=os.path.relpath(fqp, tmp_dir))
            zip_out.close()

