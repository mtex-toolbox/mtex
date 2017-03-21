function [idV,idE] = EulerTours(A)
% find Euler tours in an adjacency matrix

s = sum(A);
nextId = find(mod(s,2),1);
if isempty(nextId)
  nextId = find(s,1);
end
idV = [];
idE = [];

while ~isempty(nextId)
  
  idV(end+1) = nextId;
  
  % find neigbour
  nextId = find(A(:,idV(end)),1);
  
  if ~isempty(nextId)
    idE(end+1) = A(idV(end),nextId);
    A(idV(end),nextId) = 0;
    A(nextId,idV(end)) = 0;
  else
    idE(end+1) = NaN;
    s = sum(A>0);
    nextId = find(mod(s,2),1);
    if isempty(nextId)
      nextId = find(s,1);
    end
  end
end