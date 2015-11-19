'''
Homework 4
Team 10
Authors: Jett Andersen, Tia Zhao, Piyali Mukherjee
'''

from visibility import *

def dijkstra(vertices, start, target):
    '''
    returns a list of vertices corresponding to the shortest
    path between start and target along the given vertices
    '''
    
    original = {}
    graph = {}
    
    for v in vertices:
        original[v.index] = v
        graph[v.index] = []
        
        for i in v.adjacent:
            dist = ((v.p.x - i.p.x)**2 + (v.p.y - i.p.y)**2)**.5
            graph[v.index].append((i.index, dist))
    
    visited = {start.index: 0}
    unvisited = {}
    prev = {}
    
    for i in graph:
        if(i != start.index):
            unvisited[i] = -1 
            
    n = start.index
    
    while n != target.index:
        for x in graph[n]:
            if(x[0] in unvisited and (unvisited[x[0]] > x[1] + visited[n] or unvisited[x[0]] < 0)):
                unvisited[x[0]] = x[1] + visited[n]
                prev[x[0]] = n
                
        n = minUnvisited(unvisited)
        visited[n] = unvisited[n]
        unvisited.pop(n)
    
    
    path = [target]
    y = target.index
    while y!= start.index:
        path.append(original[prev[y]])
        y = prev[y]
    path.pop()
    path.append(start)
        
    path.reverse()
    return path
    
def minUnvisited(unvisited):
    positives = unvisited.copy()
    for i in unvisited:
        if unvisited[i]<0:
            positives.pop(i)
            
    return min(positives, key=positives.get)
