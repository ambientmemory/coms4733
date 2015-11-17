from visibility import *

''' 
sample graph
graph = {
    "a" : [("b", 1), ("c", 2), ("d", 3)],
    "b" : [("a", 1), ("c", 1), ("e", 2)],
    "c" : [("a", 2), ("b", 1), ("d", 1), ("e", 3), ("f", 2)],
    "d" : [("a", 3), ("c", 1), ("f", 2)],
    "e" : [("b", 2), ("c", 3), ("f", 1), ("t", 2)],
    "f" : [("c", 3), ("d", 2), ("e", 1), ("t", 2)],
    "t" : [("e", 2), ("f", 2)]
    }
'''

def dijkstra(vertices, start, target):
    
    graph = {}
    
    for v in vertices:
        graph[v.index] = []
        
        for i in v.adjacent:
            dist = ((v.p.x - i.p.x)**2 + (v.p.y - i.p.y)**2)**.5  # distance
            graph[v.index].append((i.index, dist))
    
    
    visited = {start.index: 0}
    unvisited = {}
    path = {}
    
    for i in graph:
        if(i != start.index):
            unvisited[i] = -1 
            
            
    n = start.index
    
    while n != target.index:
        for x in graph[n]:
            if(x[0] in unvisited and (unvisited[x[0]] > x[1] + visited[n] or unvisited[i] < 0)):
                unvisited[x[0]] = x[1] + visited[n]
                path[x[0]] = n
                
        n =  min(unvisited)
        visited[n] = unvisited[n]
        unvisited.pop(n)
    
    print(visited) # delete later
    print(path)
    
    p = [target]
    y = target
    while y!= start:
        p.append(path[y])
        y = path[y]
        
    p.reverse()
    print(p)
    return p


#dijkstra(graph, "a", "t")