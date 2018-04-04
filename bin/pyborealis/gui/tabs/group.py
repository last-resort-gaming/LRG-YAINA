#import qdarkstyle
from PyQt4 import QtGui, QtCore, Qt
from pyborealis import DB
from pyborealis.core.user import User
from pyborealis.core.group import Group

USER_ROLE  = 1001
USER_ROLE = 1002

class ListDialog(QtGui.QDialog):

    def __init__(self, title, heading):
        super(ListDialog, self).__init__()

        self.setWindowTitle(title)

        base = QtGui.QVBoxLayout()
        base.setSpacing(10)

        # ElemFont
        self.title_font  = QtGui.QFont("Arial", 10, QtGui.QFont.Bold)
        self.value_font  = QtGui.QFont("Arial", 10)

        # Build user info layout
        n = QtGui.QLabel(heading)
        base.addWidget(n)

        # Our Listbox
        self.listbox = QtGui.QListWidget()
        self.listbox.setSelectionMode(QtGui.QAbstractItemView.ExtendedSelection)
        base.addWidget(self.listbox)

        # Button Holder Widget
        buttons = QtGui.QWidget()
        bl = QtGui.QHBoxLayout()
        buttons.setLayout(bl)

        cancelButton = QtGui.QPushButton('&Cancel')
        cancelButton.clicked.connect(self.close)
        bl.addWidget(cancelButton)

        okButton = QtGui.QPushButton('&Ok')
        okButton.clicked.connect(self.accept)
        bl.addWidget(okButton)

        base.addWidget(buttons)

        self.setLayout(base)

class GroupTab(QtGui.QHBoxLayout):

    def _init_column(self, title, list, add, remove):

        # User Buttons
        btns_container = QtGui.QWidget()
        btns_layout    = QtGui.QHBoxLayout()
        btns_layout.setMargin(0)
        btns_container.setLayout(btns_layout)

        # Add / Delete Button
        add.setMaximumSize(30, 30)
        add.setMinimumSize(30, 30)
        btns_layout.addWidget(add)
        remove.setMaximumSize(30, 30)
        remove.setMinimumSize(30, 30)
        btns_layout.addWidget(remove)
        btns_layout.addStretch()

        # Build Layout
        layout = QtGui.QVBoxLayout()
        layout.addWidget(title)
        layout.addWidget(list)
        layout.addWidget(btns_container)

        # Build Container
        left = QtGui.QWidget()
        left.setMinimumWidth(150)
        #left.setMaximumWidth(200)
        left.setLayout(layout)

        return left

    def __init__(self):
        super(GroupTab, self).__init__()

        self.llistt = QtGui.QLabel("Groups:")
        self.llistt.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        self.llist = QtGui.QListWidget()
        self.llist.currentItemChanged.connect(self.GroupChanged)
        self.ladd  = QtGui.QPushButton("+")
        self.ladd.clicked.connect(self.AddGroup)
        self.ldel  = QtGui.QPushButton("-")
        self.ldel.clicked.connect(self.DelGroup)
        left = self._init_column(self.llistt, self.llist, self.ladd, self.ldel)
        self.addWidget(left)

        self.mlistt = QtGui.QLabel("Members:")
        self.mlistt.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        self.mlist = QtGui.QListWidget()
        self.mlist.setSelectionMode(QtGui.QAbstractItemView.ExtendedSelection)
        self.madd  = QtGui.QPushButton("+")
        self.madd.clicked.connect(self.AddMembers)
        self.mdel  = QtGui.QPushButton("-")
        self.mdel.clicked.connect(self.DelMembers)
        mid = self._init_column(self.mlistt, self.mlist, self.madd, self.mdel)
        self.addWidget(mid)

        self.rlistt = QtGui.QLabel("Permissions:")
        self.rlistt.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        self.rlist = QtGui.QListWidget()
        self.rlist.setSelectionMode(QtGui.QAbstractItemView.ExtendedSelection)
        self.radd  = QtGui.QPushButton("+")
        self.radd.clicked.connect(self.AddPerms)
        self.rdel  = QtGui.QPushButton("-")
        self.rdel.clicked.connect(self.DelPerm)
        right = self._init_column(self.rlistt, self.rlist, self.radd, self.rdel)
        self.addWidget(right)

        # Link Events
        self.refresh_llist()

    def AddMembers(self):
        # Multi-select list box of items not already in the list
        d = ListDialog('Add Members to Group', 'Members:')

        for u in User.getAllUsers():
            if u.steamid not in self.musers:
                itm = QtGui.QListWidgetItem('Player: %s' % u.name)
                itm.setData(USER_ROLE, u)
                d.listbox.addItem(itm)

        for g in Group.getAllGroups():
            if g.id not in self.mgroups:
                itm = QtGui.QListWidgetItem('Group: %s' % g.name)
                itm.setData(USER_ROLE, g)
                d.listbox.addItem(itm)

        d.exec_()

        if d.result() == 1:
            c = DB.get()
            for itm in d.listbox.selectedItems():
                x = itm.data(USER_ROLE).toPyObject()
                if isinstance(x, User):
                    c.execute("""INSERT INTO members VALUES (?, ?)""",
                            [self.group.id, x.steamid])
                    c.commit()
                else:
                    c.execute("""INSERT INTO members_group VALUES (?, ?)""",
                            [self.group.id, x.id])
                    c.commit()

            self.refresh_mlist()

    def DelMembers(self):
        user_list = [ "    -" + str(x.text()) for x in self.mlist.selectedItems() ]
        retval = QtGui.QMessageBox().question(QtGui.QWidget(), "Are you sure ?",
                                              "Are you sure you wish to delete the following permissions from this group: \n\n%s\n" % "\n".join(user_list),
                                              "Cancel", "OK")

        if retval == 1:
            c = DB.get()
            for itm in self.mlist.selectedItems():
                x = itm.data(USER_ROLE).toPyObject()
                if isinstance(x, User):
                    c.execute("""DELETE FROM members WHERE groupid=? AND steamid=?""",
                              [self.group.id, x.steamid])
                else:
                    c.execute("""DELETE FROM members_group WHERE groupid_p=? and groupid_c=?""",
                              [self.group.id, x.id])
            c.commit()
            self.refresh_mlist()

    def AddPerms(self):
        # Multi-select list box of items not already in the list
        d = ListDialog('Add Permissions to Group', 'Available Permissions:')

        for row in DB.get().execute("""
            SELECT permissions.idx, providers.name || ": " || permissions.permission AS perm
            FROM permissions
                JOIN providers
            ON permissions.provider = providers.idx
            ORDER BY perm
        """):
            if row[0] not in self.permlist:
                itm = QtGui.QListWidgetItem(row[1])
                itm.setData(USER_ROLE, row[0])
                d.listbox.addItem(itm)

        d.exec_()

        if d.result() == 1:
            c = DB.get()
            for itm in d.listbox.selectedItems():
                c.execute("""INSERT INTO permissions_map VALUES (?, ?)""", [self.group.id, itm.data(USER_ROLE).toPyObject()])

            c.commit()
            self.refresh_rlist()

    def DelPerm(self):
        permission_list = [ "    -" + str(x.text()) for x in self.rlist.selectedItems() ]
        retval = QtGui.QMessageBox().question(QtGui.QWidget(), "Are you sure ?",
                                              "Are you sure you wish to delete the following permissions from this group: \n\n%s\n" % "\n".join(permission_list),
                                              "Cancel", "OK")

        if retval == 1:
            c = DB.get()
            for itm in self.rlist.selectedItems():
                c.execute("""DELETE FROM permissions_map WHERE groupid=? AND permission=?""",
                          [self.group.id, itm.data(USER_ROLE).toPyObject()])
            c.commit()
            self.refresh_rlist()

    def AddGroup(self):
        text, ok = QtGui.QInputDialog.getText(QtGui.QWidget(), 'Create Group', 'New Group Name:')
        if ok:
            Group.add_group(str(text))
            self.refresh_llist()

    def DelGroup(self, item):
        x = self.llist.currentItem().data(USER_ROLE).toPyObject()

        if x.immutable:
            QtGui.QMessageBox().question(QtGui.QWidget(), "Error", "You cannot delete this group")
        else:
            retval = QtGui.QMessageBox().question(QtGui.QWidget(), "Are you sure?", "This will delete all permissions, memberships and the group itself, do you wish to proceed", "Cancel", "OK")
            if retval == 1:
                x.delete()
                self.refresh_llist()

    def GroupChanged(self, item):
        if item is not None:
            self.group = item.data(USER_ROLE).toPyObject()
            self.refresh_mlist(self.group)
            self.refresh_rlist(self.group)

    def refresh_rlist(self, group = None):

        if group is None:
            group = self.group

        # Just a List of Perms
        self.rlist.clear()
        self.permlist = []
        c = 0
        for row in DB.get().execute("""
            SELECT permissions.idx, providers.name || ": " || permissions.permission
            FROM permissions_map
            JOIN permissions
                ON permissions_map.permission = permissions.idx
            JOIN providers
                ON permissions.provider = providers.idx
            WHERE permissions_map.groupid = ?""", [group.id]):

            itm = QtGui.QListWidgetItem(row[1])
            itm.setData(USER_ROLE, row[0])
            self.permlist.append(row[0])
            self.rlist.addItem(itm)
            c += 1

        self.rlistt.setText('Permissions: (%i)' % c)

    def refresh_mlist(self, group = None):
        self.mlist.clear()
        self.musers = []
        self.mgroups = []

        if group is None:
            group = self.group

        # Refresh
        c = 0
        for x in group.members():
            if isinstance(x, User):
                w = QtGui.QListWidgetItem("Player: %s" % x.name)
                self.musers.append(x.steamid)
            else:
                w = QtGui.QListWidgetItem("Group: %s" % x.name)
                self.mgroups.append(x.id)

            w.setData(USER_ROLE, x)
            self.mlist.addItem(w)
            c += 1

        if c > 0:
            self.mlist.setCurrentRow(0)

        self.mlistt.setText('Members: (%i)' % c)

    def refresh_llist(self):
        self.llist.clear()

        # Refresh
        c = 0
        for u in Group.getAllGroups():
            w = QtGui.QListWidgetItem(u.name)
            if u.immutable:
                w.setTextColor(QtCore.Qt.darkGray)
            w.setData(USER_ROLE, u)
            self.llist.addItem(w)
            c += 1

        if c > 0:
            self.llist.setCurrentRow(0)

        self.llistt.setText('Groups: (%i)' % c)