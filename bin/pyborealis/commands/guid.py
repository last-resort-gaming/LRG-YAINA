import sys
import md5
from ..util import Command, steamid_to_guid

class GUID(Command):

    @classmethod
    def setup(cls, subparsers):
        p = subparsers.add_parser("guid", description="Generates a GUID for given steam ID", help="Generates GUID for Steam ID")
        p.set_defaults(cmd=cls)
        p.add_argument('SteamID', help="Steam ID to generate GUID for")

    def run(self):
        # The gui just runs...
        try:
            print steamid_to_guid(self.args.SteamID)
        except:
            print "Invalid Steam ID"
            return 1
