function border = EulerCycles(Vertex,nextVertex)
% retrieve Euler cycles from an oriented Edge list

[ignore,a] = sort(Vertex);
[ignore,b] = sort(nextVertex);

vertexPointer(b) = a;

vertexOrder = zeros(numel(Vertex),1);
vertexOrder(1) = a(1);  % starting vertex

edgeCount = 0;  % number of edges per euler cycle
next = 1; previous = next;

while true
  
  next = next+1;  
  nextEdge = vertexPointer(vertexOrder(previous));
  
  if nextEdge > 0
    
    vertexOrder(next) = nextEdge;
    vertexPointer(vertexOrder(previous)) = -1;
    
  else
    
    edgeCount(end+1) = previous;    
    startVertex = vertexPointer(vertexPointer>0);
    
    if isempty(startVertex),
      break
    else
      vertexOrder(next) = startVertex(1);
    end
    
  end
  
  previous = next;
  
end


numTours = numel(edgeCount)-1;
if numTours > 1,
  
  border = cell(1,numTours);
  for k=1:numTours
    border{k} = Vertex(vertexOrder(edgeCount(k)+1:edgeCount(k+1)))';
  end
  
else
  
  border = Vertex(vertexOrder)';
  
end
