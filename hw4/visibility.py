class point:
    x = 0
    y = 0
    def __init__(self, X, Y):
        x = X
        y = Y

class vertex:
    adjacenct = []
    p = point(0, 0)
    def __init__(self, P):
        adjacent = []
        p = P

def splitWhen(pred, iterable):
    l1 = []
    l2 = []
    hasSplit = False
    for x in iterable:
        if not hasSplit and not pred(x):
            l1 = l1 + [x]
        else:
            hasSplit = True
            l2 = l2 + [x]

    return l1, l2

def loadPolygons():
    f = open('hw4_world_and_obstacles_convex.txt', 'r')
    obstacleStrings = f.read().split('\n')[2:]

    world, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings)
    
    toPoint = lambda s: list(map(float, s.split(' ')[:-1]))
    world = list(map(toPoint, world))
    
    obstacles = []
    while obstacleStrings != []:
        obstacle, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings[1:])
        obstacles = obstacles + [list(map(toPoint, obstacle))]

    return obstacles, world

def growPolygons(vertices, createSize):
    return []

def createGraph(vertices):
    return []
