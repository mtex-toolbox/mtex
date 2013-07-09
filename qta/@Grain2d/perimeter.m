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


I_FD = abs(get(grains,'I_FDext'));
I_DG = get(grains,'I_DG');
I_FG = I_FD*I_DG;

f = specialBoundary(grains,varargin{:},[],'ext');

[i,g] = find(I_FG(f,any(I_DG)));
f = f(i);

V = full(get(grains,'V'));
F = full(get(grains,'F'));

F = F(f,:);
edgeLength = sqrt(sum((V(F(:,1),:) - V(F(:,2),:)).^2,2));

peri = full(sparse(g,1,edgeLength,numel(grains),1));





