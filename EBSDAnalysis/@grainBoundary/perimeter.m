function  peri = perimeter(gb,varargin)
% boundary length
%
% Input
%  gb - @grainBoundary
%
% Output
%  peri    - perimeter
%
% Syntax
%   p = perimeter(grains.boundary) - 
%
%   p = perimeter(grains,10*degree) - returns the length of low angle
%   boundaries per grain
%
% p = perimeter(grains,CSL(3)) - returns the length of special boundaries
%   per grains
%
% p = perimeter(grains,property,...,param,val,...) -
%
% See also
% Grain2d/equivalentperimeter


F = reshape(nonzeros(gb.F),[],2);

edgeLength = sqrt(sum((gb.V(F(:,1),:) - gb.V(F(:,2),:)).^2,2));

peri = full(sparse(g,1,edgeLength,size(gb,1),1));

