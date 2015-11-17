import math

class Point:
    x = 0.0
    y = 0.0
    def __init__(self, X, Y):
        self.x = X
        self.y = Y

    def plus(self, P):
        return Point(P.x + self.x, P.y + self.y)

    def __repr__(self):
        return '(' + str(self.x) + ',' + str(self.y) + ')'

def makePoint(xy):
    return Point(xy[0], xy[1])

class Vertex:
    adjacenct = []
    p = Point(0, 0)
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
    
    toPoint = lambda s: makePoint(list(map(float, s.split(' ')[:-1])))
    world = list(map(toPoint, world))
    
    obstacles = []
    while obstacleStrings != []:
        obstacle, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings[1:])
        if len(obstacle) > 0:
            obstacles = obstacles + [list(map(toPoint, obstacle))]

    return obstacles, world

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

mypolygons = [[Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)]]

def doIt():
    return growPolygons(loadPolygons()[0])

def createGraph(vertices):
    return []
