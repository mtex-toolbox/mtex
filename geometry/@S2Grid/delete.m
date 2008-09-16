function S2G = delete(S2G,points)
% elilinates points from grid
%% Input
%  S2G    - @S2Grid
%  points - double | @vector3d
%
%% Output
%  S2G    - @S2Grid

if isa(points,'logical'), points = find(points);end
if isa(points,'S2Grid'), points = vector3d(points);end
if isa(points,'vector3d'), points = find(S2G,points);end

S2G.Grid(points) = [];

if check_option(S2G.options,'INDEXED')

  % update rho indexing
  for ith = 1:GridLength(S2G.theta)
    
    irh = points>0 & points <=GridLength(S2G.rho(ith));
    S2G.rho(ith) = delete(S2G.rho(ith),points(irh));    
    
    points = points - GridLength(S2G.rho(ith));
  end
  
  % update theta indexing
  S2G.theta = delete(S2G.theta,GridLength(S2G.rho)==0);
  S2G.rho(GridLength(S2G.rho) == 0) = [];
  
end
