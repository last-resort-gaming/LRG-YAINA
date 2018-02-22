# Handle Cfg Functions
# https://community.bistudio.com/wiki/Functions_Library_(Arma_3)

from __future__ import unicode_literals, print_function
import re
import logging
import os
from pypeg2 import *
from pypeg2.xmlast import thing2xml

quoted_string_or_num = re.compile(r'(?:([\'"])(.*?(?<!\\))\1|[0-9]+)')

class Type(Keyword):
    grammar = Enum( K("class") )

class NoNewlineParameter(str):
    grammar = name(), blank, "=", blank, quoted_string_or_num, ";"

class Parameter(object):
    def __init__(self, o):
        self.value = o

    def set(self, value):
        self.value = value

    def __repr__(self):
        return self.value

    def __str__(self):
        return self.value

    grammar = name(), blank, "=", blank, quoted_string_or_num, ";", endl

class NoNewlineParameters(Namespace):
    grammar = maybe_some(indent(NoNewlineParameter))

class Parameters(Namespace):
    grammar = maybe_some(indent(Parameter))

class CfgCommand(List):
    params  = None
    grammar = indent(Type, name(), optional(blank, "{", attr("params", NoNewlineParameters), "}"), ";", endl)

class CfgCommands(Namespace):
    grammar = maybe_some(CfgCommand)

class CfgCategory(List):
    grammar = endl, indent(Type, name(), blank, "{", endl, attr("params", Parameters), attr("cmds", CfgCommands), "}", ";", endl)

class CfgCategories(Namespace):
    grammar = maybe_some(CfgCategory)

class CfgTag(List):
    grammar = Type, name(), blank, "{", endl, attr("params", Parameters), attr("cats", CfgCategories), "}", ";", endl, endl

class CfgTags(Namespace):
    grammar = maybe_some(CfgTag)

class CfgFunctions(object):

    @staticmethod
    def getTags(fn, se = False, delete=True):
        o = CfgFunctions(fn, se, delete=delete)
        return o.content

    @staticmethod
    def compose(x):
        return compose(x)

    def __init__(self, fn, server=False, delete=True):
        self.fcontents = ""
        self._read(fn, server, delete=delete)
        self.content = parse(self.fcontents, CfgTags)

    def _read(self, fn, server=False, delete=True):
        logger = logging.getLogger(__name__)
        fd = os.path.dirname(fn)
        with open(fn, 'r') as fh:
            for line in fh:
                m = re.match(r'^#include\s*([\'"])(.*?(?<!\\))\1', line)
                if m:

                    include_target = os.path.join(fd, m.group(2))

                    logger.debug("including %s" % include_target)

                    comps = list(os.path.splitext(include_target))
                    comps[0] += "_server"
                    server_target  = "".join(comps)

                    exclude_target = os.path.join(os.path.dirname(include_target), "yaina_server_only")

                    if server:
                        if (os.path.exists(server_target)):
                            self._read(server_target, server=server, delete=delete)
                        else:
                            if os.path.exists(exclude_target):
                               self._read(include_target, server=server, delete=delete)
                    else:
                        if not os.path.exists(exclude_target):
                            self._read(include_target, server=server, delete=delete)

                    if delete:
                        try:
                            logger.debug("Unlinking: %s"% include_target)
                            os.unlink(include_target)
                        except: pass

                        try:
                            logger.debug("Unlinking: %s" % server_target)
                            os.unlink(server_target)
                        except: pass

                        try:
                            logger.debug("Unlinking: %s" % exclude_target)
                            os.unlink(exclude_target)
                        except: pass

                else:
                    self.fcontents += line
        self.fcontents += "\n"
