import math

class Point:
    x = 0.0
    y = 0.0
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def plus(self, p):
        return Point(p.x + self.x, p.y + self.y)

    def __repr__(self):
        return 'Point(' + str(self.x) + ',' + str(self.y) + ')'

def makePoint(xy):
    return Point(xy[0], xy[1])

class Vertex:
    adjacent = []
    p = Point(0, 0)
    index = 0

    def __init__(self, p, index):
        self.adjacent = []
        self.p = p
        self.index = index

    def __repr__(self):
        return str(self.index) + ': ' + self.p.__repr__() + ' - ' \
                + [v.index for v in self.adjacent].__repr__()

class Graph:
    vertices = []
    maxIndex = -1
    def addVertex(self, vertex):
        if vertex.index <= self.maxIndex:
            print('Error: bad vertex index (' + str(vertex.index) + ')')
        else:
            self.vertices.append(vertex)
            self.maxIndex = vertex.index

    def __repr__(self):
        return self.vertices.__repr__()

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
    f1 = open('hw4_world_and_obstacles_convex.txt', 'r')
    obstacleStrings = f1.read().split('\n')[2:]

    world, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings)
    
    toPoint = lambda s: makePoint(list(map(float, s.strip().split(' '))))
    world = list(map(toPoint, world))
    
    obstacles = []
    while obstacleStrings != []:
        obstacle, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings[1:])
        if len(obstacle) > 0:
            obstacles = obstacles + [list(map(toPoint, obstacle))]

    f2 = open('hw4_start_goal.txt', 'r')

    graph = Graph()
    vertices = [ Vertex(toPoint(s), i) for i, s in enumerate(f2.read().split('\n')[:-1]) ]
    for vertex in vertices:
        graph.addVertex(vertex)

    return obstacles, world, graph

def convexHull(points):
    p = points[0]
    for point in points:
        if p.y < point.y or p.y == point.y and p.x < point.x:
            p = point

    eps = 0.00000000001
    orderedPoints = sorted(points,
            key=lambda q: (math.atan2(q.y - p.y, q.x - p.x)) % (2*math.pi))

    numPoints = len(orderedPoints)
    isInHull = [True] * numPoints

    for i in range(1, numPoints):
        p1 = orderedPoints[i - 1]
        p2 = orderedPoints[i]
        p3 = orderedPoints[(i + 1) % numPoints]
        
        if (p2.x - p1.x)*(p3.y - p1.y) - (p2.y - p1.y)*(p3.x - p1.x) <= 0:
            isInHull[i] = False

    return [point for i, point in enumerate(orderedPoints) if isInHull[i]]

def growPolygons(polygons):
    createDiam = 0.35
    grownPolygons = []

    for polygon in polygons:
        newPoints = []
        for point in polygon:
            newPoints.append(point.plus(Point(createDiam/2, createDiam/2)))
            newPoints.append(point.plus(Point(createDiam/2, -createDiam/2)))
            newPoints.append(point.plus(Point(-createDiam/2, createDiam/2)))
            newPoints.append(point.plus(Point(-createDiam/2, -createDiam/2)))
        grownPolygons.append(convexHull(newPoints))

    return grownPolygons

def createGraph():
    obstacles, world, graph = loadPolygons()
    grownObstacles = growPolygons(obstacles)

    print(graph)
