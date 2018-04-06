
from PyQt4 import QtGui, QtCore, Qt
from pyborealis import DB
from pyborealis.core.user import User
from pyborealis.util import steamid_to_guid

class OutputsTab(QtGui.QVBoxLayout):
    def __init__(self):
        super(OutputsTab, self).__init__()

        self.title_font  = QtGui.QFont("Arial", 10, QtGui.QFont.Bold)
        self.value_font  = QtGui.QFont("Arial", 10)

        paths = dict()
        for row in DB.get().execute('SELECT id,path FROM paths'):
            paths[row[0]] = row[1]
        print paths

        # Super simple, file pickers
        n = QtGui.QLabel("BEC Admins:")
        self._bec_admins = QtGui.QLineEdit()
        self.setup_file_chooser(n, self._bec_admins, 'bec_admins')
        self._bec_admins.setText(paths.get('bec_admins', ""))

        n = QtGui.QLabel("YAINA Permissions IniDB:")
        self._yaina_perms = QtGui.QLineEdit()
        self.setup_file_chooser(n, self._yaina_perms, 'yaina_ini')
        self._yaina_perms.setText(paths.get('yaina_ini', ""))

        self.addStretch()

    def setup_file_chooser(self, a, b, db_key):

        # We add a HBoxLayout for the dialog child with the file picker and browse button

        a.setFont(self.title_font)
        self.addWidget(a)

        container = QtGui.QWidget()

        hbox = QtGui.QHBoxLayout()
        hbox.setMargin(0)
        hbox.setSpacing(5)
        hbox.insertSpacing(20, 20)

        # b.setTextInteractionFlags(QtCore.Qt.TextBrowserInteraction)
        b.setFont(self.value_font)
        b.setEnabled(False)
        hbox.addWidget(b)
        
        button = QtGui.QPushButton("Browse")
        button.setMaximumSize(70,30)
        button.setMinimumSize(70,30)
        button.clicked.connect(lambda: self.FilePick(a.text(), b, db_key))

        hbox.addWidget(button)

        container.setLayout(hbox)
        self.addWidget(container)

    def FilePick(self, title, destination, db_key):
        dialog = QtGui.QFileDialog(self.parentWidget(), title)
        dialog.setFileMode(QtGui.QFileDialog.AnyFile)
        #dialog.setSidebarUrls(urls)
        if dialog.exec_() == QtGui.QDialog.Accepted:
            file = str(dialog.selectedFiles()[0])
            destination.setText(file)
            c = DB.get()
            c.execute("""
                INSERT OR IGNORE INTO paths(id,path)
                VALUES (?,?)
            """, [db_key, file])
            c.execute("""
                UPDATE paths SET path=? where id=?
            """, [file, db_key])
            c.commit()
