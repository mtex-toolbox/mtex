function grains = findByLocation( grains, xy )
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

I_VG = get(grains,'I_VG');

if isa(grains,'Grain2d')
  boundaryEdgeOrder = get(grains,'boundaryEdgeOrder');
  isCell = cellfun('isclass',boundaryEdgeOrder,'cell');
  
  boundaryEdgeOrder(isCell) = cellfun(@(x) x{1} ,boundaryEdgeOrder(isCell),'UniformOutput',false);
else isa(grains,'Grain3d')
  warning('currently not supported, it only returns grains incedent to the closest boundary vertex')
end

s = any(I_VG,2);
Vg = grains.V(s,:);
I_VG = I_VG(s,:);

nd = sparse(numel(grains),size(xy,1));
for k=1:size(xy,1)
  
  dist = sqrt(sum(bsxfun(@minus,Vg,xy(k,:)).^2,2));
  [dist i] = min(dist);
  
  candit = find(I_VG(i,:));
  
  if exist('boundaryEdgeOrder','var')
    b =  boundaryEdgeOrder(candit);
    
    c = false(numel(b),1);
    for l=1:numel(b)
      c(l) =  inpolygon(xy(k,1),xy(k,2),grains.V(b{l},1),grains.V(b{l},2));
    end
    candit = candit(c);
    
    if numel(candit)>1
      [a i] =  min(area(subsref(grains,candit)));
      candit = candit(i);
    end
    
  else % 3d case
    
  end
  
  nd(candit,k) = 1;
end

grains = subsref(grains, any(nd,2));





