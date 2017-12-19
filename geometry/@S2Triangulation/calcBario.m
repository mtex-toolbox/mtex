function  [bario,tId] = calcBario(sT,v,tId)

v = v(:);
if nargin == 2, tId = ones(size(v)); end
tId = tId(:);

% in the beginning nothing has been found
isInside = false(length(v),1);

% bariocentric coordinates
bario = zeros(length(v),3);

% search for the correct triangle
while any(~isInside) % as long there is something to do

  notInside = ~isInside;
  [isInside(notInside),tId(notInside),bario(notInside,:)] ...
    = sT.checkInside(v(notInside),tId(notInside));
  
end

% normalize to sum 1
bario = bsxfun(@rdivide,bario,sum(bario,2));

% write as sparse matrix
% position is vertexid 
bario = sparse(repmat((1:length(v)).',1,3),sT.T(tId,:),bario,length(v),length(sT.vertices));