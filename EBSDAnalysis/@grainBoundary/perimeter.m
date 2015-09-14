function  peri = perimeter(gb,varargin)
% boundary length per grain including holes
%
% Syntax
%   grains.boundary.perimeter 
%
%   % include subgrain boundaries
%   grains.boundary.perimeter + grains.innerBoundary.perimeter
%
%   gB = grains.boundary('Iron','Iron');
%
%   % length of low angle boundary per grain
%   gB(gB.misorientation.angle < 15*degree).perimeter 
%
%   % length of special boundaries per grain
%   gB(gB.isTwinning(CSL(3))).perimeter
%   
% Input
%  gb - @grainBoundary
%
% Output
%  peri - list of grain perimeter sorted by grain id
%
% See also
% Grain2d/perimeter

F = reshape(nonzeros(gb.F),[],2);

edgeLength = sqrt(sum((gb.V(F(:,1),:) - gb.V(F(:,2),:)).^2,2));

peri = sparse(gb.grainId(:,2),1,edgeLength,max(gb.grainId(:)),1);
ind = gb.grainId(:,1) > 0;
peri = peri + sparse(gb.grainId(ind,1),1,edgeLength(ind),length(peri),1);
