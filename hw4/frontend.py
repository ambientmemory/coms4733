'''
Homework 4
Team 10
Jett Andersen, Tia Zhao, Piyali Mukherjee
'''


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
        Frame.__init__(self,parent)
        self.parent = parent
        self.initUI()

    def initUI(self):
        self.parent.title("Map")
        self.pack(fill=BOTH, expand=1)

        canvas = Canvas(self, bg="white")
        self.drawer(canvas)

    def drawer(self, canvas):
        '''
        gets data for drawing and renders it to the screen
        '''

        graph, world, obstacles, grownObstacles, start_goal = createGraph()

        # render world
        scale = lambda p: [scale_x*(tr_x - p.x), scale_y*(tr_y - p.y)]
        toCanvasPoly = lambda os: list(it.chain(*map(scale, os)))
        canvas.create_polygon(toCanvasPoly(world), outline='blue', fill='white', width=3.0)

        # render grown obstacles
        for grownObstacle in grownObstacles:
            canvas.create_polygon(toCanvasPoly(grownObstacle), outline='green', fill='white', width=3.0)

        # render original obstacles
        for obstacle in obstacles:
            canvas.create_polygon(toCanvasPoly(obstacle), outline='black', fill='white', width=3.0)

        # render visibility graph
        for v1 in graph.vertices:
            for v2 in v1.adjacent:
                canvas.create_polygon(toCanvasPoly([v1.p, v2.p]), outline='red', fill='white', width=1.0)

        # render shortest path
        path = dijkstra(graph.vertices, start_goal[0], start_goal[1])
        for i in range(len(path) - 1):
            canvas.create_polygon(toCanvasPoly([path[i].p, path[i+1].p]),
                    outline='grey', fill='white', width=5.0)

        # write shortest path to file
        pathFile = open('path.txt', 'w')
        pathFile.write(''.join(map(lambda v: str(v.p.x) + ' ' + str(v.p.y) + '\n', path)))

        canvas.pack(fill=BOTH, expand=1)


def main():
    gui_tk = Tk()
    visualizer = Visual(gui_tk)
    gui_tk.geometry("1000x600+300+300")
    gui_tk.mainloop()

if __name__ == '__main__':
    main()
