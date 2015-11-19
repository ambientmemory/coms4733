'''
Homework 4
Team 10
Jett Andersen, Tia Zhao, Piyali Mukherjee
'''

import math

class Point:

    # coordinates
    x = 0.0
    y = 0.0

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def plus(self, p):
        ''' returns a point that is the sum of self and p '''
        return Point(p.x + self.x, p.y + self.y)

    def shift(self, p, scale):
        '''
        shifts self in the direction self - p by the distance between
        p and self multiplied by scale
        '''
        dx = self.x - p.x
        dy = self.y - p.y
        self.x = self.x + dx * scale
        self.y = self.y + dy * scale

    def __repr__(self):
        return 'Point(' + str(self.x) + ',' + str(self.y) + ')'

class Vertex:

    # list of adjacent vertices
    adjacent = []
    
    # associated point
    p = Point(0, 0)

    # associated obstascle
    obstacle = -1

    # unique identifier
    index = -1

    def __init__(self, p, index, obstacle):
        self.adjacent = []
        self.p = p
        self.index = index
        self.obstacle = obstacle

    def __repr__(self):
        return str(self.index) + ': ' + self.p.__repr__() + ' - ' \
                + [v.index for v in self.adjacent].__repr__()

    def addAdjacent(self, vertex):
        '''
        adds vertex to self's adjancency list and vice versa
        '''

        self.adjacent.append(vertex)
        vertex.adjacent.append(self)

    def isAdjacent(self, vertex):
        '''
        returns true iff self and vertex are adjacent
        '''

        selfAdjInds = list(map(lambda v: v.index, self.adjacent))
        return vertex.index in selfAdjInds

    def removeAdjacent(self, vertex):
        '''
        remves vertex from self's adjacent vertex list and vice versa
        if possible
        '''

        selfAdjInds = list(map(lambda v: v.index, self.adjacent))
        vertexAdjInds = list(map(lambda v: v.index, vertex.adjacent))
        if vertex.index in selfAdjInds:
            del self.adjacent[selfAdjInds.index(vertex.index)]
            del vertex.adjacent[vertexAdjInds.index(self.index)]

class Graph:
    # vertices in the graph
    vertices = []

    # used to ensure vertex identifiers are unique
    maxIndex = -1

    def addVertex(self, vertex):
        '''
        adds the specified vertex to the grpah
        '''

        if vertex.index <= self.maxIndex:
            print('Error: bad vertex index (' + str(vertex.index) + ')')
        else:
            self.vertices.append(vertex)
            self.maxIndex = vertex.index

    def __repr__(self):
        return self.vertices.__repr__()

def splitWhen(pred, iterable):
    '''
    splits an iterable into two lists at the element x
    for which pred(x) is true
    '''

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
    '''
    loads data from files
    '''

    # load obstacles
    f1 = open('hw4_world_and_obstacles_convex.txt', 'r')
    obstacleStrings = f1.read().split('\n')[2:]

    world, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings)
    
    makePoint = lambda xy: Point(xy[0], xy[1])
    toPoint = lambda s: makePoint(list(map(float, s.strip().split(' '))))
    world = list(map(toPoint, world))
    
    obstacles = []
    while obstacleStrings != []:
        obstacle, obstacleStrings = splitWhen(lambda s: not ' ' in s, obstacleStrings[1:])
        if len(obstacle) > 0:
            obstacles = obstacles + [list(map(toPoint, obstacle))]

    # create graph from start and end vertices
    f2 = open('hw4_start_goal.txt', 'r')
    graph = Graph()
    vertices = [ Vertex(toPoint(s), i, -1) for i, s in enumerate(f2.read().split('\n')[:-1]) ]
    for vertex in vertices:
        graph.addVertex(vertex)

    return obstacles, world, graph

def orientation(p1, p2, p3):
    '''
    calculates the orientation of the poitns p1, p2, and p3
    returns -1 for clockwise orientation, 1 for clockwise,
    0 for colinear
    '''

    o = (p2.x - p1.x)*(p3.y - p1.y) - (p2.y - p1.y)*(p3.x - p1.x)
    if o > 0:
        return 1
    if o < 0:
        return -1
    return 0

def pointOrderKey(p, q):
    '''
    converts a point q to a tuple of values by which to sort for
    the convex hull algorithm
    '''

    angle = (math.atan2(q.y - p.y, q.x - p.x)) % (2*math.pi)
    return (angle, (-1 if angle > math.pi/4 else 1) *
            ((p.x - q.x)**2 + (p.y - q.y)**2)**0.5)

def convexHull(points):
    '''
    computes the convex hull for a set of poitns
    '''

    p = points[0]
    for point in points:
        if point.y < p.y or (point.y == p.y and point.x < p.x):
            p = point

    orderedPoints = sorted(points, key=lambda q: pointOrderKey(p, q))


    numPoints = len(orderedPoints)
    isInHull = [True] * numPoints

    for i in range(1, numPoints):
        p1 = orderedPoints[(i - 1) % numPoints]
        p2 = orderedPoints[i]
        p3 = orderedPoints[(i + 1) % numPoints]
        
        if orientation(p1, p2, p3) <= 0:
            isInHull[i] = False

    return [point for i, point in enumerate(orderedPoints) if isInHull[i]]

def growPolygons(polygons):
    '''
    grows the polygons by the size of the roomba
    '''

    createDiam = 0.41
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
    '''
    returns true iff the segment p1 p2 intersects p3 p4
    endpoints don't count for intersections
    '''

    return orientation(p1, p2, p3) != orientation(p1, p2, p4) and \
            orientation(p3, p4, p1) != orientation(p3, p4, p2) or \
            p1 == p3 or p1 == p4 or p2 == p3 or p2 == p4

def isVisible(v1, v2, obstacles, world):
    '''
    returns true iff v1 is visible from v2
    '''

    for i, obstacle in enumerate(obstacles + [world]):

        p1 = Point(v1.p.x, v1.p.y)
        p2 = Point(v2.p.x, v2.p.y)

        # move away in case v1 is inside obstacle2 or vice versa
        if v1.obstacle == i:
            p1.shift(p2, -0.01)
            p2.shift(p1, 100)
        elif v2.obstacle == i:
            p2.shift(p1, -0.01)
            p1.shift(p2, 100)

        # since vertices blocked by their own obstacle won't be added anyways
        if not (v1.obstacle == v2.obstacle and v1.obstacle == i):
            for j in range(len(obstacle)):
                if intersects(p1, p2,
                        obstacle[j], obstacle[(j + 1) % len(obstacle)]):
                    return False

    return True

def createGraph():
    '''
    creates the visibility graph and returns all data necessary for
    visualization
    '''

    obstacles, world, graph = loadPolygons()
    start_goal = list(graph.vertices)
    grownObstacles = growPolygons(obstacles)
    index = graph.maxIndex + 1

    # add vertices for obstacles and edges for polygon edges
    for obsInd, obstacle in enumerate(grownObstacles):
        vertices = []
        for point in obstacle:
            vertex = Vertex(point, index, obsInd)
            index = index + 1
            vertices.append(vertex)
            graph.addVertex(vertex)

        for i in range(len(vertices)):
            vertices[i].addAdjacent(vertices[(i + 1) % len(vertices)])

    # compute visibility between vertices, with special cases for vertices
    # on the same obstacle
    size = len(graph.vertices)
    for v1i in range(size):
        v1 = graph.vertices[v1i]
        for v2i in range(v1i + 1, size):
            v2 = graph.vertices[v2i]
            if isVisible(v1, v2, grownObstacles, world):
                if v1.obstacle != v2.obstacle:
                    v1.addAdjacent(v2)
            elif v1.obstacle == v2.obstacle:
                v1.removeAdjacent(v2)

    return graph, world, obstacles, grownObstacles, start_goal
