from yaina.commands.stop import Stop
from utils import Command
import wmi
import subprocess
import os
import time

class Start(Command):
    @classmethod
    def setup(cls, s):
        p = s.add_parser("start", description="", help="Start Server")
        p.set_defaults(cmd=cls)
        p.add_argument('--nohc', action='store_true', help='Don\'t start any HCs')

    def run(self, yaina):

        # Stop existing
        Stop().run(yaina)

        instance_name = yaina.config.get('common', 'instance')
        instance_root = os.path.join(yaina.config.get('common', 'root'), instance_name)
        profiles_dir  = os.path.join(instance_root, 'profiles')
        server_port   = yaina.config.getint('server', 'port')

        try:
            os.makedirs(profile_dir)
        except: pass

        # Start Server
        cmd = [
            yaina.config.get('apps', 'server'),
            '-name=server',
            '-nosplash',
            '-noSound',
            '-world=empty',
            '-autoInit',
            '-loadMissionToMemory',
            '-yainaInstance=%s' % instance_name,
            '-bepath=%s' % os.path.join(instance_root, 'battleye'),
            '-profiles=%s' % os.path.join(profiles_dir, 'server'),
            '-config=%s' % os.path.join(instance_root, 'server.cfg'),
            '-A3Log=A3Log-%s.ini' % instance_name,
            '-port=%s' % server_port,
            '-serverMod=%s' % yaina.runconf.get('current', 'serverMod')
        ]

        print cmd
        subprocess.Popen(cmd)

        time.sleep(6)

        if not yaina.args.nohc:
            for i in range(0, yaina.config.getint('hc', 'count')):

                name = "hc%i" % (i + 1)

                cmd = [
                    yaina.config.get('apps', 'server'),
                    '-name=%s' % name,
                    '-profiles=%s' % os.path.join(profiles_dir, name),
                    '-yainaInstance=%s' % instance_name,
                    '-nosplash',
                    '-client',
                    '-noSound',
                    '-connect=%s' % yaina.config.get('hc', 'server'),
                    '-port=%i' % server_port,
                    '-mod=%s' % yaina.runconf.get('current', 'hcMod')
                ]

                optionals = [
                    ['password', 'server', 'password']
                ]

                for x in optionals:
                    try:
                        cmd.append('-%s=%s' % (x[0], yaina.config.get(x[1], x[2])))
                    except: pass

                print cmd
                subprocess.Popen(cmd)
                time.sleep(4)
