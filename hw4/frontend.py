__author__ = 'Piyali'

import tkinter
from tkinter import *

class Visual(Frame):
    global tr_x
    tr_x = -4.0
    global scale_x
    scale_x = -60.0
    global tr_y
    tr_y = -4.0
    global scale_y
    scale_y = -60.0

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
        canvas = Canvas(self, bg="white")
        self.drawer(canvas)

    def drawer(self,canvas):
        obstacle_filename = open('hw4_world_and_obstacles_convex.txt')
        list_of_objects = []
        #This will be a list of lists, each element represents an object, each object in turn is a list of points

        # We first read the count of objects
        count_of_objects = int(obstacle_filename.readline().strip()) # read first line

        for i in range(count_of_objects):
            count_of_edges = int(obstacle_filename.readline().strip())
            # read first line of the object description

            list_of_points = []
            # The parameters to create_polygon are x0,y0,x1,y1...

            for j in range(count_of_edges):
                line = obstacle_filename.readline()
                point_data = line.split()
                list_of_points.append(scale_x*(tr_x - float(point_data[1])))
                list_of_points.append(scale_y*(tr_y - float(point_data[0])))
            #endfor

            list_of_objects.append(list_of_points)
            # This will append the list of points of the current object to the list of objects

        # renders outside map
        canvas.create_polygon(list_of_objects[0], outline='black', fill='white', width=3.0)

        #renders inner objects
        for i in range(1,count_of_objects):
            canvas.create_polygon(list_of_objects[i], outline='blue', fill='white', width=0.5)

        canvas.pack(fill=BOTH, expand=1)


def main():
    gui_tk = Tk()
    visualizer = Visual(gui_tk)
    gui_tk.geometry("1000x600+300+300")
    gui_tk.mainloop()

if __name__ == '__main__':
    main()