function [ebsd,grainsM] = cleanUpPseudoSym(ebsd,grains,mori,varargin)
%
% Syntax
%
% Input
%
% Output
%

% select grain boundaries with the correct symmetry
gB = grains.boundary(mori.CS,mori.CS);

% select grain boundaries with the mori
tol = get_option(varargin,'delta',2*degree);
gB =  gB(angle(gB.misorientation,mori) < tol);

% extent of each component
xmin = accumarray(gB.componentId,gB.midPoint.x,[],@min);
ymin = accumarray(gB.componentId,gB.midPoint.y,[],@min);
xmax = accumarray(gB.componentId,gB.midPoint.x,[],@max);
ymax = accumarray(gB.componentId,gB.midPoint.y,[],@max);
d = sqrt((xmax-xmin).^2 + (ymax-ymin).^2);

% boundary length of each component
l = accumarray(gB.componentId,gB.segLength);

% tortuosity projected back to each segment
tortuosity = l(gB.componentId)./d(gB.componentId);

maxT = get_option(varargin,'threshold',1.5);

cond = tortuosity > maxT & gB.componentSize > 4;

% merge grains
[grainsM,parentId,newInd] = merge(grains,gB(cond),...
  'calcMeanOrientation','maxArea');

% update EBSD
ind = ebsd.grainId > 0;
ebsd.grainId(ind) = parentId(grains.id2ind(ebsd.grainId(ind)));

% update EBSD orientations
for k=newInd
  
  ind = find(ebsd.grainId == grainsM.id(k));
  
  ori = ebsd.orientations(ind);

  swap = angle(ori,grainsM.meanOrientation(k) * inv(mori)) ...
    < angle(ori,grainsM.meanOrientation(k));
  
  ori(swap) = ori(swap) * mori;
  ebsd.orientations(ind) = ori;

end
