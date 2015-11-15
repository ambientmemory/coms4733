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
        canvas = Canvas(self, bg="white")
        self.drawer(canvas)

    def drawer(self,canvas):
        obstacle_filename = open('hw4_world_and_obstacles_convex.txt')
        line_counter = 0
        total_obst = 0
        points=[]
        current_line = obstacle_filename.readline()
        while current_line:
            line_counter = line_counter+1
            current_entities = current_line.split()
            if len(current_entities) == 1 and line_counter == 1:
                total_obst = int(current_entities[0])
            elif len(current_entities) == 1:
                vertices_current_obst=int(current_entities[0])
            else:
                points.append(float(current_entities[0])*10)
                points.append(float(current_entities[1])*10)
            current_line = obstacle_filename.readline()

            if line_counter == 18:
                break
        #endwhile for file reading

        # TODO: Should be inside a loop
        #initialize coordinates for polygon vertices
        #points = [50,25, 50, 425]
        #render polygons
        canvas.create_polygon(points, outline='black', fill='grey', width=0.5)

        canvas.pack(fill=BOTH, expand=1)


def main():
    gui_tk = Tk()
    visualizer = Visual(gui_tk)
    gui_tk.geometry("1000x600+300+300")
    gui_tk.mainloop()

"""def obstacle(filename):
    no_of_vertices = 0
    coords_of_vertices = []

    def __init___(self):
        self."""

if __name__ == '__main__':
    main()