function S2G = delete(S2G,points)
% elilinates points from grid
%
% Input
%  S2G    - @S2Grid
%  points - logical | double | @vector3d
%
% Output
%  S2G    - @S2Grid
%
% See also
% S2Grid/copy

if isa(points,'vector3d'), points = find(S2G,points); end

if isnumeric(points), 
  inds = false(length(S2G),1);
  inds(points) = true;
  points = inds; 
end

S2G.x(points) = [];
S2G.y(points) = [];
S2G.z(points) = [];

cs = [0 cumsum(GridLength(S2G.rhoGrid))];
% update rho indexing
for ith = 1:GridLength(S2G.thetaGrid)
  irh = points(cs(ith)+1:cs(ith+1));
  S2G.rhoGrid(ith) = delete(S2G.rhoGrid(ith),irh);
end
  
% update theta indexing
S2G.thetaGrid = delete(S2G.thetaGrid,GridLength(S2G.rhoGrid)==0);
S2G.rhoGrid(GridLength(S2G.rhoGrid) == 0) = [];
