from tkinter import *
from dijkstra import *
import itertools as it

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

    def drawer(self, canvas):
        graph, world, obstacles, grownObstacles, start_goal = createGraph()
#        path = dijkstra(graph.vertices, start_goal[0], start_goal[1])

        scale = lambda p: [scale_x*(tr_x - p.x), scale_y*(tr_y - p.y)]
        toCanvasPoly = lambda os: list(it.chain(*map(scale, os)))
        canvas.create_polygon(toCanvasPoly(world), outline='blue', fill='white', width=3.0)

        for obstacle in obstacles:
            canvas.create_polygon(toCanvasPoly(obstacle), outline='black', fill='white', width=3.0)

        for obstacle in grownObstacles:
            canvas.create_polygon(toCanvasPoly(obstacle), outline='yellow', fill='white', width=3.0)

        for v1 in graph.vertices:
            for v2 in v1.adjacent:
                canvas.create_polygon(toCanvasPoly([v1.p, v2.p]), outline='red', fill='white', width=1.0)

        canvas.pack(fill=BOTH, expand=1)


def main():
    gui_tk = Tk()
    visualizer = Visual(gui_tk)
    gui_tk.geometry("1000x600+300+300")
    gui_tk.mainloop()

if __name__ == '__main__':
    main()
