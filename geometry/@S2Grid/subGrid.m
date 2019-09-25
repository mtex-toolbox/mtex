function [S2G,ind] = subGrid(S2G,v,epsilon)
% subgrid 
%
% Syntax
%   S2G = subGrid(S2G,Ind)
%   [S2G,ind] = subGrid(S2G,midpoint,epsilon)
%
% Input
%  S2G - S2Grid
%  ind - int32
%  midpoint - vector3d
%  epsilon  - double
%
% Output
%  S2G   - @S2Grid (not indexed)
%  ind - int32

if nargin == 3
  ind = find(S2G,v,epsilon);
  ind = any(ind,2);
else
  ind = v;
end

S2G.x = S2G.x(ind);
S2G.y = S2G.y(ind);
S2G.z = S2G.z(ind);

S2G.rhoGrid = subGrid(S2G.rhoGrid,ind);
S2G.thetaGrid = subGrid(S2G.thetaGrid,GridLength(S2G.rhoGrid)>0);
S2G.rhoGrid(GridLength(S2G.rhoGrid)==0) = [];
