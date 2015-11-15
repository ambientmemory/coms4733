__author__ = 'Piyali'

import tkinter
from tkinter import *

class Visual(Frame):

    def __init__(self,parent):
        #initialize frame
        Frame.__init__(self,parent)
        self.parent = parent
        self.initUI()

    def initUI(self):
        self.parent.title("Map")
        #setting frame params
        self.pack(fill=BOTH, expand=1)

        #start rendering here
        canvas = Canvas(self)

        #initialize coordinates for polygon vertices
        points = [150,100, 200, 120, 240, 180, 210, 200, 150, 150, 100, 200 ]
        canvas.create_polygon(points, outline='black', fill='gray', width=2)

        canvas.pack(fill=BOTH, expand=1)

def main():
    gui_tk = Tk()
    visualizer = Visual(gui_tk)
    gui_tk.geometry("500x500+300+300")
    gui_tk.mainloop()

if __name__ == '__main__':
    main()