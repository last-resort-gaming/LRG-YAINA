"""
General Utilities
"""

import md5

class Command(object):
    """
    Commands base class
    """

    @classmethod
    def setup(cls, subparsers):
        """
        Adds command-local parameters to the parser
        """
        p = subparsers.add_parser(cls.__name__, description="", help="%s is missing setup()" % cls.__name__)
        p.set_defaults(cmd=cls)
        pass

    def __init__(self, args):
        """
        Takes the argument parsers args for initialization
        """
        self.args = args
        pass

    def run(self):
        """
        Runner
        """
        pass


def inheritors(klass):
	subclasses = set()
	work = [klass]
	while work:
		parent = work.pop()
		for child in parent.__subclasses__():
			if child not in subclasses:
				subclasses.add(child)
				work.append(child)
	return subclasses

def steamid_to_guid(steam_id):
    if not len(str(steam_id)) == 17:
        raise ValueError('Invalid Steam ID')

    steam_id = int(steam_id)
    tmp = ""
    for i in range(8):
        tmp += chr((steam_id & 0xFF))
        steam_id >>= 8
    return md5.new("BE" + tmp).hexdigest()