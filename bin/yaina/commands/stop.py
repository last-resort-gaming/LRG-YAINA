from utils import Command
import wmi
import shlex

# https://msdn.microsoft.com/en-us/library/aa394372(v=vs.85).aspx

class Stop(Command):
    @classmethod
    def setup(cls, s):
        p = s.add_parser("stop", description="", help="Stop Server + HC instances")
        p.set_defaults(cmd=cls)

    def parse(self, cmd):
        r = dict()

        for arg in shlex.split(cmd, False)[1:]:
            try:
                (k,v) = arg.split("=")
                r[k[1:]] = v
            except ValueError:
                r[arg[1:]] = True

        return r

    def run(self, yaina):

        conn = wmi.WMI()
        for p in conn.Win32_Process():
            if p.Name == 'arma3server_x64.exe':
                d = self.parse(p.CommandLine)
                if 'yainaInstance' in d and d['yainaInstance'] == yaina.config.get('common', 'instance'):
                    p.Terminate()