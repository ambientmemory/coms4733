from visibility import *

''' 
Test on sample graph
Path should be 0 -> 1 -> 2 -> 3

graph = []
points = []
points.append(Point(0,0))
points.append(Point(1,0))
points.append(Point(3,0))
points.append(Point(5,0))
points.append(Point(0,3))
points.append(Point(1,1))
points.append(Point(2,2))

for i in range(len(points)):
    graph.append(Vertex(points[i],i,-1))

graph[0].addAdjacent(graph[1])
graph[0].addAdjacent(graph[4])
graph[0].addAdjacent(graph[5])
graph[1].addAdjacent(graph[5])
graph[1].addAdjacent(graph[2])
graph[2].addAdjacent(graph[3])
graph[2].addAdjacent(graph[6])
graph[3].addAdjacent(graph[6])
graph[4].addAdjacent(graph[5])
graph[4].addAdjacent(graph[6])
graph[5].addAdjacent(graph[6])

dijkstra(graph, graph[0], graph[3])

'''

def dijkstra(vertices, start, target):
    
    graph = {}
    
    for v in vertices:
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
            if(x[0] in unvisited and (unvisited[x[0]] > x[1] + visited[n] or unvisited[i] < 0)):
                unvisited[x[0]] = x[1] + visited[n]
                prev[x[0]] = n
                
        n =  min(unvisited)
        visited[n] = unvisited[n]
        unvisited.pop(n)
    
    
    path = [target.index]
    y = target.index
    while y!= start.index:
        path.append(prev[y])
        y = prev[y]
        
    path.reverse()
#    print(path)
    return path