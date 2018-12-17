from utils import Command
import shlex
import os
import shutil
import ConfigParser
import re
import textwrap
import sys


class Deploy(Command):
    @classmethod
    def setup(cls, s):
        p = s.add_parser("deploy", description="", help="Deploy Server")
        p.set_defaults(cmd=cls)
        p.add_argument("-m", "--map", help="Package which Map (default: Altis)", default="Altis")
        p.add_argument("-r", "--release", action="store_true", help="Release, tag and update next version numbers")

    def run(self, yaina):
        # To deploy, we need to...
        #  - ensure clean git tree
        #  - tag this commit with our version number
        #  - increment our version number for the map
        #
        # This is very ugly for now, pending templating

        # Server Dir: A3Log config
        server_dir = os.path.dirname(yaina.config.get('apps', 'server'))
        mods_dir = os.path.dirname(yaina.config.get('apps', 'mods'))
        keys_dir = os.path.dirname(yaina.config.get('apps', 'keys'))

        # Instance Dir, server.cfg
        instance_name   = yaina.config.get('common', 'instance')
        instance_root   = os.path.join(yaina.config.get('common', 'root'), instance_name)
        instance_logs   = os.path.join(instance_root, 'logs')
        instance_server = os.path.join(instance_root, 'profiles', 'server', 'Users', 'server')
        instance_be     = os.path.join(instance_root, 'battleye')

        for d in [instance_server, instance_be, instance_logs]:
            try:
                os.makedirs(d)
            except: pass

        # keys
        for root, dirs, files in os.walk(keys_dir):
            for fn in files:
                if(os.path.splitext(fn)[1] == '.bikey'):
                    try:
                        shutil.copyfile(os.path.join(root, fn), os.path.join(server_dir, 'Keys', fn))
                    except: pass

        # Battleye
        beservercfg = os.path.join(instance_be, 'beserver.cfg')
        with open(beservercfg, 'w') as fh:
            for o in yaina.config.options('battleye'):
                fh.write("%s %s\n" % (o, yaina.config.get('battleye', o)))

        # We then copy this for beserver_x64
        beservercfg_x64 = os.path.join(instance_be, 'beserver_x64.cfg')
        try:
            os.unlink(beserver_x64)
        except: pass

        shutil.copyfile(beservercfg, beservercfg_x64)

        # Bring in the server.Arma3Profile (difficulty)
        shutil.copyfile(
            os.path.join(yaina.root, 'conf', 'server.arma3profile'),
            os.path.join(instance_server, 'server.Arma3Profile'))

        # Logging, we only care about changing the output path to instance_root / logs
        a3log = ConfigParser.ConfigParser()
        a3log.optionxform=str
        a3log.read(os.path.join(yaina.root, 'conf', 'A3Log.ini'))
        a3log.set('Settings', 'CustomDirectory',instance_logs)
        with open(os.path.join(server_dir, 'A3Log-%s.ini' % instance_name), 'w') as fh:
            a3log.write(fh)

        # Main server config time
        # We read through this, really just to edit BattlEye, and add our mission cycle
        with open(os.path.join(yaina.root, 'conf', 'server.cfg')) as old:
            with open(os.path.join(instance_root, 'server.cfg'), 'w') as new:
                for line in old:
                    m = re.match(r'^(\s*BattlEye\s*=)', line, re.IGNORECASE)
                    if m:
                        new.write("%s %i;\n" % (m.group(1), yaina.config.getint('server', 'battleye')))
                    else:
                        new.write(line)

                new.write("\n")

                for k in ['password', 'passwordAdmin', 'serverCommandPassword', 'loopback']:
                    try:
                        new.write("%s = %s;\n" % (k, yaina.config.get('server', k)))
                    except: pass

                # Now we write our mission cycle
                new.write(textwrap.dedent('''

                class Missions
                {
                    class Mission1
                    {
                        template = "%s";
                        difficulty = "Custom";
                    };
                };
                ''' % (
                    yaina.runconf.get('next_%s' % yaina.args.map,  'mission')
                )))

        # If we got here, save version map to increment, and switch next to current
        # This is a mess, need to fix, so if the current != next, save the version

        for x in ['current', 'current_%s' % yaina.args.map]:

            nname = x.replace('current', 'next')

            try:
                v = yaina.runconf.get(x, 'version')
            except:
                v = ""

            nv = yaina.runconf.get(nname, 'version')
            if nv != v:
                if x == 'current':
                    yaina.getNextVersion()
                else:
                    yaina.getNextVersion(yaina.args.map)

                if not yaina.runconf.has_section(x):
                    yaina.runconf.add_section(x)
                for k in yaina.runconf.options(nname):
                    yaina.runconf.set(x, k, yaina.runconf.get(nname, k))

        # We only increment the version numbers on a release build
        if yaina.args.release:
            yaina.saveVersionInfo()

        # And our runconf
        yaina.saveRunConfig()
