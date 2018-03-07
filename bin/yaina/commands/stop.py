from utils import Command
import wmi
import shlex
import os
import subprocess
import time

# https://msdn.microsoft.com/en-us/library/aa394372(v=vs.85).aspx

class Stop(Command):
    @classmethod
    def setup(cls, s):
        p = s.add_parser("stop", description="", help="Stop Server + HC instances")
        p.set_defaults(cmd=cls)

    def parse(self, cmd):
        r = dict()

        if cmd is None:
            return r

        for arg in shlex.split(cmd, False)[1:]:
            try:
                (k,v) = arg.split("=")
                r[k[1:]] = v
            except ValueError:
                r[arg[1:]] = True

        return r

    def run(self, yaina):

        # First we try and do it nicely
        import subprocess

        try:
            cmd = [
                'powershell.exe',
                '-ExecutionPolicy',
                'Unrestricted',
                '-File', os.path.join(yaina.root, 'bin', 'stop.ps1'),
                '-instance', yaina.config.get('common', 'instance')
            ]
            subprocess.call(cmd)
        except Exception,e:
            yaina.logger.error("Failed to call subprocess: %s" % e.message)

        # wait 3 seconds to let it close
        time.sleep(3)

        # Then for completeness, and if the above failed, we go with a sledgehammer
        conn = wmi.WMI()
        for p in conn.Win32_Process():
            if p.Name == 'arma3server_x64.exe':
                d = self.parse(p.CommandLine)
                if 'yainaInstance' in d and d['yainaInstance'] == yaina.config.get('common', 'instance'):
                    p.Terminate()