import sys
from ..util import Command
from pyborealis.gui import BorealisWindow
from PyQt4 import QtGui
from pyborealis.db import DB
from ConfigParser import ConfigParser
from pyborealis.core.group import Group
from xml.etree import ElementTree as ET


class GUI(Command):

    @classmethod
    def setup(cls, subparsers):
        p = subparsers.add_parser("gui", description="Launches PyBorealis GUI", help="Launch PyBorealis GUI")
        p.set_defaults(cmd=cls)

    def run(self):
        # The gui just runs...
        app = QtGui.QApplication(sys.argv)
        gui = BorealisWindow()
        rc = app.exec_()

        if rc == 0:
            self.write()
        else:
            sys.exit(rc)

    def write(self):
        """
        Write output files
        """
        print "Updating Outputs"

        # First we get all the groups, then iterate the members and bundle our permissions
        build = dict()
        for g in Group.getAllGroups():
            perms = g.permissions()

            for n in g.members(True):

                # Append all the permissions
                steamid = str(n.steamid)
                if steamid not in build:
                    build[steamid] = {
                        'name': n.name,
                        'beguid': n.beguid,
                        'providers': {}
                    }

                for p in perms:
                    provider = str(p.provider).lower()
                    if provider not in build[steamid]['providers']:
                        build[steamid]['providers'][provider] = []
                    build[steamid]['providers'][provider].append(str(p.permission))

        outputs = dict()
        for row in DB.get().execute('SELECT id,path FROM paths'):
            outputs[row[0]] = row[1]

        if 'yaina_ini' in outputs:
            self.write_yaina_ini(outputs['yaina_ini'], build)
        else:
            print "yaina_ini path not set"

        # We need both the groups + admin file for BEC
        if 'bec_admins' in outputs:
            self.write_bec_files(outputs['bec_admins'], build)
        else:
            print "I need both teh BEC admins and groups file to be set to build outputs"

    def write_bec_files(self, bec_admins, build):
        # So, BEC wise, we go on the yaina commands, there are only the following configured:
        # 60mban, 24hban, 72hban, hrestart
        # Given BEC is hierarchy based, we just check the command availability and mark the groups
        # as such, 3,2,1,0
        #
        # <BECAdmins>
        # 	<admin id="0">
        # 		<name>MartinCo</name>
        # 		<guid>1cd37ca69066fd33a512879c74195b49</guid>
        # 		<group>0</group>
        # 		<groupname>Server Dev</groupname>
        # 	</admin>
        # </BECAdmins>

        group_names = ['Level0', 'Level1', 'Level2', 'Level3']
        command_set = ['hrestart', '72hban', '24hban', '60mban']

        # We can build our XML
        document = ET.Element('BEAdmins')

        admin_id = 0
        for u in build:
            if 'yaina' not in build[u]['providers']:
                pass

            level = -1
            i = 0
            for c in command_set:
                if c in build[u]['providers']['yaina']:
                    level = i
                    break
                i += 1

            if level != -1:
                n = ET.SubElement(document, 'admin')
                n.set('id', str(admin_id))

                c = ET.SubElement(n, 'name')
                c.text = build[u]['name']

                c = ET.SubElement(n, 'guid')
                c.text = build[u]['beguid']

                c = ET.SubElement(n, 'group')
                c.text = str(level)

                c = ET.SubElement(n, 'groupname')
                c.text = group_names[level]

                admin_id += 1

        with open(bec_admins, 'w') as fh:
            et = ET.ElementTree(document)
            et.write(fh, encoding='utf-8', xml_declaration=True)

    def write_yaina_ini(self, file, build):
        """
        YAINA INI FILE

        [SteamID]
        ; User Name
        yaina = [...]
        infistar = [...]
        """

        # If we have a ini file to dump to...
        with open(file, 'w') as fh:
            # Now dump it to our file
            ini = ConfigParser(allow_no_value=True)
            for steamid, arr in build.iteritems():
                if not ini.has_section(steamid):
                    ini.add_section(steamid)
                    ini.set(steamid, '; %s' % arr['name'])


                for provider,cmds in arr['providers'].iteritems():
                    s = str(provider).lower()
                    ini.set(steamid, s, cmds)

            ini.write(fh)