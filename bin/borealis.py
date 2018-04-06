"""
PyBorealis: An ehanced python re-write of borealis https://bitbucket.org/lastresortgaming/borealis

This is a simple user management tool

  - users
    - create users, along with Arma GUIDs
  - Arbitrary Groups
    - Add users to groups
  - Permissions
    - Assign permissions from permission modules to groups
  - Output Generators
    - Permission modules generate the outputs required

"""
import os
import sys
from pyborealis import DB
from pyborealis.util import inheritors, Command
from pyborealis.commands import *

if __name__ == "__main__":
    from argparse import ArgumentParser

    p = ArgumentParser(description='Manage YAINA Permissions', add_help=False)

    s = p.add_subparsers(title="Commands", metavar="")
    for cmd in inheritors(Command):
        cmd.setup(s)

    og = p.add_argument_group('Optional Arguments')
    og.add_argument("-d", "--debug", action="store_true", help="debug logging", default=True)
    og.add_argument("-h", "--help",  action="help", help="show this help message and exit")
    og.add_argument('--db', help="Path to database", default="~/.borealis/borealis.sqlite3")

    args = p.parse_args()

    # Always set the DB path
    DB.db_file = os.path.expanduser(args.db)

    if "cmd" in args:
        sys.exit(args.cmd(args).run())

    print "ERROR: class configuration error for %s, cmd default argument missing" % cmd.__name__
    sys.exit(1)
