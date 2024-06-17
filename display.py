import serial
from itertools import islice
from PyQt6.QtCore import QThreadPool, QRunnable, QRect, Qt, QSize, pyqtSignal, QObject
from PyQt6.QtGui import QBrush, QPainter, QColor
from PyQt6 import QtWidgets
from threading import Event
# ser = serial.serial_for_url('rfc2217://localhost:4000', baudrate=9600)
# print(ser.name)

class Signals(QObject):
    received_frame = pyqtSignal(bytes)
class SerialRunnable(QRunnable):
    def __init__(self, *k, **kw):
        self.kill = Event()
        self.signals = Signals()
        super().__init__()

    def run(self):
        self.ser = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=8, stopbits=1, parity=serial.PARITY_NONE)
        while not self.kill.wait(0):
            l = self.ser.read_until(b"\xff\xff\xff\xff\xff\xff\xff\xfa")
            self.signals.received_frame.emit(l[:-8].rjust(64, b'\x00'))

class View(QtWidgets.QWidget):
    def __init__(self, *k, **kw):
        super().__init__(*k, **kw)
        self.setSizePolicy(
            QtWidgets.QSizePolicy.Policy.MinimumExpanding,
            QtWidgets.QSizePolicy.Policy.MinimumExpanding
        )
        self.frame = b"\x00" * 64

    def sizeHint(self):
        return QSize(40, 120)

    def setFrame(self, frame):
        self.frame = frame
        self.update()

    def paintEvent(self, e):
        painter = QPainter(self)
        brush = QBrush()
        brush.setColor(QColor('black'))
        brush.setStyle(Qt.BrushStyle.SolidPattern)
        field_width = self.width() // 16
        frame_iter = iter(self.frame)
        for j in range(0, 32 * field_width, field_width):
            curr_byte = next(frame_iter)
            for i in range(0, 8 * field_width, field_width):
                rect = QRect(i, j, field_width, field_width)
                if bin(curr_byte)[2:].rjust(8, '0')[i//16:1+i//16] == '1':
                    painter.fillRect(rect, brush)
                else:
                    painter.drawRect(rect)
            curr_byte = next(frame_iter)
            for i in range(8 * field_width, 16 * field_width, field_width):
                rect = QRect(i, j, field_width, field_width)
                i -= 8 * field_width
                if bin(curr_byte)[2:].rjust(8, '0')[i//16:1+i//16] == '1':
                    painter.fillRect(rect, brush)
                else:
                    painter.drawRect(rect)



class Window(QtWidgets.QMainWindow):
    def __init__(self, *k, **kw):
        super().__init__(*k, **kw)
        self.view = View(self)
        self.setCentralWidget(self.view)
        self.setGeometry(15, 15, 300, 600)
        self.worker = SerialRunnable()
        self.start()

    def closeEvent(self, *k, **kw):
        self.worker.kill.set()
        QThreadPool.globalInstance().waitForDone()

    def heightForWidth(w):
        return 2 * w

    def start(self):
        self.worker.signals.received_frame.connect(self.view.setFrame)
        QThreadPool.globalInstance().start(self.worker)


if __name__ == '__main__':

    app = QtWidgets.QApplication([])
    w = Window()
    w.show()
    app.exec()
