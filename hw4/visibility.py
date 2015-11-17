import math

class Point:
    x = 0.0
    y = 0.0
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def plus(self, p):
        return Point(p.x + self.x, p.y + self.y)

    def shift(self, p, scale):
        dx = self.x - p.x
        dy = self.y - p.y
        self.x = self.x + dx * scale
        self.y = self.y + dy * scale

    def __repr__(self):
        return 'Point(' + str(self.x) + ',' + str(self.y) + ')'

def makePoint(xy):
    return Point(xy[0], xy[1])

class Vertex:
    adjacent = []
    p = Point(0, 0)
    index = -1
    obstacle = -1

    def __init__(self, p, index, obstacle):
        self.adjacent = []
        self.p = p
        self.index = index
        self.obstacle = obstacle

    def __repr__(self):
        return str(self.index) + ': ' + self.p.__repr__() + ' - ' \
                + [v.index for v in self.adjacent].__repr__()

    def addAdjacent(self, vertex):
        self.adjacent.append(vertex)
        vertex.adjacent.append(self)


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
    vertices = [ Vertex(toPoint(s), i, -1) for i, s in enumerate(f2.read().split('\n')[:-1]) ]
    for vertex in vertices:
        graph.addVertex(vertex)

    return obstacles, world, graph

def orientation(p1, p2, p3):
    o = (p2.x - p1.x)*(p3.y - p1.y) - (p2.y - p1.y)*(p3.x - p1.x)
    if o > 0:
        return 1
    if o < 0:
        return -1
    return 0

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
        
        if orientation(p1, p2, p3) <= 0:
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

def intersects(p1, p2, p3, p4):
    return orientation(p1, p2, p3) != orientation(p1, p2, p4) and \
            orientation(p3, p4, p1) != orientation(p3, p4, p2)

def isVisible(v1, v2, obstacles, world):
    for i, obstacle in enumerate(obstacles + [world]):
        p1 = Point(v1.p.x, v1.p.y)
        p2 = Point(v2.p.x, v2.p.y)

        # move away in case v1 is inside obstacle2 or vice versa
        if v1.obstacle == i:
            p2.shift(p1, 100)
        elif v2.obstacle == i:
            p1.shift(p2, 100)

        for j in range(len(obstacle)):
            if intersects(p1, p2,
                    obstacle[j], obstacle[(j + 1) % len(obstacle)]):
                return False

    return True

def createGraph():
    obstacles, world, graph = loadPolygons()
    grownObstacles = growPolygons(obstacles)
    index = graph.maxIndex + 1

    for obsInd, obstacle in enumerate(grownObstacles):
        vertices = []
        for point in obstacle:
            vertex = Vertex(point, index, obsInd)
            index = index + 1
            vertices.append(vertex)
            graph.addVertex(vertex)

        for i in range(len(vertices)):
            vertices[i].addAdjacent(vertices[(i + 1) % len(vertices)])

    size = len(graph.vertices)
    for v1i in range(size):
        v1 = graph.vertices[v1i]
        for v2i in range(v1i + 1, size):
            v2 = graph.vertices[v2i]
            if v1.obstacle != v2.obstacle and \
                    isVisible(v1, v2, obstacles, world):
                v1.addAdjacent(v2)

    return graph
