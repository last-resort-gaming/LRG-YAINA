
#import qdarkstyle
from tabs import *
from PyQt4 import QtGui

class BorealisWindow(QtGui.QMainWindow):

    def __init__(self):
        super(BorealisWindow, self).__init__()

        w_width = 700
        w_height = 400
        dw = QtGui.QDesktopWidget()

        self.setGeometry((dw.width() / 2) - (w_width / 2), (dw.height() / 2) - (w_height / 2), w_width, w_height)
        self.setWindowTitle("PyBorealis")

        # Main Pages
        tabs = QtGui.QTabWidget()

        tab1 = QtGui.QWidget()
        tab1.setLayout(UserTab())
        tabs.addTab(tab1, "Users")

        tab2 = QtGui.QWidget()
        tab2.setLayout(GroupTab())
        tabs.addTab(tab2, "Groups")

        tab3 = QtGui.QWidget()
        tab3.setLayout(OutputsTab())
        tabs.addTab(tab3, "Outputs")

        self.setCentralWidget(tabs)

        self.show()