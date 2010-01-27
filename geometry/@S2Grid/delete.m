function S2G = delete(S2G,points)
% elilinates points from grid
%% Input
%  S2G    - @S2Grid
%  points - logical | double | @vector3d
%
%% Output
%  S2G    - @S2Grid
%
%% See also
% S2Grid/copy

if isa(points,'vector3d'), points = find(S2G,points); end
if isnumeric(points), 
  inds = false(numel(S2G),1);
  inds(points) = true;
  points = inds; 
end

S2G.vector3d(points) = [];

if check_option(S2G.options,'INDEXED')

  cs = [0 cumsum(GridLength(S2G.rho))];
  % update rho indexing
  for ith = 1:GridLength(S2G.theta)
    irh = points(cs(ith)+1:cs(ith+1));
    S2G.rho(ith) = delete(S2G.rho(ith),irh);    
  end
  
  % update theta indexing
  S2G.theta = delete(S2G.theta,GridLength(S2G.rho)==0);
  S2G.rho(GridLength(S2G.rho) == 0) = [];
  
end
