function [grains,I_GX] = findByLocation( grains, X )
% select a grain by spatial coordinates
%
%% Input
% grains - @GrainSet
% xy - list of [x(:) y(:)] coordinates, respectively [x(:) y(:) z(:)]
%
%% Output
% grains - @GrainSet
%
%% Example
%  plotx2east
%  plot(grains)
%  p = ginput(1)
%  g = findByLocation(grains,p);
%  hold on, plotBoundary(g,'color','r','lineWidth',2)
%
%% See also
% EBSD/findByLocation GrainSet/findByOrientation


if isa(grains,'Grain2d')
  boundaryEdgeOrder = get(grains,'boundaryEdgeOrder');
  isCell = cellfun('isclass',boundaryEdgeOrder,'cell');
  
  boundaryEdgeOrder(isCell) = cellfun(@(x) x{1} ,boundaryEdgeOrder(isCell),'UniformOutput',false);
end

I_VG   = get(grains,'I_VG');
V      = grains.V;

% restrict vertices to available grains
subset = full(any(I_VG,2));
V_g    = V(subset,:);
I_GV   = I_VG(subset,any(I_VG,1))';


closestVertex = bucketSearch(V_g,X);

% buffer results
[a,i] = find(I_GV(:,closestVertex));


if exist('boundaryEdgeOrder','var')
  edgeOrder = boundaryEdgeOrder(a);
  
  b = false(size(edgeOrder));
  for k=1:numel(edgeOrder)
    V_k = V(edgeOrder{k},:);
    b(k) = inpolygon(X(i(k),1),X(i(k),2),V_k(:,1),V_k(:,2));
  end
  
  I_GX = sparse(a,i,b);
  
  checkHole = sum(I_GX) > 1;
  
  if any(checkHole)
    h = find(checkHole);
    
    for l = 1:numel(h)
      candit = find(I_GX(:,h(l)));
      [A m] = min(area(subsref(grains,candit)));
      
      I_GX(:,h(l)) = false;
      I_GX(candit(m),h(l)) = true;
    end
    
  end
  
else
  
  warning('I only return some grains close to the truth, since I have no idea');
  
  I_GX = sparse(a,i,1);  
  
end

grains = subsref(grains,any(I_GX,2));
