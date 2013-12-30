function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain, with Holes
%
%% Input
%  p - @GrainSet 
%  property - if specified, returns only the length of
%    boundary satisfying a <GrainSet.specialBoundary.html specialBoundary>
%
%% Options
% options - please see <GrainSet.specialBoundary.html specialBoundary>
%% Output
%  peri    - perimeter
%
%% Syntax
% p = perimeter(grains) - 
%
% p = perimeter(grains,10*degree) - returns the length of low angle
%   boundaries per grain
%
% p = perimeter(grains,CSL(3)) - returns the length of special boundaries
%   per grains
%
% p = perimeter(grains,property,...,param,val,...) -
%
%% See also
% Grain2d/equivalentperimeter


I_FG = grains.I_FD*grains.I_DG;

f = specialBoundary(grains,varargin{:},[],'ext');

[i,g] = find(I_FG(f,any(grains.I_DG)));
f = f(i);

V = grains.V;
F = grains.F;

F = F(f,:);
edgeLength = sqrt(sum((V(F(:,1),:) - V(F(:,2),:)).^2,2));

peri = full(sparse(g,1,edgeLength,size(grains,1),1));





