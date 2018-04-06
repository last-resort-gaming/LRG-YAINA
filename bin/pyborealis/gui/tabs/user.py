
from PyQt4 import QtGui, QtCore, Qt
from pyborealis import DB
from pyborealis.core.user import User
from pyborealis.util import steamid_to_guid

class ListWidgetUser(QtGui.QListWidgetItem):

    def __init__(self, user):
        super(ListWidgetUser, self).__init__()
        self.user = user
        self.setText(user.name)

class UserInfo(QtGui.QWidget):

    def __init__(self):
        super(UserInfo, self).__init__()

        # ElemFont
        self.title_font  = QtGui.QFont("Arial", 10, QtGui.QFont.Bold)
        self.value_font  = QtGui.QFont("Arial", 10)

        # Build user info layout
        base = QtGui.QVBoxLayout()
        base.setSpacing(10)

        n = QtGui.QLabel("Name:")
        self.name = QtGui.QLabel("")
        self._setup_item(n,self.name)
        base.addWidget(n)
        base.addWidget(self.name)

        n = QtGui.QLabel("Steam ID:")
        self.steamid = QtGui.QLabel("")
        self._setup_item(n,self.steamid)
        base.addWidget(n)
        base.addWidget(self.steamid)

        n = QtGui.QLabel("Battleye GUID:")
        self.beguid = QtGui.QLabel("")
        self._setup_item(n,self.beguid)
        base.addWidget(n)
        base.addWidget(self.beguid)

        # Zeus Trained
        self.zeus_trained = QtGui.QCheckBox()
        base.addWidget(self._add_checkbox(self.zeus_trained, "Zeus Trained"))
        self.zeus_trained.stateChanged.connect(self.ZeusTrainedState)

        base.addStretch()
        self.setLayout(base)

    def _add_checkbox(self, target, title):
        row = QtGui.QWidget()
        lay = QtGui.QHBoxLayout()
        lay.setMargin(0)
        row.setLayout(lay)
        n = QtGui.QLabel(title)
        lay.addWidget(n)
        lay.addWidget(target)
        lay.addStretch()
        #lay.addStretch()
        self._setup_item(n)
        return row

    def _setup_item(self, a, b = None):
        a.setFont(self.title_font)
        if b is not None:
            b.setTextInteractionFlags(QtCore.Qt.TextBrowserInteraction)
            b.setIndent(15)
            b.setFont(self.value_font)

    def update_user_info(self, item):
        self.name.setText(item.text())
        self.user = item
        self.steamid.setText(str(item.user.steamid))
        self.beguid.setText(item.user.beguid)
        self.zeus_trained.setChecked(item.user.zeus_trained)

    def ZeusTrainedState(self, x):
        self.user.user.zeus_trained = x == 2

class AddUserDialog(QtGui.QDialog):
    def __init__(self):
        super(AddUserDialog, self).__init__()

        self.setWindowTitle('Create User')

        base = QtGui.QVBoxLayout()
        base.setSpacing(10)

        # ElemFont
        self.title_font  = QtGui.QFont("Arial", 10, QtGui.QFont.Bold)
        self.value_font  = QtGui.QFont("Arial", 10)

        # Build user info layout

        n = QtGui.QLabel("Name:")
        self.name = QtGui.QLineEdit()
        base.addWidget(n)
        base.addWidget(self.name)

        n = QtGui.QLabel("Steam ID:")
        self.steamid = QtGui.QLineEdit()
        base.addWidget(n)
        base.addWidget(self.steamid)

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
        self.exec_()

    def accept(self):
        if str(self.name.text()).strip() == "":
            QtGui.QMessageBox().question(QtGui.QWidget(), "Error", "You must enter a name")
            return

        # validate
        try:
            steamid_to_guid(self.steamid.text())
        except:
            QtGui.QMessageBox().question(QtGui.QWidget(), "Error", "Invalid Steam ID")
            return

        # Already exists?
        u = User.getUser(int(self.steamid.text()))

        if u is not None:
            QtGui.QMessageBox().question(QtGui.QWidget(), "Error", "Steam ID already used by: %s" % u.name)
            return

        super(AddUserDialog, self).accept()


class UserTab(QtGui.QHBoxLayout):
    def __init__(self):
        super(UserTab, self).__init__()

        #splitter  = QtGui.QSplitter()
        #splitter.setChildrenCollapsible(False)

        self.user_list = QtGui.QListWidget()
        self.user_list.currentItemChanged.connect(self.UserClicked)

        # Title
        left_title = QtGui.QLabel("Users:")
        left_title.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))

        # User Buttons
        user_buttons = QtGui.QWidget()
        user_buttons_layout = QtGui.QHBoxLayout()
        user_buttons_layout.setMargin(0)
        user_buttons.setLayout(user_buttons_layout)

        # Add / Delete Button
        user_add = QtGui.QPushButton("+")
        user_add.setMaximumSize(30,30)
        user_add.setMinimumSize(30,30)
        user_add.clicked.connect(self.AddUser)
        user_buttons_layout.addWidget(user_add)

        user_del = QtGui.QPushButton("-")
        user_del.setMaximumSize(30,30)
        user_del.setMinimumSize(30,30)
        user_del.clicked.connect(self.DelUser)
        user_buttons_layout.addWidget(user_del)
        user_buttons_layout.addStretch()

        # Left Layout
        left_layout = QtGui.QVBoxLayout()
        left_layout.addWidget(left_title)
        left_layout.addWidget(self.user_list)
        left_layout.addWidget(user_buttons)

        left = QtGui.QWidget()
        left.setMinimumWidth(150)
        left.setMaximumWidth(200)
        left.setLayout(left_layout)

        # Right Layout
        self.right = UserInfo()

        # And add
        self.addWidget(left)
        self.addWidget(self.right)

        #self.addWidget(splitter)
        self.refresh_users()

    def DelUser(self):
        retval = QtGui.QMessageBox().question(QtGui.QWidget(), "Are you sure ?", "This will delete all information regarding this player, do you wish to proceed", "Cancel", "OK")
        if retval == 1:
            self.user_list.currentItem().user.delete()
            self.refresh_users()

    def AddUser(self):
        d = AddUserDialog()
        if d.result() == 1:
            User.add_user(str(d.name.text()), int(d.steamid.text()))
            self.refresh_users()

    def UserClicked(self, item):
        if item is not None:
            self.right.update_user_info(item)

    def refresh_users(self):
        self.user_list.clear()

        # Refresh
        c = 0
        for u in User.getAllUsers():
            w = ListWidgetUser(u)
            self.user_list.addItem(w)
            c += 1

        if c > 0:
            self.user_list.setCurrentRow(0)